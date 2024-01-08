import 'package:flutter/material.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';

class PetAddSuccessScreen extends StatefulWidget {
  const PetAddSuccessScreen({super.key});

  @override
  State<PetAddSuccessScreen> createState() => _PetAddSuccessScreenState();
}

class _PetAddSuccessScreenState extends State<PetAddSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    double Percent = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/profile_images/login_success.png', // 여기에 이미지 경로를 정확히 입력해주세요
              width: 202,
              height: 183,
            ),
            SizedBox(height: 31),
            Text(
              '환영합니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '가입이 완료되었습니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25,
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF16C077), // backgroundColor 대신 primary 사용
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // 모서리를 둥글게 설정
                ),
                fixedSize: Size(Percent * 0.5, 56.0), // 버튼 크기 설정 (원하는 크기로 수정)
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen()),
                );
              },
              child: Text('로그인하러 가기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
