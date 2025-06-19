import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final String apiKey;
  final String pdfUrl;
  final String _prefsKey = 'cached_prospectus_base64';

  GeminiService({required this.apiKey, required this.pdfUrl});

  Future<String> queryGemini(String question) async {
    final base64Pdf = await _getCachedBase64Pdf();

    final prompt = '''
      You are an academic assistant. Answer the following question using only the university prospectus provided. Do not use outside information. Be brief, specific and precise to the question asked.

      Question: $question
      ''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "inline_data": {
                "mime_type": "application/pdf",
                "data": base64Pdf,
              }
            },
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception('Gemini API Error: ${response.body}');
    }
  }

  Future<String> _getCachedBase64Pdf() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);

    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Download the PDF
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    final base64Data = base64Encode(response.bodyBytes);
    await prefs.setString(_prefsKey, base64Data);
    return base64Data;
  }
}
