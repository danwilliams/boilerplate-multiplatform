//! Boilerplate application library for use with UniFFI

/// Greet the user
/// 
/// # Parameters
/// 
/// * `name` - The name of the user to greet
/// 
pub fn greet(name: &str) -> String {
	format!("Hello {name} from Rust!")
}


