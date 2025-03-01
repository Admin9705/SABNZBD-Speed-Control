#!/bin/bash
# SABnzbd Speed Limit Controller for SABnzbd 4.4
#
# According to the 4.4 API documentation, setting the speed limit
# is done via: mode=config&name=speedlimit&value=...
# You can specify the speed in:
#  - Percentage (e.g., value=50 for 50% of your max line speed)
#  - KB/s (append 'K')
#  - MB/s (append 'M')
#
# For ~50 MB/s, we'll use 51200K (50*1024 KB/s).

# --------------------------
# Configuration
# --------------------------
SAB_ADDRESS="http://10.0.0.10:8080"
API_KEY="86a11e19dcb1400a869773be38abc9bf"

# Log file location
LOGFILE="sab_api.log"

# Function to log messages with a timestamp
log_message() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "${timestamp} - ${message}" | tee -a "$LOGFILE"
}

# Define speed limit.
# ~50 MB/s is 51200 KB/s, so we'll do 51200K.
# If you'd rather specify "50M", you can do that as well.
speed_limit="51200K"
log_message "Setting speed limit to ${speed_limit} (which is roughly 50 MB/s)."

# Construct the API URL
# Note: If your SABnzbd is actually served at /sabnzbd, then adjust:
#   ${SAB_ADDRESS}/sabnzbd/api?mode=...
# If it's at the root, just use /api?mode=...
api_url="${SAB_ADDRESS}/api?mode=config&name=speedlimit&apikey=${API_KEY}&value=${speed_limit}"

log_message "Sending request to SABnzbd API: ${api_url}"

# Send the API request using curl and capture both the response body and HTTP status
response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$api_url")
body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

# Log the result based on the HTTP status code
if [ "$status" -eq 200 ]; then
    log_message "Received successful response (HTTP $status). Response body:"
    log_message "${body}"
else
    log_message "Error: Received HTTP status $status. Response body:"
    log_message "${body}"
fi
