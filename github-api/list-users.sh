#!/bin/bash
###########################################
# Author: Vidhushan
# About : List users with READ access in a GitHub repository
# Date  : 13.11.2025
###########################################

API_URL="https://api.github.com"

# ----------- UPDATE THESE 2 VALUES -----------
USERNAME="your_github_username"
TOKEN="your_github_pat_token"
# ---------------------------------------------

REPO_OWNER="vidhushanorg"   # Fixed as per your requirement
REPO_NAME="$1"              # Only repository name comes from user

# ---------------- Helper Function ----------------
helper() {
    if [ $# -ne 1 ]; then
        echo "❌ Error: Wrong number of arguments."
        echo "Usage: $0 <repository_name>"
        echo "Example: $0 shell-scripting-projects"
        exit 1
    fi
}

# ---------------- GitHub API GET ----------------
github_api_get() {
    local endpoint="$1"
    curl -s -u "${USERNAME}:${TOKEN}" "${API_URL}/${endpoint}"
}

# --------- List Users With Read Access Function ---------
list_users_with_read_access() {

    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch API response
    response="$(github_api_get "$endpoint")"

    echo "--------------------------------------------------"
    echo "🔍 RAW API RESPONSE (debug output):"
    echo "$response"
    echo "--------------------------------------------------"

    # If response starts with '{', it's an error object
    if echo "$response" | jq -e 'type=="object"' >/dev/null 2>&1; then
        error_msg=$(echo "$response" | jq -r '.message // empty')
        if [[ -n "$error_msg" ]]; then
            echo "❌ GitHub API Error: $error_msg"
            exit 1
        fi
    fi

    # If response is not a JSON array, exit safely
    if ! echo "$response" | jq -e 'type=="array"' >/dev/null 2>&1; then
        echo "❌ Unexpected API response format. Cannot continue."
        exit 1
    fi

    # Extract READ access users
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')

    if [[ -z "$collaborators" ]]; then
        echo "ℹ No users with READ access found in ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "✅ Users with READ access in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# ---------------- Execute ----------------
helper "$@"

echo "🔎 Checking READ access users in repo: ${REPO_OWNER}/${REPO_NAME}"
list_users_with_read_access
