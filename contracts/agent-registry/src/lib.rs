#![no_std]

mod errors;
mod events;
mod types;

#[cfg(test)]
mod test;

use errors::Error;
use soroban_sdk::{contract, contractimpl, panic_with_error, Address, BytesN, Env, Symbol};
use types::{AgentInfo, DataKey};

// Persistent entries are bumped to keep at least ~30 days of TTL headroom,
// extended out to ~ a year on write, matching typical Soroban registry usage.
const AGENT_TTL_THRESHOLD: u32 = 17_280 * 30; // ~30 days of ledgers
const AGENT_TTL_EXTEND_TO: u32 = 17_280 * 365; // ~365 days of ledgers

#[contract]
pub struct AgentRegistry;

#[contractimpl]
impl AgentRegistry {
    /// Sets the contract admin. Callable exactly once.
    pub fn initialize(env: Env, admin: Address) {
        if env.storage().instance().has(&DataKey::Admin) {
            panic_with_error!(&env, Error::AlreadyInitialized);
        }
        env.storage().instance().set(&DataKey::Admin, &admin);
    }

    /// Registers (or re-registers as active) an agent's signing pubkey.
    /// Admin-only.
    pub fn register_agent(env: Env, admin: Address, agent_id: Symbol, pubkey: BytesN<65>) {
        admin.require_auth();
        Self::require_admin(&env, &admin);

        let key = DataKey::Agent(agent_id.clone());
        let info = AgentInfo {
            pubkey: pubkey.clone(),
            active: true,
        };
        env.storage().persistent().set(&key, &info);
        env.storage().persistent().extend_ttl(
            &key,
            AGENT_TTL_THRESHOLD,
            AGENT_TTL_EXTEND_TO,
        );

        events::agent_registered(&env, agent_id, pubkey);
    }

    /// Marks an agent inactive without deleting its record. Admin-only.
    pub fn revoke_agent(env: Env, admin: Address, agent_id: Symbol) {
        admin.require_auth();
        Self::require_admin(&env, &admin);

        let key = DataKey::Agent(agent_id.clone());
        let mut info: AgentInfo = env
            .storage()
            .persistent()
            .get(&key)
            .unwrap_or_else(|| panic_with_error!(&env, Error::NotInitialized));

        info.active = false;
        env.storage().persistent().set(&key, &info);
        env.storage().persistent().extend_ttl(
            &key,
            AGENT_TTL_THRESHOLD,
            AGENT_TTL_EXTEND_TO,
        );

        events::agent_revoked(&env, agent_id);
    }

    /// Reads an agent's record. Callable by anyone, no auth required.
    pub fn get_agent(env: Env, agent_id: Symbol) -> Option<AgentInfo> {
        env.storage().persistent().get(&DataKey::Agent(agent_id))
    }

    fn require_admin(env: &Env, caller: &Address) {
        let admin: Address = env
            .storage()
            .instance()
            .get(&DataKey::Admin)
            .unwrap_or_else(|| panic_with_error!(env, Error::NotInitialized));

        if admin != *caller {
            panic_with_error!(env, Error::Unauthorized);
        }
    }
}
