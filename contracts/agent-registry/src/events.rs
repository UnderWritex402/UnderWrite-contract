use soroban_sdk::{BytesN, Env, Symbol};

pub fn agent_registered(env: &Env, agent_id: Symbol, pubkey: BytesN<65>) {
    env.events()
        .publish((Symbol::new(env, "AgentRegistered"), agent_id), pubkey);
}

pub fn agent_revoked(env: &Env, agent_id: Symbol) {
    env.events()
        .publish((Symbol::new(env, "AgentRevoked"), agent_id), ());
}
