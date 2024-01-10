import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/message/message_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final KakaoAppUser appUser; // 생성자에 추가된 매개변수

  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet, required this.appUser}) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}


class _PetDetailScreenState extends State<PetDetailScreen> {

  late Image backgroundImage;
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;



  @override
  void initState() {
    super.initState();

    String base64Image = widget.pet['pet_images'];
    List<int> bytes = base64.decode(base64Image);
    backgroundImage = Image.memory(Uint8List.fromList(bytes));

    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();


  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    String getSelectedPetId() {
      // 여기에 사용자가 선택한 반려동물의 petId를 가져오는 로직을 추가
      // 예를 들어, 반려동물 목록 화면에서 선택한 반려동물 정보를 사용하거나,
      // 다른 방식으로 사용자에게 선택한 반려동물을 확인하는 방법을 구현하세요.

      // 임시로 '123'을 반환하도록 하였습니다. 실제로는 사용자가 선택한 반려동물의 petId를 반환해야 합니다.
      return '1234';
    }
    @override
    void dispose() {
      _localRenderer.dispose();
      _remoteRenderer.dispose();
    }

    void initRenderers() async {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
    }


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.pet['pet_name'] + ' Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: backgroundImage.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(63.0),
                  topRight: Radius.circular(63.0),
                ),
              ),
              child: Stack(
                children: [
                  // 반려동물 이름을 표시하는 Text 위젯 추가
                  Positioned(
                    top: 17,
                    left: 0,
                    right: 0,
                    child: Text(
                      widget.pet['pet_name'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // 가운데 정렬
                    ),
                  ),
                  // 추가 정보를 표시하는 Text 위젯 추가
                  Positioned(
                    top: 65,
                    left: 0,
                    right: 0,
                    child: Text(
                      '${widget.pet['pet_breed']} / ${widget.pet['pet_gender']} ${widget.pet['pet_age']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center, // 가운데 정렬
                    ),
                  ),
                  Positioned(
                    top: 101,
                    left: 0,
                    right: screenWidth * 0.6,
                    child: GestureDetector(
                      onTap: () {
                        // Chat 화면으로 이동하는 코드 추가
                        String selectedPetId = getSelectedPetId();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MessageScreen(petId: selectedPetId ,appUser: widget.appUser)),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.green,
                            ),
                            width: 88,
                            height: 88,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/images/bottom_bar_icon/white_chat.svg'),
                                SizedBox(height: 4),  // 이미지와 텍스트 사이의 간격 조절
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 101,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          color: Color(0xffF4BF6E),
                          child: Text(
                            'Chat2',  // 작은 따옴표를 올바르게 사용해야 합니다.
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.center, // 가운데 정렬
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 101,
                    left: screenWidth * 0.6,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          color: Colors.green,
                          child: Text(
                            'Chat3',  // 작은 따옴표를 올바르게 사용해야 합니다.
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.center, // 가운데 정렬
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50.0, // 원하는 위치로 조정
            left: 20.0, // 원하는 위치로 조정
            child: Text(
              'text',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}