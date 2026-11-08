import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/accessibilityResult.dart';
import '../services/apiService.dart';

class PostValidatorScreen extends StatefulWidget {
  const PostValidatorScreen({super.key});

  @override
  _PostValidatorScreenState createState() => _PostValidatorScreenState();
}

class _PostValidatorScreenState extends State<PostValidatorScreen> {
  final _altTextController = TextEditingController();
  Timer? _debounce;
  AccessibilityResult? _result;
  bool _isLoading = false;

  // Agora usamos uma lista de imagens em vez de apenas uma
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    // pickMultiImage permite selecionar várias fotos de uma vez da galeria
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });

      if (_altTextController.text.isNotEmpty) {
        _onInputChanged(_altTextController.text);
      }
    }
  }

  void _resetApp() {
    setState(() {
      _selectedImages = [];
      _altTextController.clear();
      _result = null;
    });
  }

  void _onInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione as imagens do carrossel primeiro.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await validatePostAPI(value, _selectedImages);
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
      appBar: AppBar(
        title: const Text('Validador de Acessibilidade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetApp,
            tooltip: 'Limpar tudo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.collections),
              label: const Text('Selecionar Carrossel de Imagens'),
            ),
            const SizedBox(height: 16),

            // Exibe as imagens selecionadas numa lista horizontal
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(_selectedImages[index].path, fit: BoxFit.cover, width: 150)
                            : Image.file(File(_selectedImages[index].path), fit: BoxFit.cover, width: 150),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            TextField(
                controller: _altTextController,
                onChanged: _onInputChanged,
                maxLines: 5, // Aumentamos para caber uma legenda maior
                decoration: const InputDecoration(
                labelText: 'Legenda da Postagem (Cole seu rascunho aqui)',
                border: OutlineInputBorder(),
                ),
                ),
            const SizedBox(height: 20),

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Desmonta a lista de resultados do Python e cria uma notificação para cada foto
        ..._result!.carouselAnalysis.map((imgResult) => ListTile(
          leading: Icon(
            imgResult.isValid ? Icons.check_circle : Icons.error,
            color: imgResult.isValid ? Colors.green : Colors.red,
          ),
          title: Text('Contraste: ${imgResult.filename}'),
          subtitle: Text(imgResult.message),
        )),
        const Divider(),
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