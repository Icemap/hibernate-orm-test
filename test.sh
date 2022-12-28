#!/bin/bash
set +x

echo "hibernate test start"

HIBERNATE_TIDB_LOG="tidb_hibernate.log"

# start tidb servers
echo "starting tidb-servers, log file: ${HIBERNATE_TIDB_LOG}"
${TIDB_SERVER_PATH} -config tidb_config.toml -store unistore -path "" -lease 0s > ${HIBERNATE_TIDB_LOG} 2>&1 &
SERVER_PID=$!
sleep 5
echo "tidb-server(PID: ${SERVER_PID}) started"

# when exit clean

trap 'kill ${SERVER_PID}' EXIT

mysql -u root -h 127.0.0.1 -P 4001 < init.sql

# start test
gradle :hibernate-core:test -Pdb=tidb -DdbHost=localhost:4001 --stacktrace -g gradle-user-home
EXIT_CODE=$?

# handle test results
if [ ${EXIT_CODE} -ne 0 ]
then
	echo "ERROR: hibernate test failed!"
	echo "=========== ERROR EXIT [${EXIT_CODE}]: FULL tidb.log BEGIN ============"
	cat ${HIBERNATE_TIDB_LOG}
	echo "=========== ERROR EXIT [${EXIT_CODE}]: FULL tidb.log END =============="
	exit 1
fi