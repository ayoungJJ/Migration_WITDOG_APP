import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = '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';
const apiUrl = 'https://api.openai.com/v1/completions';

class ChatBotAi extends StatefulWidget {
  const ChatBotAi({Key? key}) : super(key: key);

  @override
  State<ChatBotAi> createState() => _ChatBotAiState();
}

class _ChatBotAiState extends State<ChatBotAi> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("펫봇"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // 새로운 메시지가 맨 위로 오도록 변경
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _messages[index].text,
                    textAlign: _messages[index].isUser
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  subtitle: Text(_messages[index].isUser ? '' : 'GPT'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _sendMessage(_controller.text, true); // 사용자 메시지
                    generateText(_controller.text).then((response) {
                      _sendMessage(response, false); // GPT 메시지
                    });
                    _controller.clear();
                  },
                  child: const Text("Send"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, bool isUser) {
    DateTime currentTime = DateTime.now();
    String period = (currentTime.hour >= 12) ? '오후' : '오전';
    int hour = (currentTime.hour > 12) ? currentTime.hour - 12 : currentTime.hour;
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = currentTime.minute.toString().padLeft(2, '0');
    String formattedTime = "$period $formattedHour:$formattedMinute";

    setState(() {
      _messages.insert(0, ChatMessage("$formattedTime   $text", isUser));
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}

Future<String> generateText(String prompt) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt':
      "What is $prompt? Tell me like you're explaining to an eight-year-old.",
      'max_tokens': 1000,
      'temperature': 0,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0
    }),
  );

  Map<String, dynamic> newresponse =
  jsonDecode(utf8.decode(response.bodyBytes));

  print("Response from GPT: $newresponse");

  return newresponse['choices'][0]['text'];
}