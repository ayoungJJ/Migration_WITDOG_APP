import 'dart:convert';

import 'package:http/http.dart' as http;

const apiUrl = "https://api.openai.com/v1/chat/completions";
const apiKey = "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";


Future<String> sendMessage(String prompt) async {

  final response = await http.post(Uri.parse(apiUrl),
    headers: {
    'Content-Type' : 'application/json',
    'Authorization': 'Bearer $apiKey',
  },
    body: jsonEncode({
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'system',
        'content':
        'You are a poetic assistant, skilled in explaining complex programming concepts with creative flair.'
      },
      {'role': 'user', 'content': prompt}
    ]
  }),);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

    final String reply =
        data['choices'][0]['message']['content'] ?? "응답을 받지 못했습니다.";
    return reply;
  } else {
    final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception(data['error']['message'] ?? "응답을 받지 못했습니다.");
  }
}
