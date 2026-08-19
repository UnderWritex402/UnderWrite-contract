#!/usr/bin/env bash
# One-time local setup: creates (and funds, if needed) the admin identity
# used to deploy and administer agent-registry on Stellar testnet.
#
# Usage: ./scripts/setup-testnet.sh [identity-name]
set -euo pipefail

IDENTITY="${1:-underwrite-admin}"

if stellar keys address "$IDENTITY" >/dev/null 2>&1; then
    echo "Identity '$IDENTITY' already exists."
else
    echo "Generating identity '$IDENTITY' and funding via friendbot..."
    stellar keys generate "$IDENTITY" --network testnet --fund
fi

ADDRESS="$(stellar keys address "$IDENTITY")"
echo "Admin address: $ADDRESS"
echo "Network: testnet"
