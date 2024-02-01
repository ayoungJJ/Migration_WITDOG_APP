import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:testing_pet/model/message.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';

class MessageScreen extends StatefulWidget {
  late KakaoAppUser? appUser;
  final String petIdentity;

  MessageScreen({Key? key, required this.petIdentity, this.appUser})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late TextEditingController _messagesController = TextEditingController();
  late Stream<List<Message>> _messagesStream = Stream.empty();
  late String petName;
  Map<String, dynamic> petProfileResponse = {};



  @override
  void initState() {
    _initializeMessagesStream();
    _loadPetProfileCache(widget.petIdentity);
    super.initState();
  }

  void _initializeMessagesStream() {
    if (widget.appUser != null) {
      final myUserId = widget.appUser?.user_id;

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((maps) =>
          maps.map((map) => Message.fromMap(map: map, myUserId: myUserId))
              .toList());

      _messagesStream.listen((data) {
        print('Received data from stream: $data');
      });
    } else {
      final myPetId = widget.petIdentity;

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((maps) =>
          maps.map((map) => Message.fromMap(map: map, myUserId: myPetId))
              .toList());
      _messagesStream.listen((data) {
        print('Received data from stream: $data');
      });
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
        _loadPetProfileCache(widget.petIdentity);
      }

      // 스트림을 업데이트합니다.
      _initializeMessagesStream();
    }
  }

  Future<Map<String, dynamic>?> _loadUserProfileCache(String userId) async {
    final profileResponse =
    await supabase.from('Kakao_User').select().eq('user_id', userId);

    print('user profile response : $profileResponse');

    if (profileResponse != null && profileResponse.isNotEmpty) {
      final userProfile = profileResponse[0];

      if (userProfile != null) {
        return {
          'nickname': userProfile['nickname'],
        };
      }
    }

    return null;
  }

  void _loadPetProfileCache(String petIdentity) async {
    var petProfileResponseList = await supabase
        .from('Add_UserPet')
        .select()
        .eq('pet_identity', '681665');

    print('petProfileResponse $petProfileResponseList');

    if (petProfileResponseList != null && petProfileResponseList.isNotEmpty) {
      // 첫 번째 항목에서 프로필 정보를 추출하여 업데이트
      var firstPetProfile = petProfileResponseList[0];
      setState(() {
        petProfileResponse = {
          'pet_name': firstPetProfile['pet_name'],
          'pet_images': firstPetProfile['pet_images'],
        };
      });
    } else {
      print('Pet profile not found or empty.');
    }
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
              builder: (BuildContext context,
                  AsyncSnapshot<List<Message>> snapshot) {
                print('context data : $context');
                final messages = snapshot.data ?? [];


                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, index) {
                    final message = messages[index];

                    // 현재 사용자의 메시지 여부 확인
                    bool isCurrentUserMessage = widget.appUser != null
                        ? message.userId == widget.appUser?.user_id &&
                        message.petId == widget.petIdentity
                        : message.userId == widget.appUser?.user_id ||
                        message.petId == widget.petIdentity;

                    // 현재 메시지의 시간을 포맷팅
                    String formattedTime = DateFormat('hh:mm a').format(
                        message.createdAt);


                    return Align(
                      alignment: isCurrentUserMessage
                          ? Alignment.centerRight // 변경: 현재 사용자의 메시지는 오른쪽 정렬
                          : Alignment.centerLeft, // 변경: 반려동물의 메시지는 왼쪽 정렬
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: isCurrentUserMessage
                            ? ChatBubble(
                          clipper: ChatBubbleClipper1(
                              type: BubbleType.sendBubble),
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(top: 20),
                          backGroundColor: Colors.blue,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: _loadUserProfileCache(
                                      message.userId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      // 데이터가 없어도 채팅은 표시되어야 함
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(formattedTime),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(message.context),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      Map<String,
                                          dynamic> profileData = snapshot.data!;
                                      String senderName = profileData['nickname'] ??
                                          'Unknown User';

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end,
                                        children: [
                                          Row(
                                            children: [
                                              Text('${senderName}: ${message
                                                  .context}'),
                                              SizedBox(
                                                width: 10,
                                              ),
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
                          ),
                        )
                            : ChatBubble(

                          clipper: ChatBubbleClipper1(
                              type: BubbleType.receiverBubble),
                          backGroundColor: Color(0xffE7E7ED),
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _buildImageFromBase64(petProfileResponse['pet_images']?.toString() ?? ''),
                                Text(
                                  message.context != null ? message.context : '',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  formattedTime,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                    controller: _messagesController,
                    decoration: InputDecoration(hintText: '메시지 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_upward_sharp),
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

  Widget _buildImageFromBase64(String base64String) {
    if (base64String == null || base64String.isEmpty) {
      print('Empty or null base64 string.');
      return Container();
    }

    // 나머지 코드는 동일하게 유지
    try {
      Uint8List bytes = base64.decode(base64String);
      print('Decoded bytes for image: $bytes');
      return Image.memory(bytes, width: 50, height: 50);
    } catch (e) {
      print('Error decoding Base64 string: $e');
      return Container();
    }
  }
}
