#!/usr/bin/env bash
# Builds agent-registry, deploys it to Stellar testnet, and initializes it
# with the given identity as admin. Prints the deployed contract ID.
#
# Usage: ./scripts/deploy.sh [identity-name]
set -euo pipefail

IDENTITY="${1:-underwrite-admin}"
NETWORK="testnet"
WASM_PATH="target/wasm32-unknown-unknown/release/agent_registry.wasm"

echo "Building agent-registry (release, wasm32-unknown-unknown)..."
stellar contract build

echo "Deploying to $NETWORK as '$IDENTITY'..."
CONTRACT_ID="$(stellar contract deploy \
    --wasm "$WASM_PATH" \
    --source "$IDENTITY" \
    --network "$NETWORK")"

echo "Deployed contract ID: $CONTRACT_ID"

ADMIN_ADDRESS="$(stellar keys address "$IDENTITY")"

echo "Initializing contract with admin: $ADMIN_ADDRESS"
stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$IDENTITY" \
    --network "$NETWORK" \
    -- initialize \
    --admin "$ADMIN_ADDRESS"

echo ""
echo "agent-registry deployed and initialized."
echo "AGENT_REGISTRY_CONTRACT=$CONTRACT_ID"
echo ""
echo "Hand this contract ID to underwrite-app (AGENT_REGISTRY_CONTRACT) and"
echo "to TrusTrove's Invoice contract config."
