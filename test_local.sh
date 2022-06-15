#!/bin/bash

echo "hibernate local test start"

LOCAL_TIDB_LOG="local_tidb_hibernate.log"

echo "starting tidb-servers, log file: ${LOCAL_TIDB_LOG}"
# using fast_config.toml config file
${TIDB_SERVER_PATH} -config tidb_config.toml -store unistore -path "" -lease 0s > ${LOCAL_TIDB_LOG} 2>&1 &
FAST_SERVER_PID=$!
sleep 5
echo "tidb-server(PID: ${FAST_SERVER_PID}) started"

# when exit clean

trap 'kill ${FAST_SERVER_PID}' EXIT

mysql -u root -h 127.0.0.1 -P 4001 < init.sql;

# start test
sh ./gradlew clean test -Pdb=tidb -DdbHost=localhost:4001 --stacktrace
EXIT_CODE=$?

# handle test results
if [ ${EXIT_CODE} -ne 0 ]
then
	echo "ERROR: hibernate test failed!"
	echo "=========== ERROR EXIT [${EXIT_CODE}]: FULL tidb.log BEGIN ============"
	cat ${LOCAL_TIDB_LOG}
	echo "=========== ERROR EXIT [${EXIT_CODE}]: FULL tidb.log END =============="
	exit 1
fi

# handle race
RACE_RET=`grep 'DATA RACE' ${LOCAL_TIDB_LOG} || true`
if [ -n "${RACE_RET}" ]
then
	echo "tidb-server DATA RACE!"
	cat ${LOCAL_TIDB_LOG}
	exit 1
fi
