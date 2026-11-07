import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/accessibility_result.dart';

Future<AccessibilityResult?> validatePostAPI(String altText, XFile? imageFile) async {
  // Se não houver imagem selecionada, não faz a requisição
  if (imageFile == null) return null;

  // 10.0.2.2 para emulador Android, 127.0.0.1 para Web / Windows / Desktop
  final String baseUrl = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      ? 'http://10.0.2.2:8000/validate-post'
      : 'http://127.0.0.1:8000/validate-post';

  final url = Uri.parse(baseUrl);

  try {
    // Cria uma requisição Multipart (específica para envio de ficheiros/formulários)
    var request = http.MultipartRequest('POST', url);

    // 1. Adiciona o texto alternativo digitado
    request.fields['alt_text'] = altText;

    // 2. Lê a imagem e anexa à requisição
    final bytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: imageFile.name,
    );
    request.files.add(multipartFile);

    // 3. Envia para o backend e aguarda a resposta
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AccessibilityResult.fromJson(jsonDecode(response.body));
    } else {
      debugPrint("Erro do servidor: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Erro na requisição: $e");
  }
  return null;
}
