import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:testing_pet/model/message.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';

class MessageScreen extends StatefulWidget {
  final KakaoAppUser appUser; // KakaoAppUser 추가
  final String petId;
  const MessageScreen({Key? key, required this.appUser, required this.petId}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Stream<List<Message>> _messagesStream;

  Map<String, dynamic> _profileCache = {};

  @override
  void initState() {
    final myUserId = widget.appUser.user_id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('pet_id', widget.petId) // 해당 반려동물의 메시지만 가져오도록 수정
        .order('created_at')
        .map((maps) =>
        maps.map((map) => Message.fromMap(map: map, myUserId: myUserId)).toList());
    super.initState();
  }

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
              stream: _messagesStream,
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
                    reverse: true, // 최신 메시지가 맨 위에 오도록 수정
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
    } else {
      // 메시지 전송 후에 스트림을 업데이트합니다.
      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('pet_id', widget.petId) // 해당 반려동물의 메시지만 가져오도록 수정
          .order('created_at')
          .map((maps) =>
          maps.map((map) => Message.fromMap(map: map, myUserId: widget.appUser.user_id)).toList());
    }
  }

  void _loadProfileCache(String userId) async {
    // Get user profile from your data source (e.g., Supabase)
    final profileResponse = await supabase
        .from('Add_UserPet')
        .select()
        .eq('user_id', userId)
        .single();

    print(profileResponse);

    if (profileResponse.error != null) {
      print('프로필 가져오기 에러: ${profileResponse.error}');
      return;
    }

    final userProfile = profileResponse.data;

    // Decode base64 encoded image
    String base64Image = userProfile['pet_images'];
    List<int> bytes = base64.decode(base64Image);

    _profileCache[userId] = {
      'pet_name': userProfile['pet_name'],
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
          Text(profile['pet_name'].toString() ?? '사용자 이름이 없음',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(message.content),
          Text(message.createdAt.toString()), // Indicate creation time, change format as needed
        ],
      ),
    );
  }
}
