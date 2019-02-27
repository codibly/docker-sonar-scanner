#!/bin/sh

# try get user token from input args

token=$(echo $@ | sed 's/.*sonar.login=\([^ ]*\).*/\1/g')

if test -z "$token"
then
    # else try get token from sonar properties file
    token=$(cat sonar-project.properties | sed 's/sonar.login=\(.*\)/\1/;t;d')
fi

get() {
# in url pass additional auth - ..//password@:
    url=$(echo $1 | sed "s/\(https\?:\/\/\)\(.*\)/\1$token:@\2/")
    wget -qO- -c $url || exit 1
}

serverUrl=$(cat .scannerwork/report-task.txt | sed 's/serverUrl=\(.*\)/\1/;t;d')
ceTaskUrl=$(cat .scannerwork/report-task.txt | sed 's/ceTaskUrl=\(.*\)/\1/;t;d')

while true; do
    analysisId=$(get $ceTaskUrl | sed 's/.*analysisId":"\(.*\?\)","status.*}}/\1/')

#   check if anylysis is completed
    if echo $analysisId | grep -q status; then
        echo "Waiting for analysis complete..."
    else
        break;
    fi
# wait until sonar complete report
    sleep 3
done

# get status
status=$(get $serverUrl/api/qualitygates/project_status?analysisId=$analysisId | sed 's/.*"status":"\(.*\)","conditions".*/\1/')

if [ $status != "OK" ]; then
    echo "Quality gate not passed"
    exit 1;
fi;

echo "Quality gate: Passed"
