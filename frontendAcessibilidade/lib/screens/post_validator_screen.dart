import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/accessibility_result.dart';
import '../services/api_service.dart';

class PostValidatorScreen extends StatefulWidget {
  const PostValidatorScreen({super.key});

  @override
  State<PostValidatorScreen> createState() => _PostValidatorScreenState();
}

class _PostValidatorScreenState extends State<PostValidatorScreen> {
  final _altTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  Timer? _debounce;
  AccessibilityResult? _result;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      // Se o utilizador já tiver escrito algum texto, valida a nova imagem automaticamente
      if (_altTextController.text.isNotEmpty) {
        _onInputChanged(_altTextController.text);
      }
    }
  }

  void _onInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Mostra um aviso se a pessoa tentar digitar sem ter escolhido uma imagem
    if (_selectedImage == null) {
      if (value.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleciona uma imagem primeiro.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Chama a API passando o texto e o ficheiro da imagem
      final result = await validatePostAPI(value, _selectedImage);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
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
      appBar: AppBar(
        title: const Text('Validador de Acessibilidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botão e preview da imagem
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_selectedImage == null ? 'Selecionar Imagem' : 'Alterar Imagem'),
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: kIsWeb
                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                      : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 20),

            // Campo de Texto Alternativo
            TextField(
              controller: _altTextController,
              onChanged: _onInputChanged,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Texto Alternativo (Alt Text)',
                hintText: 'Descreva a imagem para pessoas com deficiência visual...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Carregamento ou resultado
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_result != null)
              _buildFeedbackPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPanel() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
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
            const Divider(),
            ListTile(
              leading: Icon(
                _result!.isAltTextValid ? Icons.check_circle : Icons.warning,
                color: _result!.isAltTextValid ? Colors.green : Colors.orange,
              ),
              title: const Text('Texto Alternativo'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_result!.altTextIssues.isEmpty)
                    const Text('O texto alternativo está adequado!')
                  else
                    ..._result!.altTextIssues.map((issue) => Text('• $issue')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
