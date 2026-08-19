use soroban_sdk::{contracttype, BytesN, Symbol};

/// Storage keys for the agent-registry contract.
#[contracttype]
#[derive(Clone)]
pub enum DataKey {
    /// The contract admin address. Instance storage.
    Admin,
    /// agent_id -> AgentInfo. Persistent storage.
    Agent(Symbol),
}

/// Registered agent record.
///
/// `pubkey` is the agent's uncompressed secp256k1 public key, used to
/// recover the signer of an attestation on TrusTrove's Invoice contract.
/// `active` gates whether the agent is currently trusted; revoked agents
/// keep their record for audit history instead of being deleted.
#[contracttype]
#[derive(Clone, Debug, PartialEq)]
pub struct AgentInfo {
    pub pubkey: BytesN<65>,
    pub active: bool,
}
