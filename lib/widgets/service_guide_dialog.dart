import 'package:flutter/material.dart';

class ServiceGuideDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('서비스 가이드'), // 대화 상자 제목 변경
      content: Text('반려 동물과 언어 번역\n - 개발 예정 \n\n'
          '영상 통화 기능, 반려 목록\n - 개발 진행 중 '
      ), // 대화 상자 내용 변경
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6ABFB9)
          ),
          child: Text('닫기'), // 버튼 텍스트 변경
          onPressed: () {
            Navigator.of(context).pop(); // 대화 상자 닫기
          },
        ),
      ],
    );
  }
}
