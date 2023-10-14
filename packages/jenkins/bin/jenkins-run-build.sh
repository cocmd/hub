#!/bin/bash
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 <JENKINS_URL> <JOB_NAME> <USERNAME> <PASSWORD> [PARAMETERS] [WAIT_FOR_FINISH]"
    echo "Trigger a Jenkins job and optionally monitor its execution."
    echo
    echo "Arguments:"
    echo "  <JENKINS_URL>:     The URL of the Jenkins server."
    echo "  <JOB_NAME>:        The name of the Jenkins job to trigger."
    echo "  <USERNAME>:        Your Jenkins username."
    echo "  <PASSWORD>:        Your Jenkins password."
    echo "  [PARAMETERS]:      Optional parameters for the job."
    echo "  [WAIT_FOR_FINISH]: Optional flag to wait for the build to finish (true/false, default is true)."
    exit 1
}

# Check for the correct number of command-line arguments
if [ "$#" -lt 4 ] || [ "$#" -gt 6 ]; then
    usage
fi

# Jenkins Server URL
JENKINS_URL="$1"

# Job Name
JOB_NAME="$2"

# Username
USERNAME="$3"

# Password
PASSWORD="$4"

# Parameters for the job (if any)
PARAMETERS="$5"

# Debug function to echo debug information
debug() {
    echo "DEBUG: $1"
}

# Debug mode (set to true to enable debugging)
DEBUG=false

# File where web session cookie is saved
COOKIEJAR="$(mktemp)"

# echo "Jenkins url is $JENKINS_URL"

# Function to get the Jenkins CSRF crumb
get_jenkins_crumb() {
    local CRUMB
    CRUMB=$(curl -s --fail -u "$USERNAME:$PASSWORD" --cookie-jar "$COOKIEJAR" "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
    echo "$CRUMB"
}

# Get the Jenkins CSRF crumb
CRUMB=$(get_jenkins_crumb)
debug "CRUMB item: $CRUMB"

# Trigger the job with parameters
debug "Triggering Jenkins job: $JOB_NAME with parameters: $PARAMETERS"

# Define the parameters (if any) as a query string
PARAMETER_STRING=""
if [ -n "$PARAMETERS" ]; then
    PARAMETER_STRING="-d $PARAMETERS"
fi

# Trigger the job and capture the Location header to monitor it
debug "Calling $JENKINS_URL/job/$JOB_NAME/buildWithParameters with parameters: $PARAMETER_STRING"
QUEUE_ITEM_URL=$(curl -f --silent -X POST -u "$USERNAME:$PASSWORD" --cookie "$COOKIEJAR" -H "$CRUMB" $PARAMETER_STRING "$JENKINS_URL/job/$JOB_NAME/buildWithParameters" -D - | grep Location | awk '{print $2}')

# check for errors in the curl reponse
if [ $? -ne 0 ]; then
    echo "Error: Failed to trigger Jenkins job: $JOB_NAME" >&2
    exit 1
fi

QUEUE_ITEM_URL=$(echo "$QUEUE_ITEM_URL" | sed 's/[^A-Za-z0-9:/._-]//g')

# make sure QUEUE_ITEM_URL is valid url
if [[ ! "$QUEUE_ITEM_URL" =~ ^http.* ]]; then
    echo "Error: QUEUE_ITEM_URL is not a valid url." >&2
    exit 1
fi

# Initialize BUILD_NUMBER to an empty string
BUILD_NUMBER=""

# Wait for a valid build number to be assigned
while ! [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; do
    # Fetch the BUILD_NUMBER
    BUILD_NUMBER=$(curl -f --silent -X GET -u "$USERNAME:$PASSWORD" --cookie "$COOKIEJAR" -H "$CRUMB" "$QUEUE_ITEM_URL/api/json" | jq -r '.executable.number')
    
    if ! [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
        echo "DEBUG: Build number is not a valid number. Retrying in 5 seconds..."
        sleep 5
    fi
done

echo "Job ${JOB_NAME} triggered successfully - $JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER/console"

# Check if WAIT_FOR_FINISH flag is set to true (default) before waiting for build to finish
WAIT_FOR_FINISH="${6:-true}"

if [ "$WAIT_FOR_FINISH" == "true" ]; then
    # Wait for the build to finish
    echo "Waiting for build #${BUILD_NUMBER} to finish..."
    while true; do
        BUILD_STATUS=$(curl -X GET \
          --fail \
          --silent \
          --cookie "$COOKIEJAR" -H "$CRUMB" \
          -u "$USERNAME:$PASSWORD" \
          "$JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER/api/json?tree=result")
        
        if [[ "$BUILD_STATUS" != *"null"* ]]; then
            break
        fi
        sleep 5
    done

    # Get the build result
    BUILD_RESULT=$(curl -X GET \
          --fail \
          --silent \
          --cookie "$COOKIEJAR" -H "$CRUMB" \
          -u "$USERNAME:$PASSWORD" \
          "$JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER/api/json?tree=result")

    echo "Build result: $BUILD_RESULT"
    if [[ "$BUILD_RESULT" != *"SUCCESS"* ]]; then
        echo "Build failed!"
        exit 1
    fi
    echo "Build succeeded!"
else
    echo "Not waiting for build to finish."
fi

exit 0
