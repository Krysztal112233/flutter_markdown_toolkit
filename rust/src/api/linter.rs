use rumdl_lib::config::Config;
use rumdl_lib::rule::{LintWarning, Severity};
use rumdl_lib::rules::{all_rules, filter_rules};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MarkdownLintDiagnostic {
    pub rule_name: String,
    pub message: String,
    pub line: u32,
    pub column: u32,
    pub end_line: u32,
    pub end_column: u32,
    pub severity: MarkdownLintSeverity,
    pub has_fix: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MarkdownLintSeverity {
    Error,
    Warning,
    Info,
}

/// Lint Markdown using rumdl's default rule set.
pub fn lint_markdown(markdown: String) -> Result<Vec<MarkdownLintDiagnostic>, String> {
    let config = Config::default();
    let all = all_rules(&config);
    let rules = filter_rules(&all, &config.global);

    rumdl_lib::lint(
        &markdown,
        &rules,
        false,
        config.markdown_flavor(),
        None,
        Some(&config),
    )
    .map(|warnings| warnings.into_iter().map(Into::into).collect())
    .map_err(|error| error.to_string())
}

impl From<LintWarning> for MarkdownLintDiagnostic {
    fn from(warning: LintWarning) -> Self {
        Self {
            rule_name: warning.rule_name.unwrap_or_default(),
            message: warning.message,
            line: saturating_u32(warning.line),
            column: saturating_u32(warning.column),
            end_line: saturating_u32(warning.end_line),
            end_column: saturating_u32(warning.end_column),
            severity: warning.severity.into(),
            has_fix: warning.fix.is_some(),
        }
    }
}

impl From<Severity> for MarkdownLintSeverity {
    fn from(severity: Severity) -> Self {
        match severity {
            Severity::Error => Self::Error,
            Severity::Warning => Self::Warning,
            Severity::Info => Self::Info,
        }
    }
}

fn saturating_u32(value: usize) -> u32 {
    u32::try_from(value).unwrap_or(u32::MAX)
}

#[cfg(test)]
mod tests {
    use super::{lint_markdown, MarkdownLintSeverity};

    #[test]
    fn returns_structured_rumdl_diagnostics() {
        let diagnostics = lint_markdown("#Heading\n".to_owned()).unwrap();
        let missing_space = diagnostics
            .iter()
            .find(|diagnostic| diagnostic.rule_name == "MD018")
            .expect("MD018 should report a missing heading space");

        assert_eq!(missing_space.line, 1);
        assert_eq!(missing_space.severity, MarkdownLintSeverity::Warning);
        assert!(missing_space.has_fix);
    }
}
