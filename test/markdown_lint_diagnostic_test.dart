import 'package:flutter_markdown_toolkit/flutter_markdown_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownLintDiagnostic', () {
    const diagnostic = MarkdownLintDiagnostic(
      ruleName: 'MD018',
      message: 'No space after hash on atx heading',
      line: 1,
      column: 1,
      endLine: 1,
      endColumn: 8,
      severity: MarkdownLintSeverity.warning,
      hasFix: true,
    );

    test('stores all fields', () {
      expect(diagnostic.ruleName, 'MD018');
      expect(diagnostic.message, 'No space after hash on atx heading');
      expect(diagnostic.line, 1);
      expect(diagnostic.column, 1);
      expect(diagnostic.endLine, 1);
      expect(diagnostic.endColumn, 8);
      expect(diagnostic.severity, MarkdownLintSeverity.warning);
      expect(diagnostic.hasFix, isTrue);
    });

    test('implements value equality', () {
      const other = MarkdownLintDiagnostic(
        ruleName: 'MD018',
        message: 'No space after hash on atx heading',
        line: 1,
        column: 1,
        endLine: 1,
        endColumn: 8,
        severity: MarkdownLintSeverity.warning,
        hasFix: true,
      );

      expect(other, equals(diagnostic));
      expect(other.hashCode, diagnostic.hashCode);
    });

    test('distinguishes different diagnostics', () {
      const different = MarkdownLintDiagnostic(
        ruleName: 'MD019',
        message: 'Multiple spaces after hash on atx heading',
        line: 2,
        column: 1,
        endLine: 2,
        endColumn: 9,
        severity: MarkdownLintSeverity.error,
        hasFix: false,
      );

      expect(different, isNot(equals(diagnostic)));
    });
  });

  test('MarkdownLintSeverity exposes all levels', () {
    expect(
      MarkdownLintSeverity.values,
      containsAll([
        MarkdownLintSeverity.error,
        MarkdownLintSeverity.warning,
        MarkdownLintSeverity.info,
      ]),
    );
  });
}
