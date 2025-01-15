#!/bin/bash

# Read the Azure credentials file
CREDENTIALS_FILE="$HOME/.azure/credentials"

# Check if the file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Credentials file not found: $CREDENTIALS_FILE"
  exit 1
fi

# Read the credentials and set environment variables
while IFS='=' read -r key value; do
  case "$key" in
    subscription_id) export AZURE_SUBSCRIPTION_ID="$value" ;;
    client_id) export AZURE_CLIENT_ID="$value" ;;
    secret) export AZURE_SECRET="$value" ;;
    tenant) export AZURE_TENANT="$value" ;;
  esac
done < <(grep -v '^\[' "$CREDENTIALS_FILE")

# Print the environment variables to verify
echo "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "AZURE_SECRET=$AZURE_SECRET"
echo "AZURE_TENANT=$AZURE_TENANT"