// Runs the LIVR test suite against the Rust "livr" crate.
// Comparison mirrors the crate's own test runner (livr-core/tests/common/mod.rs):
// deep equality, key order does not matter, value types matter ('1' is not 1),
// except that numbers compare by value (10 equals 10.0).
use std::env;
use std::fs;
use std::panic::{self, AssertUnwindSafe};
use std::path::Path;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use livr::{Alias, Registry, Validator};
use serde::Serialize;
use serde_json::{Value, json};

#[derive(Serialize)]
struct Failure {
    case: String,
    message: String,
}

#[derive(Serialize)]
struct Report {
    id: &'static str,
    package: &'static str,
    version: Option<String>,
    source: String,
    total: usize,
    passed: usize,
    failures: Vec<Failure>,
    error: Option<String>,
}

const SUITES: [&str; 4] = [
    "positive",
    "negative",
    "aliases_positive",
    "aliases_negative",
];
// LIVR 2.5: schemas that must not build
const SCHEMA_ERRORS: &str = "schema_errors";

fn read_json(dir: &Path, name: &str) -> Option<Value> {
    let text = fs::read_to_string(dir.join(format!("{name}.json"))).ok()?;
    Some(serde_json::from_str(&text).unwrap_or_else(|e| panic!("cannot parse {name}.json: {e}")))
}

fn deep_equal(a: &Value, b: &Value) -> bool {
    match (a, b) {
        (Value::Number(a), Value::Number(b)) => a.as_f64() == b.as_f64(),
        (Value::Array(a), Value::Array(b)) => {
            a.len() == b.len() && a.iter().zip(b).all(|(a, b)| deep_equal(a, b))
        }
        (Value::Object(a), Value::Object(b)) => {
            a.len() == b.len()
                && a.iter()
                    .all(|(key, a)| b.get(key).is_some_and(|b| deep_equal(a, b)))
        }
        (a, b) => a == b,
    }
}

fn show(value: &Value) -> String {
    let str = value.to_string();
    match str.char_indices().nth(300) {
        Some((end, _)) => format!("{}…", &str[..end]),
        None => str,
    }
}

// LIVR 2.5: options.json {"now": "YYYY-MM-DDTHH:MM:SSZ"} is the current time of the bounds
// today, yesterday and tomorrow, given to the builder with `now()` (livr 0.2.0+, the version
// that Cargo.toml requires), like the crate's own tests (livr-core/tests/common/mod.rs)
fn parse_now(now: &str) -> Result<SystemTime, String> {
    let wrong = || format!("options.json: a wrong \"now\": {now}");
    let template = b"0000-00-00T00:00:00Z";
    let valid = now.len() == template.len()
        && now.bytes().zip(template).all(|(c, &t)| {
            if t == b'0' {
                c.is_ascii_digit()
            } else {
                c == t
            }
        });
    if !valid {
        return Err(wrong());
    }
    let number = |range: std::ops::Range<usize>| now[range].parse::<i64>().map_err(|_| wrong());
    let (year, month, day) = (number(0..4)?, number(5..7)?, number(8..10)?);
    // Days since 1970-01-01, "days_from_civil" by Howard Hinnant
    let y = if month <= 2 { year - 1 } else { year };
    let era = y.div_euclid(400);
    let year_of_era = y - era * 400;
    let day_of_year = (153 * (if month > 2 { month - 3 } else { month + 9 }) + 2) / 5 + day - 1;
    let day_of_era = year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year;
    let days = era * 146_097 + day_of_era - 719_468;
    let seconds = days * 86_400 + number(11..13)? * 3600 + number(14..16)? * 60 + number(17..19)?;
    let seconds = u64::try_from(seconds).map_err(|_| wrong())?;
    Ok(UNIX_EPOCH + Duration::from_secs(seconds))
}

// Registers the aliases of the case and builds the validator, which checks the schema
fn build_validator(dir: &Path, rules: &Value) -> Result<Validator, String> {
    let mut registry = Registry::default();
    if let Some(Value::Array(aliases)) = read_json(dir, "aliases") {
        for alias in &aliases {
            let alias = Alias::from_json(alias).map_err(|e| e.to_string())?;
            registry.register_alias(alias).map_err(|e| e.to_string())?;
        }
    }
    let mut builder = Validator::builder(rules).registry(&registry);
    if let Some(now) = read_json(dir, "options").and_then(|options| options.get("now").cloned()) {
        builder = builder.now(parse_now(now.as_str().unwrap_or_default())?);
    }
    builder.build().map_err(|e| e.to_string())
}

// Passes when the aliases or the schema are rejected: an error or a panic
fn run_schema_error_case(dir: &Path) -> Option<String> {
    let rules = read_json(dir, "rules").unwrap_or(Value::Null);
    match panic::catch_unwind(AssertUnwindSafe(|| build_validator(dir, &rules))) {
        Ok(Ok(_)) => Some("expected building the validator to fail".to_string()),
        Ok(Err(_)) | Err(_) => None,
    }
}

fn run_case(suite: &str, dir: &Path) -> Result<Option<String>, String> {
    let rules = read_json(dir, "rules").unwrap_or(Value::Null);
    let input = read_json(dir, "input").unwrap_or(Value::Null);
    let validator = build_validator(dir, &rules)?;
    let result = validator.validate(&input);

    if suite.ends_with("positive") {
        let expected = read_json(dir, "output").unwrap_or(Value::Null);
        return Ok(match result {
            Err(errors) => Some(format!("expected no errors, got {}", show(&json!(errors)))),
            Ok(output) if !deep_equal(&output, &expected) => Some(format!(
                "expected output {}, got {}",
                show(&expected),
                show(&output)
            )),
            Ok(_) => None,
        });
    }

    let expected = read_json(dir, "errors").unwrap_or(Value::Null);
    Ok(match result {
        Ok(output) => Some(format!(
            "expected validation to fail, got output {}",
            show(&output)
        )),
        Err(errors) => {
            let errors = json!(errors);
            (!deep_equal(&errors, &expected))
                .then(|| format!("expected errors {}, got {}", show(&expected), show(&errors)))
        }
    })
}

// A schema error or a panic is an exception, like a thrown error in the other harnesses
fn run_case_catching(suite: &str, dir: &Path) -> Option<String> {
    if suite == SCHEMA_ERRORS {
        return run_schema_error_case(dir);
    }
    match panic::catch_unwind(AssertUnwindSafe(|| run_case(suite, dir))) {
        Ok(Ok(message)) => message,
        Ok(Err(error)) => Some(format!("exception: {error}")),
        Err(payload) => {
            let reason = payload
                .downcast_ref::<String>()
                .cloned()
                .or_else(|| payload.downcast_ref::<&str>().map(|s| (*s).to_string()))
                .unwrap_or_else(|| "panic".to_string());
            Some(format!("exception: {reason}"))
        }
    }
}

// The version of livr in the Cargo.lock that `cargo run` resolved
fn package_version() -> Option<String> {
    let lock = fs::read_to_string("Cargo.lock").ok()?;
    let mut lines = lock.lines();
    while let Some(line) = lines.next() {
        if line.trim() == r#"name = "livr""# {
            let version = lines.next()?.trim().strip_prefix("version = ")?;
            return Some(version.trim_matches('"').to_string());
        }
    }
    None
}

fn main() {
    let suite_dir = env::var("TEST_SUITE_DIR").unwrap_or_else(|_| "../../test_suite".to_string());
    let mut failures = Vec::new();
    let mut total = 0;

    let mut suites = SUITES.to_vec();
    if Path::new(&suite_dir).join(SCHEMA_ERRORS).is_dir() {
        suites.push(SCHEMA_ERRORS);
    }
    for suite in suites {
        let mut names: Vec<String> = fs::read_dir(Path::new(&suite_dir).join(suite))
            .unwrap_or_else(|e| panic!("cannot read {suite_dir}/{suite}: {e}"))
            .filter_map(|entry| entry.ok())
            .filter(|entry| entry.path().is_dir())
            .map(|entry| entry.file_name().to_string_lossy().into_owned())
            .filter(|name| !name.starts_with('.'))
            .collect();
        names.sort();

        for name in names {
            total += 1;
            let dir = Path::new(&suite_dir).join(suite).join(&name);
            if let Some(message) = run_case_catching(suite, &dir) {
                failures.push(Failure {
                    case: format!("{suite}/{name}"),
                    message,
                });
            }
        }
    }

    let result = Report {
        id: "rust",
        package: "livr",
        version: package_version(),
        source: env::var("SOURCE").unwrap_or_else(|_| "crates.io".to_string()),
        total,
        passed: total - failures.len(),
        failures,
        error: None,
    };
    let output = format!(
        "{}\n",
        serde_json::to_string_pretty(&result).expect("result serializes")
    );

    match env::var("OUT_FILE") {
        Ok(path) => fs::write(&path, output).unwrap_or_else(|e| panic!("cannot write {path}: {e}")),
        Err(_) => print!("{output}"),
    }
}
