import 'dart:async';
import 'package:flutter/material.dart';
import '../models/accessibility_result.dart';
import '../services/api_service.dart';

class PostValidatorScreen extends StatefulWidget {
  const PostValidatorScreen({super.key});

  @override
  State<PostValidatorScreen> createState() => _PostValidatorScreenState();
}

class _PostValidatorScreenState extends State<PostValidatorScreen> {
  final _altTextController = TextEditingController();
  final String _bgColor = "#FFFFFF";
  final String _textColor = "#757575"; // Cinza claro forçado para testar erro de contraste

  Timer? _debounce;
  AccessibilityResult? _result;
  bool _isLoading = false;

  void _onInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await validatePostAPI(_bgColor, _textColor, value);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _altTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validador de Acessibilidade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _altTextController,
              onChanged: _onInputChanged,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Texto Alternativo (Alt Text)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_result != null)
              _buildFeedbackPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            _result!.isContrastValid ? Icons.check_circle : Icons.error,
            color: _result!.isContrastValid ? Colors.green : Colors.red,
          ),
          title: const Text('Contraste de Cores'),
          subtitle: Text(_result!.contrastMessage),
        ),
        ListTile(
          leading: Icon(
            _result!.isAltTextValid ? Icons.check_circle : Icons.warning,
            color: _result!.isAltTextValid ? Colors.green : Colors.orange,
          ),
          title: const Text('Texto Alternativo'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _result!.altTextIssues
                .map((issue) => Text('• $issue'))
                .toList(),
          ),
        ),
      ],
    );
  }
}