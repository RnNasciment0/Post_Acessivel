import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accessibility_result.dart';

Future<AccessibilityResult?> validatePostAPI(String bgColor, String textColor, String altText) async {
  // 10.0.2.2 é o endereço que o emulador Android usa para aceder à porta 8000 do Windows
  final url = Uri.parse('http://127.0.0.1:8000/validate-post');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "background_color": bgColor,
        "text_color": textColor,
        "alt_text": altText,
      }),
    );

    if (response.statusCode == 200) {
      return AccessibilityResult.fromJson(jsonDecode(response.body));
    }
  } catch (e) {
    print("Erro na requisição: $e");
  }
  return null;
}