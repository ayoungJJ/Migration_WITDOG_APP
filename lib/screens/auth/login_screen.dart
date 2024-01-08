import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as KakaoUser;
import 'package:provider/provider.dart';
import 'package:testing_pet/model/user.dart' as TestingPetUser;
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_info_screen.dart';
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
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
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
            padding: const EdgeInsets.only(bottom: 78.0),
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
                  authProvider.setLoading(true);

                  try {
                    await authProvider.kakaologin(context);

                    bool isLoggedIn =
                    await authProvider.checkKakaoLoginStatus();

                    if (isLoggedIn) {
                      bool isFirstTimeUser =
                      await authProvider.checkIfFirstTimeUser();

                      if (isFirstTimeUser) {
                        bool hasPetData =
                        await authProvider.checkIfUserHasPetDataInDatabase(
                            authProvider.appUser);

                        if (!hasPetData) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(appUser: authProvider.appUser!),
                            ),
                          );
                        }

                        if (hasPetData) {
                          _WelcomeDialog(context);
                        } else if (authProvider.appUser != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetInfoScreen(
                                appUser: authProvider.appUser!,
                              ),
                            ),
                          );
                        }
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(appUser: authProvider.appUser!),
                          ),
                        );
                      }
                    } else if (authProvider.appUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetInfoScreen(
                            appUser: authProvider.appUser!,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print('로그인 실패: $e');
                  } finally {
                    authProvider.setLoading(false);
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
