#![cfg(test)]

use super::{AgentRegistry, AgentRegistryClient};
use soroban_sdk::{testutils::Address as _, Address, BytesN, Env, Symbol};

fn setup() -> (Env, AgentRegistryClient<'static>, Address) {
    let env = Env::default();
    env.mock_all_auths();

    let contract_id = env.register(AgentRegistry, ());
    let client = AgentRegistryClient::new(&env, &contract_id);

    let admin = Address::generate(&env);
    client.initialize(&admin);

    (env, client, admin)
}

fn dummy_pubkey(env: &Env, byte: u8) -> BytesN<65> {
    BytesN::from_array(env, &[byte; 65])
}

#[test]
fn initialize_then_register_and_get() {
    let (env, client, admin) = setup();

    let agent_id = Symbol::new(&env, "underwrite");
    let pubkey = dummy_pubkey(&env, 1);

    client.register_agent(&admin, &agent_id, &pubkey);

    let info = client.get_agent(&agent_id).unwrap();
    assert_eq!(info.pubkey, pubkey);
    assert!(info.active);
}

#[test]
#[should_panic(expected = "Error(Contract, #2)")]
fn initialize_twice_panics() {
    let (_env, client, admin) = setup();
    client.initialize(&admin);
}

#[test]
#[should_panic]
fn register_by_non_admin_fails() {
    let (env, client, _admin) = setup();

    let not_admin = Address::generate(&env);
    let agent_id = Symbol::new(&env, "underwrite");
    let pubkey = dummy_pubkey(&env, 2);

    client.register_agent(&not_admin, &agent_id, &pubkey);
}

#[test]
fn revoke_then_get_agent_shows_inactive() {
    let (env, client, admin) = setup();

    let agent_id = Symbol::new(&env, "underwrite");
    let pubkey = dummy_pubkey(&env, 3);

    client.register_agent(&admin, &agent_id, &pubkey);
    client.revoke_agent(&admin, &agent_id);

    let info = client.get_agent(&agent_id).unwrap();
    assert!(!info.active);
    // record is preserved, not deleted
    assert_eq!(info.pubkey, pubkey);
}

#[test]
fn get_agent_on_unknown_id_returns_none() {
    let (env, client, _admin) = setup();
    let unknown = Symbol::new(&env, "ghost");
    assert_eq!(client.get_agent(&unknown), None);
}

#[test]
#[should_panic]
fn revoke_by_non_admin_fails() {
    let (env, client, admin) = setup();

    let agent_id = Symbol::new(&env, "underwrite");
    let pubkey = dummy_pubkey(&env, 4);
    client.register_agent(&admin, &agent_id, &pubkey);

    let not_admin = Address::generate(&env);
    client.revoke_agent(&not_admin, &agent_id);
}

#[test]
#[should_panic]
fn revoke_unknown_agent_fails() {
    let (env, client, admin) = setup();
    let unknown = Symbol::new(&env, "ghost");
    client.revoke_agent(&admin, &unknown);
}
