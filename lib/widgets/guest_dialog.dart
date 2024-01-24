import 'package:flutter/material.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';

class GuestDialog extends StatefulWidget {
  const GuestDialog({Key? key}) : super(key: key);

  @override
  State<GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends State<GuestDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1), // 배경을 어둡게 처리
      body: Center(
        child: AlertDialog(
          title: Center(
              child: Text(
                '이용불가',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
              )),
          content: Text(
            '현재 이용이 불가합니다\n회원가입 후 이용해 주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            ),
          ),

          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(262, 56),
                        backgroundColor: Color(0xFF16C077),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        //backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF16C077)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                        //Navigator.pop(context);
                      },
                      //style:
                      child: Text(
                        '회원가입하기',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(262, 56),
                      backgroundColor: Color(0xFF7516C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      //backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF16C077)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    //style:
                    child: Text(
                      '나중에하기',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}