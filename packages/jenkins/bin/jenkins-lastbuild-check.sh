# COCMD-DESC: Check the status of the latest build of a Jenkins job.
# COCMD-USAGE: jenkins-lastbuild-check.sh jenkins_url job_name username password

# Function to display usage information
usage() {
    echo "Usage: $0 <JENKINS_URL> <JOB_NAME> <USERNAME> <PASSWORD_OR_API_TOKEN>"
    exit 1
}

# Check for the correct number of command-line arguments
if [ "$#" -ne 4 ]; then
    usage
fi

# Jenkins Server URL
JENKINS_URL="$1"

# Job Name
JOB_NAME="$2"

# Username
USERNAME="$3"

# Password or API Token
PASSWORD_OR_API_TOKEN="$4"

# File where web session cookie is saved
COOKIEJAR="$(mktemp)"

# Function to get the Jenkins CSRF crumb
get_jenkins_crumb() {
    local CRUMB
    CRUMB=$(curl -s --fail -u "$USERNAME:$PASSWORD_OR_API_TOKEN" --cookie-jar "$COOKIEJAR" "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
    echo "$CRUMB"
}

# Get the Jenkins CSRF crumb
CRUMB=$(get_jenkins_crumb)

# Function to get the latest build status
get_latest_build_status() {
    local BUILD_STATUS
    BUILD_STATUS=$(curl -X GET \
        --fail \
        --silent \
        --cookie "$COOKIEJAR" -H "$CRUMB" \
        -u "$USERNAME:$PASSWORD_OR_API_TOKEN" \
        "$JENKINS_URL/job/$JOB_NAME/lastBuild/api/json?tree=result")
    echo "$BUILD_STATUS"
}

# Get the latest build status
LATEST_BUILD_STATUS=$(get_latest_build_status)

# Check if the build status contains "SUCCESS" or "FAILURE"
if [[ "$LATEST_BUILD_STATUS" == *"SUCCESS"* ]]; then
    echo "✅ Latest build of $JOB_NAME: SUCCESS"
    echo "$JENKINS_URL/job/$JOB_NAME/lastBuild/console"
    exit 0
elif [[ "$LATEST_BUILD_STATUS" == *"FAILURE"* ]]; then
    echo "❌ Latest build of $JOB_NAME: FAILURE"
    echo "$JENKINS_URL/job/$JOB_NAME/lastBuild/console"
    exit 1
else
    echo "❌ Latest build of $JOB_NAME: Status unknown or in progress"
    echo "$JENKINS_URL/job/$JOB_NAME/lastBuild/console"
    exit 2
fi
