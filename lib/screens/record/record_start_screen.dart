import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart' as Record;
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';

class RecordStartScreen extends StatefulWidget {
  const RecordStartScreen({Key? key}) : super(key: key);

  @override
  State<RecordStartScreen> createState() => _RecordStartScreenState();
}

class _RecordStartScreenState extends State<RecordStartScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool isStopButtonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double eightyPercentHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('뒤로가기'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
      ),
      extendBodyBehindAppBar: true,
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
                padding: EdgeInsets.only(top: eightyPercentHeight * 0.21),
                child: const Text(
                  '아래 글자를 말해보세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7FFFFF),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: eightyPercentHeight * 0.03),
                child: const Text(
                  '집에갈께',
                  style: TextStyle(
                    fontSize: 36,
                    color: Color(0xFF7FFFFF),
                  ),
                ),
              ),
              SizedBox(height: eightyPercentHeight * 0.15),
              GestureDetector(
                onTap: () {
                  if (!isRecording && !isStopButtonPressed) {
                    startRecording();
                  } else if (isRecording && !isStopButtonPressed) {
                    stopRecording();
                    showRecordingCompleteDialog(context);
                  }
                },
                child: isStopButtonPressed
                    ? GestureDetector(
                  onTap: () {
                    showRecordingCompleteDialog(context);
                  },
                  child: Image.asset(
                    'assets/images/record_images/mic_void.png',
                    height: 200,
                    width: 200,
                  ),
                )
                    : RippleAnimation(
                  color: const Color(0xFF466053),
                  delay: const Duration(milliseconds: 100),
                  repeat: true,
                  minRadius: 100,
                  ripplesCount: 5,
                  duration: const Duration(milliseconds: 6 * 300),
                  child: Image.asset(
                    'assets/images/record_images/animations_mic.gif',
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: eightyPercentHeight * 0.11),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Color(0xFF16C077)),
                        minimumSize: MaterialStateProperty.all(Size(189, 56)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (isRecording) {
                          stopRecording();
                          showRecordingCompleteDialog(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        }
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

  Future<void> startRecording() async {
    try {
      await Record.RecordState.record;
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecording() async {
    await Record.RecordState.stop;
    setState(() {
      isRecording = false;
      isStopButtonPressed = true;
    });
  }

  void showRecordingCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('녹음 완료'),
        content: const Text('녹음이 성공적으로 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
