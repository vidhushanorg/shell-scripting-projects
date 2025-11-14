#!/bin/bash
###########################################
# Author: Vidhushan
# About : List users with READ access in a GitHub repository
# Date  : 13.11.2025
###########################################

API_URL="https://api.github.com"

# --- Authentication (set your values here OR export them before running) ---
USERNAME="your_github_username"
TOKEN="your_github_pat_token"

# --- Repository info from command line ---
REPO_OWNER="vidhushanorg"   # Organization fixed as per your requirement
REPO_NAME=$1                # Repo name passed as argument

# ---------------------- Helper Function ----------------------
helper() {
    if [ $# -ne 1 ]; then
        echo "❌ Error: Missing arguments."
        echo "Usage: $0 <repository_name>"
        echo "Example: $0 shell-scripting-projects"
        exit 1
    fi
}

# ---------------------- API GET Function ----------------------
github_api_get() {
    local endpoint="$1"
    curl -s -u "${USERNAME}:${TOKEN}" "${API_URL}/${endpoint}"
}

# ---------------------- Main Logic ----------------------
list_users_with_read_access() {

    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    response="$(github_api_get "$endpoint")"

    # Check for GitHub API errors
    error=$(echo "$response" | jq -r '.message // empty')

    if [[ -n "$error" ]]; then
        echo "❌ GitHub API Error: $error"
        exit 1
    fi

    # Extract users with read access
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')

    if [[ -z "$collaborators" ]]; then
        echo "ℹ No users with READ access found in ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "✅ Users with READ access in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# ---------------------- Execute ----------------------
helper "$@"

echo "🔍 Checking READ access users in: ${REPO_OWNER}/${REPO_NAME}"
list_users_with_read_access
