# Changelog

All notable changes to this project are documented in this file.

## 0.1.0 - 2026-11-02

### Added

- Soroban agent registry contract for administrator-controlled agent registration and revocation.
- Active-agent lookup used by the TrusTrove Invoice contract to verify UnderWrite attestations.
- Persistent agent records, authorization checks, registry events, and deployment scripts.
- Testnet deployment documentation and Stellar Expert links.
- CI, contributor documentation, security policy, Apache-2.0 license, and issue backlog.
- Seven contract tests covering initialization, registration, lookup, revocation, authorization, and unknown agents.

### Deployed testnet contract

- Agent registry: `CB22R3OJUCQGHZCXH5WAONTURVMSGDIDGIGXA2XQ6UNXDUKYWZKVTER5`
- Registered agent id: `underwrite_v1`

### Known limitations

- Testnet only and unaudited.
- The companion app has not recorded an accepted end-to-end attestation and financing-listing transaction.
