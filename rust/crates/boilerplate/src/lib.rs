//! Boilerplate application library for use with UniFFI

uniffi::setup_scaffolding!();

/// Greet the user
/// 
/// # Parameters
/// 
/// * `name` - The name of the user to greet
/// 
#[uniffi::export]
pub fn greet(name: &str) -> String {
	format!("Hello {name} from Rust!")
}


