# Security Policy

## Supported versions

Underwrite is a pre-release project deployed on Stellar testnet only. No mainnet deployment exists.

| Version | Supported |
| --- | --- |
| `0.1.x` | Yes |
| Earlier versions | No |

## Audit status

Unaudited.

## In scope

- Authorization bypasses in `initialize`, `register_agent`, or `revoke_agent`.
- Incorrect admin checks or agent state transitions, including acceptance of a revoked agent.
- Errors in the stored secp256k1 public key or agent activity state that can break signature verification by a caller.
- Replay, signature-recovery, or domain-separation issues caused by the registry data returned to an attestation verifier.
- Persistent-storage TTL behavior that silently removes agent records.
- Panics, arithmetic errors, or storage behavior that can lock the registry state.

## Out of scope

- Testnet token value.
- Issues in GOAT Network, Stellar, Soroban, or other third-party services themselves.
- Social engineering.
- Denial of service by request volume against public endpoints.
- Findings with no demonstrated impact.

## How to report

Use GitHub private vulnerability reporting through this repository's Security Advisories. Do not open a public issue.

Include affected code, reproduction steps, impact, and any suggested fix. Do not include live secrets or private keys.

## Response timeline

| Stage | Target |
| --- | --- |
| Acknowledge report | Within 3 days |
| Complete initial triage | Within 7 days |
| Set a fix target | Within 14 days after triage |
| Coordinate disclosure | After a fix is available, normally within 30 days |

## Disclosure policy

Disclosure is coordinated with the reporter after a fix is available. Reporters receive credit unless they decline it.
