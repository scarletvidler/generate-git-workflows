#!/bin/bash
# Usage: ./generate-workflow.sh "Turtle UK" "develop,feature" "US,EU,all"

set -e

# Ensure the target directory exists
OUTPUT_DIR=".github/workflows"
mkdir -p "$OUTPUT_DIR"

# --- Function to create a workflow file ---
create_workflow() {
  local NAME="$1"
  local BRANCH="$2"
  local MARKET="$3"

  # Trim spaces
  NAME=$(echo "$NAME" | xargs)
  BRANCH=$(echo "$BRANCH" | xargs)
  MARKET=$(echo "$MARKET" | xargs)

  # Derived variables
  BRANCH_UPPER=$(echo "$BRANCH" | tr '[:lower:]' '[:upper:]')
  NAME_SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

  # Optional market slug
  MARKET_SLUG=""
  if [[ "$MARKET" != "all" ]]; then
    MARKET_SLUG="-$(echo "$MARKET" | tr '[:upper:]' '[:lower:]')"
  fi
  MARKET_UPPER=$(echo "$MARKET" | tr '[:lower:]' '[:upper:]')

  FILENAME="${OUTPUT_DIR}/${BRANCH}-${NAME_SLUG}${MARKET_SLUG}.yml"

  # Generate the workflow YAML
  cat > "$FILENAME" <<EOF
# This is a basic workflow to help you get started with Action

name: Sync - ${BRANCH_UPPER} ${NAME} ${MARKET_UPPER}

on:
  push:
    branches:
      - ${BRANCH}
    paths-ignore:
      - "templates/*.json"
      - "config/*.json"
      - "locales/*.json"
      - "sections/*.json"
  pull_request:
    branches:
      - ${BRANCH}
    paths-ignore:
      - "templates/*.json"
      - "config/*.json"
      - "locales/*.json"
      - "sections/*.json"

  workflow_dispatch:

jobs:
  store-sync:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Shopify Multi Store Deployer ${NAME}
        uses: jamiemccleave/shopify-multi-store-deployer@v2.0
        with:
          from_branch: "${BRANCH}"
          to_branch: "stores/${BRANCH}-${NAME_SLUG}${MARKET_SLUG}"
          user_name: "GitHub Action : Multi Store Merge Bot"
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

  echo "✅ Workflow generated: $FILENAME"
}


# --- Main script ---
NAME="$1"
BRANCHES="$2"
MARKETS="$3"

if [ -z "$NAME" ] || [ -z "$BRANCHES" ] || [ -z "$MARKETS" ]; then
  echo "Usage: $0 \"Name\" \"Branch1,Branch2,...\" \"Market1,Market2,... (use 'all' if none)\""
  exit 1
fi

# Split comma-separated inputs into arrays
IFS=',' read -ra BRANCH_ARRAY <<< "$BRANCHES"
IFS=',' read -ra MARKET_ARRAY <<< "$MARKETS"

# If markets include "all", just use "all"
if [[ " ${MARKET_ARRAY[@]} " =~ " all " ]]; then
  MARKET_ARRAY=("all")
fi

# Loop through branches and markets
for BRANCH in "${BRANCH_ARRAY[@]}"; do
  for MARKET in "${MARKET_ARRAY[@]}"; do
    echo "Generating workflow for branch: $BRANCH, market: $MARKET"
    create_workflow "$NAME" "$BRANCH" "$MARKET"
  done
done
