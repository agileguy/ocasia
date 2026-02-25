#!/bin/bash

# This script is designed to be run by the system cron daemon.
# It fetches package download stats and sends them to a Telegram chat via an OpenClaw message command.

set -euo pipefail

# --- Configuration ---
# The absolute path to the OpenClaw CLI, sourced from the user's fnm setup
OPENCLAW_CLI="/Users/dan/.local/share/fnm/node-versions/v24.14.0/installation/bin/openclaw"

# The command for the globally installed pypi-cli tool
# Assumes it's in the standard path for npm global installs. We will add the path just in case.
export PATH="$HOME/.npm-global/bin:$PATH"
PYPI_COMMAND="pypi"


# The Telegram Chat ID to send the message to
TELEGRAM_CHAT_ID="8575237058"

# List of your packages
PYPI_PACKAGES=("rally-tui" "logview-ag" "sequel-ag")
NPM_PACKAGES=(
    "@agileguy/cf-cli" "@agileguy/ghost-cli" "@agileguy/nitfy"
    "bsky-cli" "goalert-cli" "posterboy" "pypkg-cli" "resend-email-cli"
)

# --- Logic ---

# Function to fetch PyPI stats using the fixed global CLI
get_pypi_stats() {
    local pkg_name="$1"
    local json_output
    json_output=$($PYPI_COMMAND stats "$pkg_name" --json)
    
    # The API returns daily data for the last month. We can calculate the rest.
    local last_month
    last_month=$(echo "$json_output" | jq '.data.total_downloads')
    local last_week
    last_week=$(echo "$json_output" | jq '[.data.python_versions[].downloads] | add') # Placeholder, needs better logic
    local last_day
    last_day=$(echo "$json_output" | jq '[.data.python_versions[] | select(.date == "'$(date -v-1d +%Y-%m-%d)'") | .downloads] | add // 0')

    # Summing downloads from the last 7 days for an accurate weekly count
    last_week=0
    for i in {1..7}; do
        day_downloads=$(echo "$json_output" | jq '[.data.python_versions[] | select(.date == "'$(date -v-${i}d +%Y-%m-%d)'") | .downloads] | add // 0')
        last_week=$((last_week + day_downloads))
    done

    echo "$pkg_name|$last_day|$last_week|$last_month"
}

# Function to fetch npm stats
get_npm_stats() {
    local pkg_name="$1"
    local encoded_pkg_name
    encoded_pkg_name=$(printf %s "$pkg_name" | jq -sRr @uri)
    
    local day_url="https://api.npmjs.org/downloads/point/last-day/$encoded_pkg_name"
    local week_url="https://api.npmjs.org/downloads/point/last-week/$encoded_pkg_name"
    local month_url="https://api.npmjs.org/downloads/point/last-month/$encoded_pkg_name"
    
    local last_day
    last_day=$(curl -s "$day_url" | jq '.downloads // 0')
    local last_week
    last_week=$(curl -s "$week_url" | jq '.downloads // 0')
    local last_month
    last_month=$(curl -s "$month_url" | jq '.downloads // 0')
    
    echo "$pkg_name|$last_day|$last_week|$last_month"
}

# --- Execution ---

MESSAGE="📦 *Daily Package Download Report*\n\n"

MESSAGE+="*PyPI Packages*:\n"
MESSAGE+="\`\`\`\n"
MESSAGE+="Package          | Day | Week | Month\n"
MESSAGE+="------------------|-----|------|-------\n"
for pkg in "${PYPI_PACKAGES[@]}"; do
    STATS=$(get_pypi_stats "$pkg")
    IFS='|' read -r name day week month <<< "$STATS"
    printf -v line "%-18s| %-3s | %-4s | %-5s\n" "$name" "$day" "$week" "$month"
    MESSAGE+="$line"
done
MESSAGE+="\`\`\`\n"

MESSAGE+="\n*NPM Packages*:\n"
MESSAGE+="\`\`\`\n"
MESSAGE+="Package               | Day | Week | Month\n"
MESSAGE+="---------------------|-----|------|-------\n"
for pkg in "${NPM_PACKAGES[@]}"; do
    STATS=$(get_npm_stats "$pkg")
    if [ -n "$STATS" ]; then
        IFS='|' read -r name day week month <<< "$STATS"
        printf -v line "%-21s| %-3s | %-4s | %-5s\n" "$name" "$day" "$week" "$month"
        MESSAGE+="$line"
    fi
done
MESSAGE+="\`\`\`"

# Send the message using the OpenClaw CLI
"$OPENCLAW_CLI" message send --channel telegram --target "$TELEGRAM_CHAT_ID" --message "$MESSAGE"
