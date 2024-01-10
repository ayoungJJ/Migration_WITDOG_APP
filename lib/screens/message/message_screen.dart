import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing_pet/model/message.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';

class MessageScreen extends StatefulWidget {
  final String petId;
  final KakaoAppUser appUser;


  MessageScreen({Key? key, required this.petId, required this.appUser}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic> _profileCache = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: () async* {
                final response = await supabase
                    .from('messages')
                    .select()
                    .eq('pet_id', widget.petId)
                    .order('created_at', ascending: true);

                print('streamMessage : ${response}');

                final data = response as List<dynamic>;

                print('streamData : ${data}');

                yield data
                    .map((item) =>
                    Message.fromMap(map: item, myUserId: '1234'))
                    .toList();
              }(),
              builder: (context, AsyncSnapshot<List<Message>> snapshot) {
                print('snapshop ${snapshot}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Check if snapshot.data is not null
                if (snapshot.data != null) {
                  final messages = snapshot.data as List<Message>;
                  print('Data: $messages');

                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      _loadProfileCache(message.userId);
                      return _ChatBubble(
                        message: message,
                        profile: _profileCache[message.userId],
                      );
                    },
                  );
                } else {
                  // Handle the case when snapshot.data is null
                  return const Center(child: Text('No data available'));
                }
              },

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: '메시지 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final messageText = _messageController.text;
                    await _sendMessage(messageText);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String messageText) async {
    final response = await supabase.from('messages').upsert([
      {
        'pet_id': widget.petId,
        'content': messageText,
        'user_id': widget.appUser.user_id,
      }
    ]);

    print('sendMessage line : ${response}');

    if (response != null && response.error != null) {
      print('메시지 전송 에러: ${response.error}');
    }
  }

  void _loadProfileCache(String petId) async {
    // Get dog profile from your data source (e.g., Supabase)
    final profileResponse = await supabase
        .from('Add_UserPet')
        .select()
        .eq('pet_name', petId)
        .single();

    print(profileResponse);

    if (profileResponse.error != null) {
      print('프로필 가져오기 에러: ${profileResponse.error}');
      return;
    }

    final dogProfile = profileResponse.data;

    // Decode base64 encoded image
    String base64Image = dogProfile['pet_images'];
    List<int> bytes = base64.decode(base64Image);

    _profileCache[petId] = {
      'pet_name': dogProfile['pet_name'],
      'pet_images': Image.memory(Uint8List.fromList(bytes)),
    };
  }

  Widget _ChatBubble({required Message message, required dynamic profile}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Text(profile['pet_name'].toString() ?? '사용자 이름이 없음',
              style: TextStyle(fontWeight: FontWeight.bold)),
          */
          Text(message.content),
          Text(message.createdAt.toString()), // Indicate creation time, change format as needed
        ],
      ),
    );
  }

}
