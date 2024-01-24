import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_pet/model/message.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';

class MessageScreen extends StatefulWidget {
  late KakaoAppUser? appUser; // KakaoAppUser 추가
  final String petIdentity;

  MessageScreen({Key? key, required this.petIdentity, this.appUser})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late TextEditingController _messagesController = TextEditingController();
  Stream<List<Message>> _messagesStream = Stream.empty();
  late String petName;

  @override
  void initState() {
    _loadPetProfileCache(widget.petIdentity);
    _initializeMessagesStream();

    super.initState();
  }

  void _initializeMessagesStream() {
    if (widget.appUser != null) {
      final myUserId = widget.appUser!.user_id;

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((maps) => maps
              .map((map) => Message.fromMap(
                    map,
                    myUserId: myUserId,
                  ))
              .toList());
    } else if (widget.petIdentity != null) {
      final petUserId = widget.petIdentity;

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((maps) => maps
              .map((map) => Message.fromMap(
                    map,
                    myUserId: petUserId,
                  ))
              .toList());
    }
    super.initState();
  }

  Future<void> _sendMessage(String messageController) async {
    print('Sending message: $messageController');

    final response = await supabase.from('messages').upsert([
      {
        'context': messageController,
        'user_id': widget.appUser?.user_id,
        'pet_id': widget.petIdentity,
      }
    ]);

    print('sendMessage response: $response');

    if (response != null && response.error != null) {
      print('메시지 전송 에러: ${response.error}');
    } else {
      print('메시지가 성공적으로 전송되었습니다.');

      // 메시지 전송 후에 프로파일 캐시를 업데이트합니다.
      if (widget.appUser != null) {
        await _loadUserProfileCache(widget.appUser!.user_id);
      } else {
        await _loadPetProfileCache(widget.petIdentity);
      }

      // 스트림을 업데이트합니다.
      _initializeMessagesStream();
    }
  }

  Future<Map<String, dynamic>?> _loadUserProfileCache(String userId) async {
    final profileResponse =
        await supabase.from('Add_UserPet').select().eq('user_id', userId);

    if (profileResponse != null && profileResponse.isNotEmpty) {
      final userProfile = profileResponse[0];

      if (userProfile != null) {
        return {
          'user_name': userProfile['user_name'],
        };
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _loadPetProfileCache(String petIdentity) async {
    final petProfileResponse = await supabase
        .from('Add_UserPet')
        .select()
        .eq('pet_identity', petIdentity);

    print('petProfileResponse $petProfileResponse}');

    if (petProfileResponse != null && petProfileResponse.isNotEmpty) {
      final petProfile = petProfileResponse[0];
      print('petProfile $petProfile');

      if (petProfile != null) {
        return {
          'pet_name': petProfile['pet_name'],
          'pet_images': petProfile['pet_images'], // pet_images 추가
        };
      }
    }

    return null;
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
                //print('widget.appUser: ${widget.appUser!.user_id}');
                print('widget.petIdentity: ${widget.petIdentity}');

                print('snapshop ${snapshot}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error loading data: ${snapshot.error}');
                  return Center(
                    child: Text('Error loading data: ${snapshot.error}'),
                  );
                }

                // snapshot.data가 null이면 빈 리스트로 초기화
                final messages = snapshot.data ?? [];

                // 메세지 리스트가 비어있는지 확인
                if (messages.isNotEmpty) {
                  print('Data load context : $messages');

                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      _loadPetProfileCache(message.context);

                      return _ChatBubble(
                        message: message,
                      );
                    },
                  );
                } else {
                  // Handle the case when messages list is empty
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
          /*
                  // Check if snapshot.data is not null
                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  print('Data load context : $messages');

                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      _loadPetProfileCache(message.context);

                      return _ChatBubble(
                        message: message,
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading data: ${snapshot.error}'),
                  );
                } else {
                  // Handle the case when snapshot.data is null
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messagesController,
                    decoration: InputDecoration(hintText: '메시지 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final messageText = _messagesController.text;
                    await _sendMessage(messageText);
                    _messagesController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessageWithUser(
      KakaoAppUser appUser, String _messageController) async {
    print('Sending message with user: $_messageController');
    print('appUser.userid : ${appUser.user_id}');

    final response = await supabase.from('messages').insert([
      {
        'context': _messageController,
        'user_id': appUser.user_id,
      }
    ]);

    print('sendMessageWithUser response: $response');

    if (response != null && response.error != null) {
      print('메시지 전송 에러: ${response.error}');
    } else {
      print('메시지가 성공적으로 전송되었습니다.');

      // 메시지 전송 후에 사용자 프로파일 캐시를 업데이트합니다.
      await _loadUserProfileCache(appUser.user_id);

      // 스트림을 업데이트합니다.
      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('pet_id', widget.petIdentity)
          .order('created_at')
          .map((maps) => maps
              .map((map) => Message.fromMap(map, myUserId: appUser.user_id))
              .toList());
    }
  }

  Widget _ChatBubble({required Message message}) {
    final isCurrentUserMessage = widget.appUser != null
        ? message.userId == widget.appUser?.user_id &&
        message.petId == widget.petIdentity :
    message.userId == widget.appUser?.user_id ||
        message.petId == widget.petIdentity;

    String formattedTime = DateFormat('hh:mm a').format(message.createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCurrentUserMessage ? 8.0 : 80.0,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment: isCurrentUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _loadPetProfileCache(message.petId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                // 데이터가 없어도 채팅은 표시되어야 함
                return Column(
                  crossAxisAlignment: isCurrentUserMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(formattedTime),
                        SizedBox(width: 10,),
                        Text(message.context),
                      ],
                    ),
                  ],
                );
              } else {
                Map<String, dynamic> petProfileData = snapshot.data!;
                return Column(
                  crossAxisAlignment: isCurrentUserMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildImageFromBase64(petProfileData['pet_images']),
                        SizedBox(width: 8),
                        Text(message.context),
                        SizedBox(width: 10,),
                        Text(formattedTime),
                      ],
                    ),

                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildImageFromBase64(String base64String) {
  if (base64String.isEmpty) {
    return Container(); // 빈 컨테이너를 반환하거나 다른 기본 이미지를 설정할 수 있습니다.
  }

  Uint8List bytes = base64.decode(base64String);
  return Image.memory(bytes, width: 50, height: 50);
}
