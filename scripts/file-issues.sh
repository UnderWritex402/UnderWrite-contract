#!/usr/bin/env bash
set -euo pipefail

REPO="UnderWritex402/UnderWrite-contract"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif [[ $# -ne 0 ]]; then
  echo "usage: $0 [--dry-run]" >&2
  exit 2
fi

create_issue() {
  local title="$1"
  local labels="$2"
  local body
  body="$(cat)"

  if [[ "$DRY_RUN" == "true" ]]; then
    printf '\nTITLE: %s\nLABELS: %s\n%s\n' "$title" "$labels" "$body"
  else
    gh issue create \
      --repo "$REPO" \
      --title "$title" \
      --label "$labels" \
      --body "$body"
  fi
}

create_issue \
  "test(events): assert agent registration event payload" \
  "complexity:low,area:events,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Add a contract test that records `register_agent` events and asserts the exact topics and 65-byte public-key data. The current tests check storage only, so an event regression would pass.

## Why it matters
Indexers need a stable registration event to discover approved verification agents without scanning contract storage.

## Acceptance Criteria
- [ ] A test invokes `register_agent` and asserts the event name, agent ID topic, and public-key data.
- [ ] The test fails when any topic or data field changes.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(events): assert agent revocation event payload" \
  "complexity:low,area:events,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Add a contract test for the event emitted by `revoke_agent`. The current revocation test checks the stored `active` flag but not the event consumed by indexers.

## Why it matters
Consumers need a reliable revocation signal so they stop presenting an inactive agent as trusted.

## Acceptance Criteria
- [ ] A test asserts the revocation event name and agent ID topic.
- [ ] The test asserts the event data shape exactly.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(auth): assert the register unauthorized error" \
  "complexity:low,area:auth,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Replace the generic panic assertion in `register_by_non_admin_fails` with an assertion for contract error `Unauthorized` (`#3`). The current test can pass for an unrelated panic.

## Why it matters
Authorization tests must prove the registry rejects the caller for the intended reason.

## Acceptance Criteria
- [ ] The non-admin registration test asserts contract error `Unauthorized`.
- [ ] The test would fail for `NotInitialized` or another panic.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(auth): assert the revoke unauthorized error" \
  "complexity:low,area:auth,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Make `revoke_by_non_admin_fails` assert contract error `Unauthorized` instead of accepting any panic. Keep the registered-agent setup so the auth check is isolated.

## Why it matters
A broad panic test can hide a state lookup failure and give false confidence in the admin boundary.

## Acceptance Criteria
- [ ] The test asserts contract error `Unauthorized` (`#3`).
- [ ] The test fails if revocation reaches a missing-agent or missing-admin path.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(registry): cover revoked agent reactivation" \
  "complexity:low,area:registry,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Add a test for the documented behavior that `register_agent` can reactivate a revoked agent. Assert the active flag and the stored key after re-registration.

## Why it matters
Reactivation is an admin state transition that TrusTrove relies on when deciding whether an attestation signer is active.

## Acceptance Criteria
- [ ] A revoked agent becomes active after an authorized re-registration.
- [ ] The test asserts whether the old or newly supplied public key is stored.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(registry): define repeated revocation behavior" \
  "complexity:low,area:registry,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Add a test that calls `revoke_agent` twice for the same agent and documents the intended result. The code currently writes `active = false` and emits an event on every call without a test.

## Why it matters
Clear idempotency behavior prevents operators and indexers from interpreting duplicate revocations as distinct state changes.

## Acceptance Criteria
- [ ] The expected second-call result is documented in the test name and assertions.
- [ ] Event and storage behavior for the second call are asserted.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "test(registry): isolate multiple agent records" \
  "complexity:low,area:registry,Stellar Wave,testing,good first issue" <<'BODY'
## Summary
Register two agent IDs with different keys, revoke one, and assert the other record is unchanged. Existing tests exercise one storage key at a time.

## Why it matters
The `DataKey::Agent(Symbol)` mapping must not allow one agent update to affect another signer used by the listing gate.

## Acceptance Criteria
- [ ] Two agents can be registered and read independently.
- [ ] Revoking one agent does not change the other agent's key or active flag.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "fix(tooling): parameterize register-agent deployment values" \
  "complexity:low,area:tooling,Stellar Wave,bug,good first issue" <<'BODY'
## Summary
Replace the contract ID, admin address, identity, and network hardcoded in `scripts/register-agent.sh` with explicit arguments or documented environment variables. Preserve safe testnet defaults only where they cannot target the wrong deployment.

## Why it matters
The current script can silently write to one fixed registry when an operator intends to administer another deployment.

## Acceptance Criteria
- [ ] Contract ID, admin address, source identity, and network are configurable.
- [ ] Missing required values produce a clear usage error before `stellar contract invoke` runs.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Bash, Stellar CLI.
BODY

create_issue \
  "fix(tooling): validate registry script arguments" \
  "complexity:low,area:tooling,Stellar Wave,bug,good first issue" <<'BODY'
## Summary
Validate agent IDs, contract IDs, addresses, and 65-byte uncompressed public-key hex in the registry shell scripts before sending a transaction. The scripts currently pass raw arguments to Stellar CLI.

## Why it matters
Local validation prevents avoidable failed transactions and catches a common mistake: passing a 20-byte EVM address instead of the 65-byte key.

## Acceptance Criteria
- [ ] Invalid key length or prefix is rejected locally with no invocation.
- [ ] Invalid contract, address, or empty agent values produce specific errors.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Bash, Stellar CLI.
BODY

create_issue \
  "docs(storage): document registry TTL assumptions" \
  "complexity:low,area:storage,Stellar Wave,documentation,good first issue" <<'BODY'
## Summary
Document how `AGENT_TTL_THRESHOLD` and `AGENT_TTL_EXTEND_TO` translate from ledgers to time and when entries are extended. Note that reads currently do not refresh TTL.

## Why it matters
Operators need to know when an approved agent record can expire and stop satisfying TrusTrove's listing gate.

## Acceptance Criteria
- [ ] The ledger-count assumptions and extension points are documented from code.
- [ ] The documentation states the operational consequence of an expired record.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Markdown.
BODY

create_issue \
  "feat(events): migrate to typed contract events" \
  "complexity:medium,area:events,Stellar Wave,enhancement" <<'BODY'
## Summary
Replace deprecated `Events::publish` calls with Soroban SDK 27 `#[contractevent]` types. Preserve the existing topic and data layout or document and test a deliberate migration.

## Why it matters
The current calls emit deprecation warnings and an untested wire change can break event indexers.

## Acceptance Criteria
- [ ] Registration and revocation use typed event definitions.
- [ ] Compatibility tests pin the chosen topic and data XDR layout.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "feat(events): emit registry initialization" \
  "complexity:medium,area:events,Stellar Wave,enhancement" <<'BODY'
## Summary
Emit a typed event when `initialize` stores the first admin. Include the admin address in indexed or data fields and add an event test.

## Why it matters
The registry currently has no on-chain event that lets operators or indexers identify the initial administrator without reading raw storage.

## Acceptance Criteria
- [ ] Successful initialization emits one documented event containing the admin address.
- [ ] Failed repeat initialization emits no initialization event.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "fix(registry): validate uncompressed secp256k1 keys" \
  "complexity:medium,area:registry,Stellar Wave,security" <<'BODY'
## Summary
Validate that a registered `BytesN<65>` uses the uncompressed secp256k1 `0x04` prefix and represents an acceptable key for downstream recovery checks. Add negative tests for malformed values.

## Why it matters
The current fixed width accepts any 65 bytes, so an admin mistake can register an agent that can never produce a matching signature.

## Acceptance Criteria
- [ ] Malformed prefixes and invalid key material are rejected with a defined error.
- [ ] A valid uncompressed key still registers and reads back unchanged.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Soroban crypto APIs, Cargo test utilities.
BODY

create_issue \
  "fix(storage): define agent TTL renewal on reads" \
  "complexity:medium,area:storage,Stellar Wave,bug" <<'BODY'
## Summary
Decide and implement how active agent records remain live when they are read but not rewritten for months. `get_agent` currently returns the record without extending its persistent TTL.

## Why it matters
An active signer can disappear from registry storage even while TrusTrove continues to query it, causing valid attestations to fail.

## Acceptance Criteria
- [ ] The renewal policy is documented and implemented in a public or maintenance path.
- [ ] Tests cover reads below and above the renewal threshold.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, persistent storage test utilities.
BODY

create_issue \
  "test(storage): cover TTL threshold and expiry behavior" \
  "complexity:medium,area:storage,Stellar Wave,testing" <<'BODY'
## Summary
Add ledger-sequence tests for the 30-day threshold and 365-day extension used by agent records. Cover registration and revocation writes.

## Why it matters
TTL constants are security-relevant state retention rules and currently have no executable coverage.

## Acceptance Criteria
- [ ] Tests assert the live-until ledger after registration and revocation.
- [ ] Tests cross the threshold and verify whether an extension occurs.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, ledger and storage test utilities.
BODY

create_issue \
  "test(registry): pin public-key replacement semantics" \
  "complexity:medium,area:registry,Stellar Wave,testing" <<'BODY'
## Summary
Add tests for registering an already active agent ID with a different public key. Document whether this operation is supported rotation or should be rejected.

## Why it matters
Today `register_agent` silently replaces the key, which changes who can sign attestations under an existing ID.

## Acceptance Criteria
- [ ] The intended replacement behavior is explicit in contract docs.
- [ ] Tests assert storage and event behavior for a different key.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.
BODY

create_issue \
  "ci(tooling): build the contract Wasm artifact" \
  "complexity:medium,area:tooling,Stellar Wave,enhancement" <<'BODY'
## Summary
Extend CI beyond host checks to build the release Wasm target used by `scripts/deploy.sh`. Upload or inspect the artifact so deployment failures are caught on pull requests.

## Why it matters
Host tests can pass while the no-std Wasm contract fails to compile or produces no deployable artifact.

## Acceptance Criteria
- [ ] CI builds `agent_registry.wasm` for the repository's supported Wasm target.
- [ ] The job reports the artifact path and fails when the Wasm build fails.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Stellar CLI or Rust Wasm target, GitHub Actions.
BODY

create_issue \
  "feat(tooling): generate TypeScript contract bindings" \
  "complexity:medium,area:tooling,Stellar Wave,enhancement" <<'BODY'
## Summary
Add a reproducible command that generates TypeScript bindings from the built agent-registry contract spec. Document how the app should consume and update them.

## Why it matters
Generated bindings reduce drift between the Rust interface and the TypeScript client that reads agent records.

## Acceptance Criteria
- [ ] One documented command regenerates bindings from the current contract.
- [ ] CI detects stale generated output or verifies generation succeeds.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Stellar CLI, TypeScript.
BODY

create_issue \
  "fix(tooling): verify the interface after deployment" \
  "complexity:medium,area:tooling,Stellar Wave,enhancement" <<'BODY'
## Summary
Extend `scripts/deploy.sh` to inspect the deployed contract interface and read initialization state before printing success. Keep all checks on the selected network and contract ID.

## Why it matters
The current script reports success after invocation without proving that the deployed Wasm exposes the expected registry functions.

## Acceptance Criteria
- [ ] Deployment verifies `initialize`, `register_agent`, `revoke_agent`, and `get_agent` are present.
- [ ] A failed verification exits non-zero and does not print the final success message.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Bash, Stellar CLI.
BODY

create_issue \
  "fix(tooling): make the smoke test non-destructive" \
  "complexity:medium,area:tooling,Stellar Wave,bug" <<'BODY'
## Summary
Change `scripts/verify.sh` so a smoke test cannot silently replace a real agent's key. Use a clearly isolated test ID, require explicit confirmation, or restore prior state when safe.

## Why it matters
The script calls `register_agent`, whose current behavior overwrites an existing record and can change the trusted signer on testnet.

## Acceptance Criteria
- [ ] The script detects an existing target agent before writing.
- [ ] The default path cannot replace an existing production-like testnet record.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Bash, Stellar CLI.
BODY

create_issue \
  "fix(auth): require authorization during initialization" \
  "complexity:high,area:auth,Stellar Wave,security,bug" <<'BODY'
## Summary
Require the proposed admin to authorize `initialize` and add tests that use real mocked authorization expectations. The current function stores any supplied address without calling `require_auth`.

## Why it matters
Deployment and initialization are separate transactions, so an unauthenticated initializer can race the intended operator and permanently select another admin.

## Acceptance Criteria
- [ ] `initialize` requires authorization from the stored admin candidate.
- [ ] Tests prove missing or incorrect authorization fails and authorized initialization succeeds.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Soroban auth test utilities.
BODY

create_issue \
  "feat(auth): add controlled admin rotation" \
  "complexity:high,area:auth,Stellar Wave,security,enhancement" <<'BODY'
## Summary
Design and implement an admin rotation function with current-admin authorization and acceptance or authorization by the new admin. Emit a typed rotation event.

## Why it matters
The registry has no recovery path when the admin key must be rotated, so losing or retiring that key can lock all agent administration.

## Acceptance Criteria
- [ ] Only the current admin can initiate rotation and the new address authorizes as defined by the design.
- [ ] Tests cover success, unauthorized callers, same-address rotation, and post-rotation permissions.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Soroban auth and event test utilities.
BODY

create_issue \
  "fix(storage): preserve admin instance state TTL" \
  "complexity:high,area:storage,Stellar Wave,security,bug" <<'BODY'
## Summary
Add and test an instance-storage TTL policy for the admin state. The contract stores `DataKey::Admin` in instance storage but never extends the instance TTL.

## Why it matters
If instance state expires, every admin operation fails with `NotInitialized` and `initialize` may become callable again depending on restored state.

## Acceptance Criteria
- [ ] Admin state receives a documented TTL extension on safe contract paths.
- [ ] Tests cover expiry risk, renewal, and the behavior of `initialize` after ledger advances.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, instance storage and ledger test utilities.
BODY

create_issue \
  "test(tooling): measure registry resource budgets" \
  "complexity:high,area:tooling,Stellar Wave,testing" <<'BODY'
## Summary
Add repeatable budget measurements for `initialize`, `register_agent`, `revoke_agent`, and `get_agent`. Record CPU instructions, memory, and ledger I/O for representative inputs.

## Why it matters
Resource regressions can make registry checks too expensive for the TrusTrove listing transaction even when functional tests pass.

## Acceptance Criteria
- [ ] Measurements cover every public function with fixed fixtures.
- [ ] Baselines and an agreed regression threshold are documented or enforced in CI.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Soroban budget test utilities.
BODY

create_issue \
  "design(registry): define post-MVP multi-agent governance" \
  "complexity:high,area:registry,Stellar Wave,help wanted,enhancement" <<'BODY'
## Summary
Write a discussion-first design for moving from one admin-managed TrusTrove agent to an open multi-agent registry. Cover admission, revocation, key rotation, identity collisions, and governance without changing contract code in the first PR.

## Why it matters
The current single-admin model can store many IDs but does not define who may join or how conflicting and malicious agents are handled.

## Acceptance Criteria
- [ ] The design compares at least two admission and governance models with threat analysis.
- [ ] The proposal defines a migration path that preserves existing agent records and listing checks.

## Tech Stack
Rust 2021, soroban-sdk 27.0.6, Soroban contract design, Markdown.
BODY
