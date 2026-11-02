# Underwrite Agent Registry

[![CI](https://github.com/UnderWritex402/UnderWrite-contract/actions/workflows/ci.yml/badge.svg)](https://github.com/UnderWritex402/UnderWrite-contract/actions/workflows/ci.yml)
![Network: Stellar testnet](https://img.shields.io/badge/network-Stellar%20testnet-7B61FF)
![Rust 2021](https://img.shields.io/badge/Rust-2021-DEA584?logo=rust)
![Soroban SDK 27.0.6](https://img.shields.io/badge/Soroban%20SDK-27.0.6-4B4BFF)

Underwrite is an invoice verification layer for Stellar. A verification agent checks an invoice, signs a risk signal, and posts it to a Soroban registry. TrusTrove lists an invoice for financing only if a valid attestation exists. This repository contains the agent registry that stores each approved agent's secp256k1 public key and active status.

Testnet only. Unaudited. No mainnet deployment exists. End-to-end flow: in progress.

## How the repositories fit together

| Repository | Role |
| --- | --- |
| [`UnderWrite-contract`](https://github.com/UnderWritex402/UnderWrite-contract) | Soroban agent registry in this repository. |
| [`UnderWrite-app`](https://github.com/UnderWritex402/UnderWrite-app) | Off-chain invoice verification agent and attestation client. |
| [`TrusTrove-contract`](https://github.com/TrusTrove/TrusTrove-contract) | Invoice contract that calls the registry through `submit_attestation`. |

All three repositories are needed for the full flow.

```mermaid
flowchart LR
    A[Underwrite agent] -->|signed risk signal| T[TrusTrove Invoice]
    T -->|get_agent| R[Underwrite registry]
    T -->|valid attestation| L[listing gate]
```

## Testnet deployment

| Component | Network | Contract ID | Status |
| --- | --- | --- | --- |
| Agent registry | Stellar testnet | [`CB22R3OJUCQGHZCXH5WAONTURVMSGDIDGIGXA2XQ6UNXDUKYWZKVTER5`](https://stellar.expert/explorer/testnet/contract/CB22R3OJUCQGHZCXH5WAONTURVMSGDIDGIGXA2XQ6UNXDUKYWZKVTER5) | Contract instance resolved on testnet. |

The registered agent ID `underwrite_v1` was confirmed active with a read-only `get_agent` simulation.

## Maintainers

| Name | Role | GitHub | Telegram |
| --- | --- | --- | --- |
| Fuhad Adesanya | Maintainer | [@K1NGD4VID](https://github.com/K1NGD4VID), [@fadesany](https://github.com/fadesany) | [@K1NGD4VID](https://t.me/K1NGD4VID) |

## Quick Start

Prerequisite: a stable Rust toolchain.

```bash
git clone https://github.com/UnderWritex402/UnderWrite-contract.git
cd UnderWrite-contract
cargo fmt --all -- --check
cargo clippy --workspace --all-targets
cargo test --workspace
```

The current test suite has 7 tests. The commands above were checked from a fresh clone.

## Contract interface

| Function | Parameters | Return | Authorization and errors |
| --- | --- | --- | --- |
| `initialize` | `admin: Address` | `()` | Callable once. A second call panics with `AlreadyInitialized`. |
| `register_agent` | `admin: Address`, `agent_id: Symbol`, `pubkey: BytesN<65>` | `()` | Requires `admin` authorization and the stored admin address. Panics with `NotInitialized` or `Unauthorized`. |
| `revoke_agent` | `admin: Address`, `agent_id: Symbol` | `()` | Requires `admin` authorization. Panics with `NotInitialized` for a missing agent or admin and `Unauthorized` for the wrong admin. |
| `get_agent` | `agent_id: Symbol` | `Option<AgentInfo>` | Public read. Returns `None` for an unknown agent. |


### Storage TTL assumptions

The TTL constants in `contracts/agent-registry/src/lib.rs` are counted in ledgers. They assume a 5-second ledger close time, which gives 17,280 ledgers per day:

| Constant | Value in code | Ledgers | Approximate time |
| --- | --- | --- | --- |
| `AGENT_TTL_THRESHOLD` | `17_280 * 30` | 518,400 | ~30 days |
| `AGENT_TTL_EXTEND_TO` | `17_280 * 365` | 6,307,200 | ~365 days |

If the network closes ledgers faster or slower than every 5 seconds, the real time changes to match.

An agent record's TTL is extended only in `register_agent` and `revoke_agent`, right after the record is written. Each call runs `extend_ttl(&key, AGENT_TTL_THRESHOLD, AGENT_TTL_EXTEND_TO)`. This sets the TTL to ~365 days only when the remaining TTL is below ~30 days. If more TTL is left, the call leaves it unchanged. `get_agent` and other reads do not refresh the TTL. An agent that is only read, for example by TrusTrove during `submit_attestation`, still counts down to expiry. With no further admin writes, a record can expire about 365 days after its last extension.

Operational consequence: once an approved agent record expires, `get_agent` can no longer return it until the entry is restored or the agent is registered again. TrusTrove then cannot confirm the agent as active, its attestations stop satisfying the listing gate, and invoices that rely on that agent cannot be listed. Operators should watch the remaining TTL of each active agent record. Before it expires, they should restore it or extend it, for example by calling `register_agent` again with the same public key.
`AgentInfo` contains `pubkey: BytesN<65>` and `active: bool`. Registration writes an active record. Revocation keeps the record and sets `active` to `false`. Agent records use persistent storage and extend their TTL on registration or revocation.

## Security and license

Read [SECURITY.md](SECURITY.md) before reporting a vulnerability. Audit status: unaudited.

No `LICENSE` file is present. The repository owner must select a license before contributors can rely on reuse terms.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md), then:

1. Pick an unassigned issue with no unmet dependency.
2. Create a branch such as `feat/123-short-name` from `main`.
3. Use Conventional Commits, for example `test(registry): cover revoked agents`.
4. Open a pull request that links the issue, includes tests, updates docs, and passes CI.

## Contributors

[![Contributors](https://contrib.rocks/image?repo=UnderWritex402/UnderWrite-contract)](https://github.com/UnderWritex402/UnderWrite-contract/graphs/contributors)
