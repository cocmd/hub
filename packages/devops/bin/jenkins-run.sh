# write a script to run jenkins build. username and password are arguments to this script
# run the script from the command line
# ./jenkins-run.sh username password
# username and password are arguments to this script
# also the job name is params and any extra args to the job are passed as params
set -e
curl -X POST http://localhost:8080/job/$1/buildWithParameters --user $2:$3 --data-urlencode json='{"parameter": [{"name":"params", "value":"'"$4"'"}]}'

# EXAMPLE how to call to this script:
# ./jenkins-run.sh jobname username password "param1=value1&param2=value2"