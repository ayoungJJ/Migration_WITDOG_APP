import 'package:flutter_test/flutter_test.dart';
import 'package:testing_pet/screens/chatbot/gptAPI.dart';

void main() {
  test('send message test', () async{
    final response = await sendMessage('teeereteastsate');
    print(response);
    expect(response, isNotEmpty);
  });
}