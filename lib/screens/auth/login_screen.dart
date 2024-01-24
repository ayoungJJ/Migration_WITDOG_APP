import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:testing_pet/model/user.dart' as TestingPetUser;
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/screens/record/count_down_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthProvider authProvider;
  late KakaoAppUser kakaoAppUser;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double percent = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/login_images/login_screen_image.png'),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 122.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFFFDE30)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  try {
                    // 카카오톡을 통한 로그인 시도
                    await UserApi.instance.loginWithKakaoTalk();
                    print('카카오톡을 통한 로그인 성공');

                    // 카카오 사용자 정보 가져오기
                    final dynamic users = await UserApi.instance.me();

                    // AppUser 모델에 맞게 필드에 접근하도록 수정
                    final appUser = KakaoAppUser(
                      id: users.id.toString(),
                      user_id: await KakaoAppUser.getUserID(),
                      nickname: users.kakaoAccount?.profile?.nickname ??
                          'No Nickname',
                      createdAt: DateTime.now(),
                      kakaoAccount: null,
                    );
                    print('사용자 정보: $appUser');

                    // Supabase에 사용자 정보 저장
                    await AuthProvider().saveKakaoUserInfo(appUser);

                    // Navigator를 이용하여 화면 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                          appUser: appUser,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('오류 발생: $e');
                  }
                },
                child: Container(
                  width: percent * 0.49,
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login_images/kakao_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '카카오아이디로 시작하기',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF725353),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    // 로그인 없이 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(appUser: KakaoAppUser(id: '', user_id: 'guest', nickname: '', createdAt: DateTime.now(), kakaoAccount: null)), // 빈 KakaoAppUser를 전달
                      ),
                    );
                  },
                  child: Text('둘러보기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white, // 밑줄 색상
                      decorationStyle: TextDecorationStyle.solid, // 밑줄 스타일
                      decorationThickness: 1, // 간격 조절
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60.0,
            left: 16.0,
            child: Text(
              '동물과의\n커뮤니케이션이\n즐겁다!',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _WelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Center(
            child: Text(
              '신규가입고객',
              style: TextStyle(
                letterSpacing: 0.25,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '신규가입을 환영합니다!\n먼저 내 반려동물과 대화를 하기위해\n몇 가지가 필요해요',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountDownScreen(
                      onCountDownComplete: () {},
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(262, 56),
                backgroundColor: Color(0xFF16C077),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '입력하러가기',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
