# Contract issue backlog

These items were not filed in the first batch of 25 issues.

## `integration(registry): reject attestations from revoked agents`

Labels: `complexity:high`, `area:registry`, `Stellar Wave`, `testing`

## Summary

Add a cross-contract test that registers an agent, accepts one correctly signed attestation, revokes the agent, and then rejects another attestation from the same key. Use the real registry and Invoice contract interfaces.

## Why it matters

Registry revocation matters only if the TrusTrove listing path checks the active flag for every attestation.

## Acceptance Criteria

- [ ] A registered active agent's attestation reaches the expected Invoice contract path.
- [ ] The same key is rejected after `revoke_agent`, with the exact contract error asserted.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, TrusTrove Invoice contract test client.

## Depends on

TrusTrove Part 1D `submit_attestation` must be landed with a reusable test contract interface.

---

## `integration(registry): verify signer recovery against stored keys`

Labels: `complexity:high`, `area:registry`, `Stellar Wave`, `testing`

## Summary

Add a cross-contract fixture that signs the real attestation payload, recovers its secp256k1 public key, and compares it with the registry record. Cover a wrong key and a malformed signature.

## Why it matters

The registry stores a 65-byte key specifically for the Invoice contract's signature check, but this repository cannot prove the two implementations agree by itself.

## Acceptance Criteria

- [ ] A valid signature from the registered key is accepted.
- [ ] A different key and malformed recovery ID are rejected.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, secp256k1 fixtures, TrusTrove Invoice contract test client.

## Depends on

TrusTrove Part 1D `submit_attestation` and its payload type must be available to the integration test.

---

## `integration(storage): test expired agents at the listing gate`

Labels: `complexity:high`, `area:storage`, `Stellar Wave`, `testing`

## Summary

Advance the ledger until an agent record expires and assert the real Invoice listing or attestation path rejects that signer. Repeat after a supported TTL renewal.

## Why it matters

An expiry test inside the registry shows storage behavior, but only the consumer test proves how expiry affects invoice financing.

## Acceptance Criteria

- [ ] An expired registry record is treated as an untrusted or missing agent by the Invoice contract.
- [ ] A renewed record remains usable through the same ledger range.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, ledger test utilities, TrusTrove Invoice contract test client.

## Depends on

TrusTrove Part 1D `submit_attestation` and listing-gate test fixtures must be available.

---

## `fix(registry): distinguish missing agents from uninitialized state`

Labels: `complexity:medium`, `area:registry`, `Stellar Wave`, `enhancement`

## Summary

Add a dedicated `AgentNotFound` error and use it when `revoke_agent` cannot load the target. `NotInitialized` currently describes both a missing admin and a missing agent.

## Why it matters

Operators need accurate failures to distinguish deployment state from a typo or stale agent ID.

## Acceptance Criteria

- [ ] Missing-admin and missing-agent paths return different documented errors.
- [ ] Tests pin both error codes.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, Cargo test utilities.

---

## `test(tooling): add shell-script regression tests`

Labels: `complexity:medium`, `area:tooling`, `Stellar Wave`, `testing`

## Summary

Add automated tests for usage errors, argument validation, command construction, and failed Stellar CLI calls in `scripts/`. Use an injected or temporary fake CLI rather than live keys.

## Why it matters

The deployment scripts can change registry state, but none of their safe-failure paths are covered today.

## Acceptance Criteria

- [ ] Tests cover every script's missing and malformed argument paths.
- [ ] Tests assert the generated Stellar CLI arguments without using a live identity.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, Bash test tooling, Stellar CLI command fixtures.

---

## `ci(tooling): record release Wasm provenance`

Labels: `complexity:medium`, `area:tooling`, `Stellar Wave`, `enhancement`

## Summary

Produce a deterministic release Wasm checksum and record the source commit, Rust version, and contract spec alongside the CI artifact. Document how a deployed hash maps back to a build.

## Why it matters

Reviewers need to connect a testnet contract ID to the exact source and toolchain that produced its Wasm.

## Acceptance Criteria

- [ ] CI publishes the Wasm SHA-256 checksum and build metadata.
- [ ] Release documentation explains how to compare the artifact with a deployment.

## Tech Stack

Rust 2021, soroban-sdk 27.0.6, GitHub Actions, checksum tooling.
