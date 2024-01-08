import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late Image backgroundImage;

  @override
  void initState() {
    super.initState();

    // petImages는 여러 줄로 나뉜 Base64 데이터
    String base64Image = widget.pet['pet_images'];

    // Base64 데이터를 디코딩하여 이미지로 변환
    List<int> bytes = base64.decode(base64Image);
    backgroundImage = Image.memory(Uint8List.fromList(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // body를 AppBar 뒤로 확장
      appBar: AppBar(
        title: Text(widget.pet['pet_name'] + ' Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: AppBar().preferredSize.height), // 여백 추가
        decoration: BoxDecoration(
          // 배경 이미지 설정
          image: DecorationImage(
            image: backgroundImage.image,
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 나머지 내용들을 여기에 추가
              Text('User ID: ${widget.pet['user_id']}'),
              // 필요한 내용 추가

              // 필요에 따라 레이아웃을 수정할 수 있습니다.
            ],
          ),
        ),
      ),
    );
  }
}