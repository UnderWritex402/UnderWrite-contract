# underwrite-contract

`agent-registry` — the Soroban contract that tracks which verification
agents TrusTrove's Invoice contract trusts.

## Deployed (Stellar testnet)

```
AGENT_REGISTRY_CONTRACT=CB22R3OJUCQGHZCXH5WAONTURVMSGDIDGIGXA2XQ6UNXDUKYWZKVTER5
```

Admin address: `GAJDJSR2NSIFXVQYP2DULXENALX4276NZHF2WCUCDJQFSO2N7DGI6JFF`

Hand `AGENT_REGISTRY_CONTRACT` to `underwrite-app` and to TrusTrove's
Invoice contract config.

## Development

```sh
# build the contract wasm
stellar contract build

# run the test suite
cargo test

# deploy + initialize on testnet
./scripts/deploy.sh

# smoke test: register an agent and read it back
./scripts/verify.sh <contract-id> <agent-id> <pubkey-hex-65-bytes>
```

> Note (Windows): `cargo test` and `stellar contract build` should be run
> from WSL (or another Linux/macOS environment) rather than natively on
> Windows. The GNU toolchain hits a PE export-ordinal limit building
> soroban's dependency graph as a `cdylib`, and no MSVC linker is
> installed in this environment. Both commands work cleanly under WSL
> against the same repo via `/mnt/c/...`.

## Contract interface

```rust
fn initialize(env: Env, admin: Address);
fn register_agent(env: Env, admin: Address, agent_id: Symbol, pubkey: BytesN<65>);
fn revoke_agent(env: Env, admin: Address, agent_id: Symbol);
fn get_agent(env: Env, agent_id: Symbol) -> Option<AgentInfo>;
```

`register_agent` and `revoke_agent` are admin-only (`require_auth`).
`get_agent` is unauthenticated — this is what TrusTrove's Invoice
contract calls to check a signer's trust status.
