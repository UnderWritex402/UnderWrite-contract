#!/usr/bin/env bash
set -euo pipefail

AGENT_ID="${1:?Usage: register-agent.sh <agent_id> <pubkey_hex>}"
PUBKEY="${2:?Usage: register-agent.sh <agent_id> <pubkey_hex>}"

stellar contract invoke \
  --id CB22R3OJUCQGHZCXH5WAONTURVMSGDIDGIGXA2XQ6UNXDUKYWZKVTER5 \
  --source underwrite-admin \
  --network testnet \
  -- \
  register_agent \
  --admin GAJDJSR2NSIFXVQYP2DULXENALX4276NZHF2WCUCDJQFSO2N7DGI6JFF \
  --agent_id "$AGENT_ID" \
  --pubkey "$PUBKEY"
