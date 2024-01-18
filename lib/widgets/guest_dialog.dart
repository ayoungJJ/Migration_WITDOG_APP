import 'package:flutter/material.dart';

class GuestDialog extends StatefulWidget {
  const GuestDialog({Key? key}) : super(key: key);

  @override
  State<GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends State<GuestDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // 배경을 어둡게 처리
      body: Center(
        child: AlertDialog(
          title: Text('Guest 모드'),
          content: Text('게스트로 이용 중입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}