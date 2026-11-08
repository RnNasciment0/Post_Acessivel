import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/accessibilityResult.dart';

Future<AccessibilityResult?> validatePostAPI(String altText, List<XFile> images) async {
  if (images.isEmpty) return null;

  final url = Uri.parse('http://127.0.0.1:8000/validate-post');

  try {
    var request = http.MultipartRequest('POST', url);
    request.fields['alt_text'] = altText;

    // Loop para enviar todas as imagens do carrossel para o backend
    for (var image in images) {
      final bytes = await image.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'images', // A chave 'images' deve bater com o nome no Python
        bytes,
        filename: image.name,
      );
      request.files.add(multipartFile);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AccessibilityResult.fromJson(jsonDecode(response.body));
    } else {
      print("Erro do servidor: ${response.statusCode}");
    }
  } catch (e) {
    print("Erro na requisição: $e");
  }
  return null;
}