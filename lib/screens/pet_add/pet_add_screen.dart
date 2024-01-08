import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testing_pet/model/pet_model.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/utils/constants.dart';

class PetAddScreen extends StatefulWidget {
  final KakaoAppUser appUser; // 생성자에 추가된 매개변수

  PetAddScreen({required this.appUser});

  @override
  State<PetAddScreen> createState() => _PetAddScreenState();
}

class _PetAddScreenState extends State<PetAddScreen> {
  String petName = '';
  String selectedBreed = '';
  String selectedSize = '';
  String selectedDropdown = '';
  String selectedGender = '암컷';
  bool selectedIsNeutered = false;
  String petAge = '';
  String randomNumberText = '';
  String duplicateText = '';
  late ImagePicker picker;
  XFile? image;
  Uint8List? imageBytes;
  bool isDuplicate = true;

  String generateRandomNumber() {
    // 4자리 난수 생성
    String randomNum = (Random().nextInt(9000) + 1000).toString();

    return randomNum;
  }

  Future<String> saveToDatabase() async {
    String genderCode = (selectedGender == '수컷') ? 'A' : 'B';
    String sizedCode = (selectedSize == '소형')
        ? 'A'
        : (selectedSize == 'medium')
        ? 'B'
        : 'C';

    String petPhone = '$genderCode$sizedCode-${generateRandomNumber()}';

    return petPhone;
  }

  Future<void> initializeImagePicker() async {
    picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
  }

// 데이터베이스에 반려동물 정보 추가 함수
  Future<void> _addPetToDatabase() async {
    try {
      final userId = await KakaoAppUser.getUserID();
      String petPhone = await saveToDatabase();
      Uint8List? imageBytes;
      if (image != null) {
        imageBytes = await image!.readAsBytes();
      }

      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await _uploadImageToDatabase(imageBytes);
      }

      // Add pet information to Supabase database using imageUrl in existing code
      await PetModel().addPet(
        userId: userId,
        petImages: imageBytes ?? Uint8List(0),
        petName: petName,
        petBreed: selectedBreed,
        petSize: selectedSize,
        petGender: selectedGender,
        petAge: petAge,
        petPhone: petPhone,
        isFavorite: false,
      );
    } catch (error) {
      print('Error adding pet: $error');
      rethrow;
    }
  }

  // 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = pickedImage;
    });
  }

// 이미지를 Supabase 데이터베이스에 업로드 및 URL 반환
  Future<String?> _uploadImageToDatabase(Uint8List imageBytes) async {
    try {
      final imageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final userId = await KakaoAppUser.getUserID();

      print('Image URL: $imageUrl');

      final response = await supabase.from('pet_images').upsert([
        {
          'user_id': userId,
          'pet_images': imageUrl,
        }
      ]);

      if (response.error != null) {
        // 에러 처리
        print('프로필 및 이미지 데이터 저장 오류: ${response.error!.message}');
      } else {
        // 성공적으로 데이터 저장
        print('프로필 및 이미지 데이터가 성공적으로 저장되었습니다.');
      }
    } catch (error) {
      // 에러 처리
      print('프로필 및 이미지 데이터 저장 중 오류 발생: $error');
    }
  }

  void _onAddButtonClicked() async {
    try {
      await _pickImage(); // 이미지 선택 추가

      if (image == null) {
        // 이미지가 선택되지 않은 경우 예외 처리
        print('Error: Image not selected');
        return;
      }

      final imageBytes = await image!.readAsBytes();

      if (imageBytes == null) {
        // 이미지 바이트가 없는 경우 예외 처리
        print('Error: Image bytes are null');
        return;
      }

      // 이미지를 데이터베이스에 업로드하고 URL 가져오기
      await _uploadImageToDatabase(imageBytes!);

      // 나머지 코드 작성...
    } catch (error) {
      print('Error adding pet: $error');
    }
  }

  void checkForDuplicates() async {
    // Supabase를 사용하여 중복 확인
    bool isDuplicate = await simulateDuplicateCheck();

    setState(() {
      if (isDuplicate) {
        // 중복된 경우 - 빨간색으로 표시
        randomNumberText = '이 번호는 이미 등록되었습니다.';
      } else {
        // 사용 가능한 경우 - 초록색으로 표시
        randomNumberText = '사용 가능한 번호입니다.';
      }
    });
  }

// Supabase를 사용하여 중복 확인하는 함수
  Future<bool> simulateDuplicateCheck() async {
    try {
      // Supabase API를 사용하여 중복 확인
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('pet_phone', phoneNumberController.text)
          .single();

      // Supabase에서 응답이 있는지 확인하여 중복 여부 판단
      print(response); // 디버깅용
      return response != null;
    } catch (e) {
      // 오류 처리: Supabase PostgREST 오류인 경우
      print('Supabase PostgREST 오류: $e');
      return false; // 또는 예외에 대한 적절한 처리 추가
    }
  }

  TextEditingController phoneNumberController = TextEditingController();

  List<String> dogBreedList = ['말티즈', '슈나우저', '믹스견'];
  List<String> dogSizeList = ['소형', '중형', '대형'];

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(
                '반려동물추가',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    await _addPetToDatabase();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(appUser: authProvider.appUser!),
                      ),
                      (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Color(0xFF0094FF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Color(0xFFF0F0F0),
              elevation: 0,
              titleSpacing: 0,
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '반려동물 사진 추가',
                    style: TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 19,
              ),
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _onAddButtonClicked, // Add 버튼 클릭 시 함수 호출
                  child: Stack(
                    children: [
                      // gradation
                      Positioned(
                        top: 0.67 * 184,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFC1C1C1),
                                Colors.grey,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(33.0),
                        child: image != null
                            ? Image.file(File(image!.path),
                            width: 118, height: 118)
                            : SvgPicture.asset(
                          'assets/images/profile_images/default_dog_profile.svg',
                          width: 118,
                          height: 118,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 11,
                        child: Center(
                          child: Text(
                            '추가하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 텍스트 입력 필드 3개 추가
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            petName = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: '별칭을 입력해 주세요',
                          labelStyle: TextStyle(
                            color: Color(0xffC1C1C1),
                            fontSize: 18,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xffC1C1C1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xffE0E0E0),
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 12,
              ),
              Padding(
                padding:
                const EdgeInsets.only(right: 16.0, left: 16.0, top: 12),
                child: Container(
                  height: 56, // DropdownButton의 높이 조절
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Color(0xffE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value:
                          selectedBreed.isNotEmpty ? selectedBreed : null,
                          items: dogBreedList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(
                                child: Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedBreed = value ?? '';
                            });
                          },
                          underline: Container(),
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.arrow_drop_down,
                                color: Color(0xffC1C1C1)),
                          ),
                          hint: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '반려동물 품종 선택',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xffC1C1C1),
                              ),
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding:
                const EdgeInsets.only(right: 16.0, left: 16.0, top: 12),
                child: Container(
                  height: 56, // DropdownButton의 높이 조절
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Color(0xffE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedSize.isNotEmpty ? selectedSize : null,
                          items: dogSizeList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(
                                child: Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedSize = value ?? '';
                            });
                          },
                          underline: Container(),
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.arrow_drop_down,
                                color: Color(0xffC1C1C1)),
                          ),
                          hint: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '반려동물 품종 선택',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xffC1C1C1),
                              ),
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 암컷 선택 버튼
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 7),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedGender = '암컷';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(56),
                          backgroundColor: selectedGender == '암컷'
                              ? Color(0xFF16C077)
                              : Color(0xffE0E0E0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '암컷',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: selectedGender == '암컷'
                                ? Colors.white
                                : Color(0xffC1C1C1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 수컷 선택 버튼
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7, right: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedGender = '수컷';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(56),
                          backgroundColor: selectedGender == '수컷'
                              ? Color(0xFF16C077)
                              : Color(0xffE0E0E0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '수컷',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: selectedGender == '수컷'
                                ? Colors.white
                                : Color(0xffC1C1C1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: selectedIsNeutered,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedIsNeutered = value ?? false;
                          });
                        },
                        visualDensity:
                        VisualDensity(horizontal: -4, vertical: -4),
                      ),
                      Text(
                        '중성화했음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            petAge = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: '몇살인지 입력해 주세요',
                          labelStyle: TextStyle(
                            color: Color(0xffC1C1C1),
                            fontSize: 18,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xffC1C1C1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xffE0E0E0),
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(
                      '동물전화번호',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3,),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Text(
                      '원격으로 통신할 수 있는 동물전화번호를 등록합니다.\n끝자리만 선택이 가능해요 예시) ABC-1234-5678',
                      style: TextStyle(
                        color: Color(0xff7C7C7C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                              TextEditingController(text: randomNumberText),
                              style: TextStyle(fontSize: 20),
                              readOnly: false,
                              decoration: InputDecoration(
                                hintText: '번호입력',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFDDDDDD), width: 1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(96, 56),
                            backgroundColor: Color(0xFF262121),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              randomNumberText = generateRandomNumber();
                            });
                          },
                          child: Text(
                            '랜덤번호',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(96, 56),
                            backgroundColor: Color(0xFF16C077),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            checkForDuplicates();
                          },
                          child: Text(
                            '중복확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        ),
                      ),

                    ],
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        randomNumberText,
                        style: TextStyle(
                          color: isDuplicate ? Colors.red : Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
