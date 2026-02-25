#!/bin/bash

# This script is designed to be run by the system cron daemon.
# It fetches package download stats and sends them to a Telegram chat via an OpenClaw message command.

set -euo pipefail

# --- Configuration ---
# Absolute path to the bun executable, installed via bun.sh/install
BUN_PATH="/Users/dan/.bun/bin/bun"

# The absolute path to the OpenClaw CLI
# This is necessary because cron runs with a minimal environment
OPENCLAW_CLI="/Users/dan/.local/share/fnm/node-versions/v24.14.0/installation/bin/openclaw"

# The Telegram Chat ID to send the message to
TELEGRAM_CHAT_ID="8575237058"

# Absolute path to the pypi-cli tool's source entrypoint
PYPI_CLI_PATH="/Users/dan/repos/pypi-cli/src/index.ts"

# List of your packages
PYPI_PACKAGES=("rally-tui" "logview-ag" "sequel-ag")
NPM_PACKAGES=(
    "@agileguy/cf-cli" "@agileguy/ghost-cli" "@agileguy/nitfy" 
    "bsky-cli" "goalert-cli" "posterboy" "pypkg-cli" "resend-email-cli"
)

# --- Logic ---

# Function to fetch PyPI stats
# Note: This has to parse text because the tool's JSON output is broken, even after v1.1.0.
# It approximates daily/weekly stats from the monthly total.
get_pypi_stats() {
    local pkg_name="$1"
    local output
    output=$("$BUN_PATH" run "$PYPI_CLI_PATH" stats "$pkg_name")
    local last_month
    last_month=$(echo "$output" | grep "Total Downloads" | sed -n 's/.*Total Downloads (last 30 days): \([0-9]*\).*/\1/p' | tr -d '[:space:]')
    
    local last_day=0
    local last_week=0

    if [[ -n "$last_month" && "$last_month" -gt 0 ]]; then
        last_day=$((last_month / 30))
        last_week=$((last_month / 4))
    else
        last_month=0
    fi
    echo "$pkg_name|$last_day|$last_week|$last_month"
}

# Function to fetch npm stats
get_npm_stats() {
    local pkg_name="$1"
    # URL encode the package name for scoped packages
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

MESSAGE+="*PyPI Packages (approximated)*:\n"
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
    IFS='|' read -r name day week month <<< "$STATS"
    printf -v line "%-21s| %-3s | %-4s | %-5s\n" "$name" "$day" "$week" "$month"
    MESSAGE+="$line"
done
MESSAGE+="\`\`\`"

# Send the message using the OpenClaw CLI
"$OPENCLAW_CLI" message send --channel telegram --target "$TELEGRAM_CHAT_ID" --message "$MESSAGE"
