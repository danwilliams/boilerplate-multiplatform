//! Test data.
//! 
//! This library provides shared test data for use in both unit and integration
//! tests.
//! 



//		Global configuration

//	Customisations of the standard linting configuration
#![allow(
	clippy::doc_markdown,
	clippy::exhaustive_enums,
	clippy::exhaustive_structs,
	clippy::expect_used,
	clippy::let_underscore_untyped,
	clippy::missing_assert_message,
	clippy::missing_panics_doc,
	clippy::multiple_crate_versions,
	clippy::must_use_candidate,
	clippy::panic,
	clippy::print_stdout,
	clippy::unwrap_in_result,
	clippy::unwrap_used,
	reason = "Not useful in test functionality"
)]



//		Packages

use rubedo::std::PathExt;
use std::{
	env,
	fs::read_to_string,
	io::{Error as IoError, ErrorKind as IoErrorKind},
	path::{Path, PathBuf},
	sync::OnceLock,
};
use tracing::error;



//		Statics

/// The base path for test data files.
pub static BASE_PATH: OnceLock<PathBuf> = OnceLock::new();



//		Functions

//		load																	
/// Loads a test data file.
/// 
/// This function is sync and not async, so that it is compatible with all
/// callers. As it is used for test data, blocking is not a concern.
/// 
/// # Parameters
/// 
/// * `path` - The path to the file to load.
/// 
/// # Errors
/// 
/// If the file does not exist, or cannot be read, an error will be returned.
/// 
pub fn load<P: AsRef<Path>>(path: P) -> Result<String, IoError> {
	let filename = compute_path(path.as_ref());
	if !filename.exists() {
		error!("Test data file does not exist: {filename:?}");
		return Err(IoError::new(IoErrorKind::NotFound, "Test data file does not exist"));
	}
	read_to_string(filename.clone()).inspect_err(|err| error!("Failed to read test data file {filename:?}: {err}"))
}

//		compute_path															
/// Computes the path for a data file.
/// 
/// This function works out the path for a data file, and restricts it to the
/// base path for test data files. References to current and parent directories
/// will be resolved, i.e. `.` and `..`. Note that the current directory
/// reference `.` remains relative to the actual current working directory, and
/// not the base path. The computed path will be safe to use and guaranteed to
/// be within the test data directory.
/// 
/// # Parameters
///
/// * `path` - The path to compute.
/// 
fn compute_path(path: &Path) -> PathBuf {
	let base_path = BASE_PATH.get_or_init(|| {
		let manifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
		PathBuf::from(manifest_dir).join("..").join("..").join("crates").join("test-data").join("data").normalize()
	});
	if path.is_absolute() || path.is_subjective() {
		path.to_path_buf()
	} else {
		base_path.join(path)
	}.normalize().restrict(base_path)
}


