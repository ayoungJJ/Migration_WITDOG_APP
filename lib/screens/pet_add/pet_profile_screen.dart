import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/model/pet_model.dart';
import 'package:intl/intl.dart';

class PetProfileScreen extends StatefulWidget {
  final KakaoAppUser? appUser;

  const PetProfileScreen({Key? key, this.appUser}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late PetModel _petModel;
  Map<String, dynamic>? petProfileData;

  String get formattedTime {
    return petProfileData != null
        ? DateFormat('yyyy년   MM월   dd일').format(DateTime.parse(
        petProfileData!['created_date'] ?? DateTime.now().toString()))
        : '';
  }

  @override
  void initState() {
    super.initState();
    _petModel = PetModel();
    _loadPetData();
    _loadAndProcessPetData();
  }

  Future<List<Map<String, dynamic>>?> _loadPetData() async {
    try {
      List<Map<String, dynamic>> data = (await _petModel
          .getPet(widget.appUser!.user_id)) as List<Map<String, dynamic>>;

      print('Pet Data: $data');



      return data;
    } catch (error) {
      print('Error loading pet profile data: $error');
      return null;
    }
  }

// _loadPetData에서 받은 데이터를 처리하는 함수
  void _processPetData(List<Map<String, dynamic>>? data) {
    if (data != null && data.isNotEmpty) {
      // 여러 펫 데이터가 있는 경우, 첫 번째 데이터를 사용하거나 필요에 맞게 처리

      setState(() {
        petProfileData = data[0];
        //~!
      });
    } else {
      // 데이터가 없는 경우에 대한 처리
      setState(() {
        petProfileData = null;
      });
    }
  }

// 사용 예시
  Future<void> _loadAndProcessPetData() async {
    List<Map<String, dynamic>>? data = await _loadPetData();
    _processPetData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: petProfileData != null
          ? _buildPetProfile()
          : Center(
        child: Text('로딩 중...'),
      ),
    );
  }

  ////////////////////
  Widget _buildPetProfile() {
    if (petProfileData != null) {
      return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '반려견 전화번호',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child: Container(
                margin: EdgeInsets.all(16),
                width: 328,
                height: 203,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile_images/ppp.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1E000000),
                      blurRadius: 12,
                      offset: Offset(4, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 117,
                      top: 20.0,
                      child: Text(
                        '${petProfileData!['pet_name']} 전화번호',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Positioned(
                      top: 106.0,
                      left: 71,
                      child: Text('펫 이름:   ${petProfileData!['pet_name']}'),
                    ),
                    Positioned(
                      top: 53.5,
                      left: 20.0,
                      child: Text(
                        '전화번호 :   ${petProfileData!['pet_phone']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 96.5,
                      left: 198,
                      child: Text(
                        '펫 종:   ${petProfileData!['pet_breed']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 74.5,
                      left: 198,
                      child: Text(
                        '성 별:   ${petProfileData!['pet_gender']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 118,
                      left: 198,
                      child: Text(
                        '모 색:   ${petProfileData!['pet_fur_color']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 139.5,
                      left: 198,
                      child: Text(
                        '나 이:   ${petProfileData!['pet_age']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 84.5,
                      left: 71,
                      child: Text(
                        '반려인:   ${widget.appUser?.nickname}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 166,
                      left: 109,
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 84,
                      left: 21,
                      child:
                      _buildImageFromBase64(petProfileData?['pet_images']),
                    ),
                    Positioned(
                      top: 162,
                      left: 286,
                      child: Image.asset(
                          'assets/images/index_images/witdog_logo.png'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text('펫 데이터가 없습니다.'),
      );
    }
  }
}

Widget _buildImageFromBase64(String base64String) {
  if (base64String.isEmpty) {
    return Container(); // 빈 컨테이너를 반환하거나 다른 기본 이미지를 설정할 수 있습니다.
  }

  Uint8List bytes = base64.decode(base64String);
  return Image.memory(bytes, width: 43, height: 43);
}
