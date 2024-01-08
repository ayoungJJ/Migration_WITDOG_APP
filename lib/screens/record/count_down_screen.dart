import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart' as Record;
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';
import 'package:testing_pet/screens/record/record_start_screen.dart';
import 'recording_screen.dart'; // RecordingScreen 클래스 import 추가

class CountDownScreen extends StatefulWidget {
  final VoidCallback onCountDownComplete;

  const CountDownScreen({Key? key, required this.onCountDownComplete})
      : super(key: key);

  @override
  _CountDownScreenState createState() => _CountDownScreenState();
}

class _CountDownScreenState extends State<CountDownScreen> {
  int count = 3;
  late Timer countDownTimer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    double eightyPercentHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF073823), Color(0xFF6AFFBF)],
            stops: [0.0, 1.0],
            begin: Alignment(0.5, 0.34),
            end: Alignment(0.5, 1.95),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: eightyPercentHeight * 0.25),
                child: const Text(
                  '카운트 후 말씀해 주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: eightyPercentHeight * 0.17),
                child: Builder(
                  builder: (context) {
                    if (count == 0) {
                      Future.delayed(Duration.zero, () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordStartScreen(),
                          ),
                        );
                      });
                    }

                    return Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 200,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: eightyPercentHeight * 0.11),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF16C077)),
                        minimumSize: MaterialStateProperty.all(Size(189, 56)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        navigateToNextScreen();
                      },
                      child: Text('그만하기',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 0.25,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startCountdown() {
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        count--;
      });

      if (count == 0) {
        timer.cancel();
        widget.onCountDownComplete();
      }
    });
  }

  void navigateToNextScreen() {
    // 여기에서 단어를 입력 중인지, 처음 단어도 입력하지 않았는지에 따라 적절한 페이지로 이동
    // 예를 들어, 단어를 입력 중인지 확인하는 조건은 입력 중인지의 여부에 따라 적절하게 수정
    bool isTypingWord = true; // 단어를 입력 중인지 여부 (임시값, 실제로는 텍스트 입력 상태를 확인해야 함)

    if (isTypingWord) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecordingScreen(),
        ),
      );
    } else {
      // 처음 단어도 입력하지 않았다면 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(), // YourLoginPage에는 실제 로그인 페이지가 들어가야 합니다.
        ),
      );
    }
  }

  @override
  void dispose() {
    countDownTimer.cancel();
    super.dispose();
  }
}
