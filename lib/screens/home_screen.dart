import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testing_pet/model/PetList.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/chatbot/gptAPI.dart';
import 'package:testing_pet/screens/pet_add/pet_add_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_detail_screen.dart';
import 'package:testing_pet/screens/record/count_down_screen.dart';
import 'package:testing_pet/utils/constants.dart';

import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final KakaoAppUser appUser; // 생성자에 추가된 매개변수

  HomeScreen({required this.appUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState(appUser: appUser);
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Map<String, dynamic>> dataList;
  late KakaoAppUser appUser;
  List<PetList> _petList = [];

  // 생성자를 통해 필요한 데이터를 받도록 변경
  _HomeScreenState({required this.appUser}) {
    dataList = [];
  }

  @override
  void initState() {
    super.initState();
    _loadPetList();
  }

  void _loadPetList() async {
    final response = await supabase
        .from('Add_UserPet') // 여기에 테이블 이름을 입력하세요.
        .select()
        .like('user_id', '${widget.appUser.user_id}%');
    print('response : $response');

    // 반려동물 데이터를 파싱하고 _petList 업데이트
    final List<dynamic>? data = response as List<dynamic>?;
    print(data);

    if (data != null && data.isNotEmpty) {
      final petList = data.map((petMap) => PetList.fromMap(petMap)).toList();
      print('Response Data: $data');
      print('petList : $petList');

      setState(() {
        _petList = petList;
      });
    } else {
      print('Error: No data received from Supabase or data is empty');
    }
  }

  // 반려동물 리스트 아이템 위젯을 생성하는 함수
  Widget _buildPetListItem(int index) {
    PetList pet = _petList[index];

    // Check if petImages is null or empty
    if (pet.petImages == null || pet.petImages.isEmpty) {
      // Return a ListTile with default information and a placeholder image
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 112,
                color: Colors.white,
                child: ListTile(
                  title: Text(pet.petName),
                  subtitle: Text(
                    'Age: ${pet.petAge}, ${pet.petBreed}, ${pet.petFavorite}, ${pet.petGender}',
                  ),
                  leading: Container(
                    width: 92.0,
                    height: 92.0,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SvgPicture.asset(
                          'assets/images/profile_images/default_dog_profile.svg'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Decode the base64 encoded image and convert it to bytes.
    List<int> imageBytes;
    try {
      imageBytes = base64.decode(pet.petImages);
    } catch (e) {
      print('Error decoding image: $e');
      // If decoding fails, return a ListTile with default information and a placeholder image
      return Container(
        height: 112,
        color: Colors.white,
        child: ListTile(
          title: Text(pet.petName),
          subtitle: Text(
              'Age: ${pet.petAge}, ${pet.petBreed}, ${pet.petFavorite}, ${pet.petGender}'),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 92.0,
              height: 92.0,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SvgPicture.asset(
                    'assets/images/profile_images/default_dog_profile.svg'),
              ),
            ),
          ),
        ),
      );
    }

    // Create an image widget from bytes
    Image petImage = Image.memory(
      Uint8List.fromList(imageBytes),
      width: 92.0,
      height: 92.0,
      fit: BoxFit.fill,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: 112,
              color: Colors.white,
              child: ListTile(
                title: Text(pet.petName),
                subtitle: Text(
                  'Age: ${pet.petAge}, ${pet.petBreed}, ${pet.petFavorite}, ${pet.petGender}',
                ),
                leading: Container(
                  width: 92.0,
                  height: 92.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: petImage,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  final List<Widget> _pages = [
    Container(), // 첫 번째 탭 화면
    Container(), // 두 번째 탭 화면
    Container(),
    Container(), // 네 번째 탭 화면
  ];

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.appUser.user_id}');
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '내 반려동물',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetAddScreen(appUser: appUser),
                  ),
                );
              },
              child: Text(
                '동물 추가',
                style: TextStyle(
                  color: Color(0xFF0094FF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFF0F0F0),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '즐겨찾기',
                  style: TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                // Separator line
                color: Color(0xffE0E0E0), // Same color as text
                thickness: 1.0, // 선의 두께
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '반려동물 리스트',
                  style: TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Container(
              child: Column(
                children: List.generate(
                  _petList.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetDetailScreen(
                                  pet: _petList.length > 0
                                      ? _petList[0].toMap()
                                      : {}),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets
                              .zero, // 버튼 패딩을 0으로 설정하여 내용물을 꽉 채우도록 합니다.
                        ),
                        child: Container(
                          height: 112.0, // 항목의 높이를 고정 값으로 설정
                          child: _buildPetListItem(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 186,
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '반려동물 리스트가 없습니다\n추가해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff7C7C7C),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PetAddScreen(appUser: appUser),
                          ),
                        );
                      },
                      child: Text(
                        '반려동물 추가하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff16C077),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        fixedSize: Size.fromHeight(56),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotAi()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF5FD3A2),
                Color(0xFF75B59A),
              ],
              stops: [0.0, 1.0],
              begin: Alignment(0.21, 0),
              end: Alignment(0.87, 0.88),
            ),
          ),
          child: Center(
            child:
                SvgPicture.asset('assets/images/bottom_bar_icon/chatbot.svg'),
          ),
        ),
      ),
      // TODO : 차후에 추가 할 부분
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CountDownScreen(
                  onCountDownComplete: () {
                    // 카운트다운 완료 시 실행될 코드 추가
                    // 예: 특정 동작 수행 또는 다른 페이지로 이동
                  },
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon:
                SvgPicture.asset('assets/images/bottom_bar_icon/dog_list.svg'),
            activeIcon: SvgPicture.asset(
              'assets/images/bottom_bar_icon/color_dog_list.svg',
            ),
            label: '반려견목록',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/bottom_bar_icon/chat.svg'),
            activeIcon: SvgPicture.asset(
              'assets/images/bottom_bar_icon/color_chat.svg',
            ),
            label: '대화목록',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/bottom_bar_icon/mic.svg'),
            activeIcon: SvgPicture.asset(
              'assets/images/bottom_bar_icon/color_mic.svg',
            ),
            label: '문장입력',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
                'assets/images/bottom_bar_icon/color_user_profile.svg'),
            activeIcon: SvgPicture.asset(
              'assets/images/bottom_bar_icon/user_profile.svg',
            ),
            label: '내정보',
          ),
        ],
        selectedItemColor: const Color(0xFF01DF80),
        showUnselectedLabels: true,
      ),
    );
  }
}
