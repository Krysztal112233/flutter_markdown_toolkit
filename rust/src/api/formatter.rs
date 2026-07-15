use rumdl_lib::config::Config;
use rumdl_lib::fix_coordinator::FixCoordinator;
use rumdl_lib::rules::{all_rules, filter_rules};

/// Format Markdown using rumdl's default rule set.
pub fn format_markdown(markdown: String) -> Result<String, String> {
    let config = Config::default();
    let all = all_rules(&config);
    let rules = filter_rules(&all, &config.global);
    let warnings = rumdl_lib::lint(
        &markdown,
        &rules,
        false,
        config.markdown_flavor(),
        None,
        Some(&config),
    )
    .map_err(|error| error.to_string())?;

    let mut formatted = markdown;
    let result = FixCoordinator::new().apply_fixes_iterative(
        &rules,
        &warnings,
        &mut formatted,
        &config,
        10,
        None,
    )?;

    if result.converged {
        Ok(formatted)
    } else {
        Err(format!(
            "Markdown formatting did not converge; conflicting rules: {}",
            result.conflicting_rules.join(", ")
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::format_markdown;

    #[test]
    fn formats_markdown_with_rumdl() {
        let formatted = format_markdown("#Heading\n\n- first\n- second\n".to_owned()).unwrap();

        assert!(formatted.starts_with("# Heading\n"));
    }
}
