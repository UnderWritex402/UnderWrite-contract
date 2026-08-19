#!/usr/bin/env bash
# Smoke test against a deployed agent-registry: registers one agent and
# confirms get_agent returns it correctly.
#
# Usage: ./scripts/verify.sh <contract-id> <agent-id> <pubkey-hex-65-bytes> [identity-name]
set -euo pipefail

CONTRACT_ID="${1:?usage: verify.sh <contract-id> <agent-id> <pubkey-hex> [identity-name]}"
AGENT_ID="${2:?usage: verify.sh <contract-id> <agent-id> <pubkey-hex> [identity-name]}"
PUBKEY_HEX="${3:?usage: verify.sh <contract-id> <agent-id> <pubkey-hex> [identity-name]}"
IDENTITY="${4:-underwrite-admin}"
NETWORK="testnet"

ADMIN_ADDRESS="$(stellar keys address "$IDENTITY")"

echo "Registering agent '$AGENT_ID' on $CONTRACT_ID..."
stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$IDENTITY" \
    --network "$NETWORK" \
    -- register_agent \
    --admin "$ADMIN_ADDRESS" \
    --agent_id "$AGENT_ID" \
    --pubkey "$PUBKEY_HEX"

echo "Reading it back via get_agent..."
stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$IDENTITY" \
    --network "$NETWORK" \
    -- get_agent \
    --agent_id "$AGENT_ID"
