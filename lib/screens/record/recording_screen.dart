import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing_pet/screens/record/count_down_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    checkPermissionsAndStartRecording();
  }

  @override
  Widget build(BuildContext context) {
    double eightyPercentHeight = MediaQuery
        .of(context)
        .size
        .height * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: eightyPercentHeight * 0.03),
                child: const Text(
                  '집에갈께',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: eightyPercentHeight * 0.15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CountDownScreen(
                            onCountDownComplete: () {},
                          ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/images/record_images/mic_void.png',
                    height: 200,
                    width: 200,
                  ),
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
                        backgroundColor: MaterialStateProperty.all(Color(0xFF16C077)),
                        minimumSize: MaterialStateProperty.all(Size(189, 56)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // 원하는 둥근 정도
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Stop 버튼이 눌렸을 때 수행할 동작 추가
                      },
                      child: Text('그만하기'),
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

  Future<void> checkPermissionsAndStartRecording() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      // 마이크 권한이 이미 허용된 경우

    } else {
      // 마이크 권한이 허용되지 않은 경우
      await Permission.microphone.request();
      status = await Permission.microphone.status;
      if (!status.isGranted) {
        showMicPermissionDeniedDialog(context);
      } else {
        // 권한이 허용되었을 때의 로직을 여기에 추가하세요.
      }
    }
  }

  void showMicPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('마이크 권한 필요'),
            content: const Text('녹음을 위해 마이크 권한이 필요합니다. 설정으로 이동하여 권한을 부여해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
    );
  }
}
