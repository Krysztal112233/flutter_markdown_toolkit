import 'package:flutter/material.dart';
import 'package:flutter_markdown_toolkit/flutter_markdown_toolkit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Toolkit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MarkdownToolkitPage(),
    );
  }
}

class MarkdownToolkitPage extends StatefulWidget {
  const MarkdownToolkitPage({super.key});

  @override
  State<MarkdownToolkitPage> createState() => _MarkdownToolkitPageState();
}

class _MarkdownToolkitPageState extends State<MarkdownToolkitPage> {
  final _markdownController = TextEditingController(
    text: '#Heading\n\n- first item\n- second item\n',
  );

  List<MarkdownLintDiagnostic> _diagnostics = const [];
  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  Future<void> _lint() async {
    await _run(() async {
      final diagnostics = await lintMarkdown(
        markdown: _markdownController.text,
      );
      if (!mounted) return;
      setState(() => _diagnostics = diagnostics);
    });
  }

  Future<void> _format() async {
    await _run(() async {
      final formatted = await formatMarkdown(
        markdown: _markdownController.text,
      );
      final diagnostics = await lintMarkdown(markdown: formatted);
      if (!mounted) return;
      setState(() {
        _markdownController.text = formatted;
        _diagnostics = diagnostics;
      });
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _isWorking = true;
      _error = null;
    });

    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markdown Toolkit')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _markdownController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Markdown',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 10,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _isWorking ? null : _format,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Format'),
              ),
              OutlinedButton.icon(
                onPressed: _isWorking ? null : _lint,
                icon: const Icon(Icons.rule),
                label: const Text('Lint'),
              ),
              if (_isWorking) const CircularProgressIndicator(),
            ],
          ),
          if (_error case final error?) ...[
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Diagnostics (${_diagnostics.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_diagnostics.isEmpty)
            const Text(
              'No lint diagnostics. Press Lint to inspect the Markdown.',
            ),
          for (final diagnostic in _diagnostics)
            Card(
              child: ListTile(
                title: Text('${diagnostic.ruleName}: ${diagnostic.message}'),
                subtitle: Text(
                  'Line ${diagnostic.line}, column ${diagnostic.column}'
                  ' · ${diagnostic.severity.name}'
                  '${diagnostic.hasFix ? ' · fix available' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
