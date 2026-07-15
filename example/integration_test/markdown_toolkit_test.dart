import 'package:flutter_markdown_toolkit/flutter_markdown_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(RustLib.init);

  test('formats and lints Markdown through Rust', () async {
    const markdown = '#Heading\n';

    final diagnostics = await lintMarkdown(markdown: markdown);
    final missingHeadingSpace = diagnostics.singleWhere(
      (diagnostic) => diagnostic.ruleName == 'MD018',
    );
    expect(missingHeadingSpace.line, 1);
    expect(missingHeadingSpace.severity, MarkdownLintSeverity.warning);
    expect(missingHeadingSpace.hasFix, isTrue);

    final formatted = await formatMarkdown(markdown: markdown);
    expect(formatted, startsWith('# Heading'));

    final formattedDiagnostics = await lintMarkdown(markdown: formatted);
    expect(
      formattedDiagnostics.any((diagnostic) => diagnostic.ruleName == 'MD018'),
      isFalse,
    );
  });
}
