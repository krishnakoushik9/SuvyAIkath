import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class GeminiService {
  static const _modelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const _apiKey = 'AIzaSyBbote2qK2g3sNE3f_YEpia2lg8nMy-OWU';

  Future<List<dynamic>> generateQuiz(String chapterTitle) async {
    final prompt = '''
Generate 10 multiple-choice quiz questions from \"$chapterTitle\" (Class 10 Science - NCERT).
Each question must strictly be a JSON object with keys:
question (string), options (array of 4 strings), correctAnswer (0-3 index), difficulty (basic|intermediate|hard), explanation (string).
Return only a valid JSON array (no markdown, no code fences, no prose).
''';

    final response = await http.post(
      Uri.parse(_modelUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = (data['candidates'] as List<dynamic>?) ?? const [];
      if (candidates.isEmpty) {
        throw Exception('Empty response from Gemini');
      }
      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = (content['parts'] as List<dynamic>? ) ?? const [];
      final text = (parts.isNotEmpty ? parts.first['text'] as String? : null) ?? '';

      // Try direct parse
      try {
        final parsed = jsonDecode(text);
        if (parsed is List) return parsed;
      } catch (_) {}

      // Fallback: extract first JSON array via regex
      final match = RegExp(r"\[\s*\{[\s\S]*\}\s*\]", multiLine: true).firstMatch(text);
      if (match != null) {
        final snippet = match.group(0)!;
        final parsed = jsonDecode(snippet);
        if (parsed is List) return parsed;
      }

      throw Exception('Gemini did not return a valid JSON array.');
    } else {
      throw Exception('Failed to generate quiz: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> loadFallbackQuiz() async {
    final raw = await rootBundle.loadString('assets/fallback_quiz.json');
    final parsed = jsonDecode(raw);
    return (parsed is List) ? parsed : <dynamic>[];
  }
}
