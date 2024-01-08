import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as KakaoUser;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_pet/model/user.dart' as TestingPetUser;
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_info_screen.dart';
import 'package:testing_pet/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  KakaoAppUser? _kakaoAppUser; // appUser를 저장할 private 변수 추가

  KakaoAppUser? get appUser => _kakaoAppUser; // appUser에 접근하기 위한 getter 추가

  set appUser(KakaoAppUser? user) {
    _kakaoAppUser = user;
    notifyListeners();
  }

  Future<bool> checkKakaoLoginStatus() async {
    KakaoUser.User? kakaoUser = await KakaoUser.UserApi.instance.me();
    return kakaoUser != null;
  }

  Future<bool> checkIfFirstTimeUser() async {
    // 처음 사용하는 사용자 여부를 SharedPreferences를 사용하여 확인
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTimeUser = !(prefs.getBool('hasPetInfo') ?? false);
    return isFirstTimeUser;
  }

  Future<void> _saveKakaoUserInfo(TestingPetUser.KakaoAppUser appUser) async {
    try {
      // 사용자 등록 여부 확인
      bool isUserRegistered = await isUserAlreadyRegistered(appUser);
      print('Is user registered: $isUserRegistered');

      // 사용자가 등록되어 있지 않은 경우에만 upsert 수행
      if (!isUserRegistered) {
        Map<String, dynamic> kakaoUserInfo = {
          'user_id': await KakaoAppUser.getUserID(),
          'nickname': appUser.nickname,
          'profile_image': appUser.profile_image,
        };

        // Supabase 데이터베이스에 카카오 사용자 정보 저장
        final response = await supabase
            .from('Kakao_User')
            .upsert(
          kakaoUserInfo,
          onConflict: 'user_id',
        );

        if (response.error != null) {
          print('카카오 사용자 정보 저장 실패: ${response.error?.message}');
        } else {
          print('카카오 사용자 정보 저장 성공');
        }
      }
    } catch (e) {
      print('카카오 사용자 정보 저장 중 오류 발생: $e');
    }
  }

  Future<bool> isUserAlreadyRegistered(KakaoAppUser kakaoAppUser) async {
    try {
      final response = await supabase
          .from('Kakao_User')
          .select()
          .eq('user_id', await KakaoAppUser.getUserID())
          .single();

      print(response);

      return response != null;
    } catch (e) {
      print('사용자 등록 확인 중 오류 발생: $e');
      return false;
    }
  }


  Future<bool> checkIfUserHasPetDataInDatabase(KakaoAppUser? kakaoAppUser) async {
    if (kakaoAppUser == null || kakaoAppUser.user_id == null) {
      print('Invalid input: KakaoAppUser or user_id is null.');
      return false;
    }

    try {
      // Query to retrieve user's pet data
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('user_id', kakaoAppUser.user_id);

      print("Check pet data user_id : $response");

      // Check the response and return whether there is data
      if (response != null && response.data != null && response.data!.isNotEmpty) {
        return true; // Return true if there is data
      } else {
        print('Failed to check pet data: No response or no data.');
        return false; // Return false if there is no data
      }
    } catch (e) {
      print('An error occurred while checking pet data: $e');
      return false; // When an error occurs, false is returned by default.
    }
  }



  Future<void> _performKakaoLogoutOrUnlink() async {
    try {
      // 로그아웃
      //await UserApi.instance.logout();

      // 또는 계정 연결 해제 (unlink)
      //await UserApi.instance.unlink();

      // 여기에 로그아웃 또는 연결 해제 이후의 동작을 추가할 수 있습니다.
    } catch (e) {
      // 예외 처리
      print('카카오 로그아웃 또는 연결 해제 중 오류 발생: $e');
    }
  }

  Future<void> kakaologin(BuildContext context) async {
    try {
      await _performKakaoLogoutOrUnlink();
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡을 통한 로그인 성공');

          // 카카오 사용자 정보 가져오기
          try {
            final dynamic users = await UserApi.instance.me();

            // AppUser 모델에 맞게 필드에 접근하도록 수정
            final appUser = KakaoAppUser(
              id: users.id.toString(),
              user_id: await KakaoAppUser.getUserID(),
              nickname: users.kakaoAccount?.profile?.nickname ?? 'No Nickname',
              // null 체크 추가
              profile_image: users.kakaoAccount?.profile?.profileImageUrl ?? '',
              // null 체크 추가
              createdAt: DateTime.now(),
              kakaoAccount: null,
            );
            print('사용자 정보: $appUser');

            // 카카오 사용자 정보를 Supabase 데이터베이스에 저장
            await _saveKakaoUserInfo(appUser);

            // 사용자가 이미 등록되어 있는지 확인
            bool isUserRegistered = await isUserAlreadyRegistered(
                appUser as TestingPetUser.KakaoAppUser);

            print('isUserRegister $isUserRegistered');

            if (isUserRegistered) {
              // 등록된 사용자인 경우, 홈 화면으로 이동
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(appUser: appUser),
                ),
              );
            } else {
              // 등록되지 않은 사용자인 경우, PetInfoScreen으로 이동
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PetInfoScreen(
                    appUser: appUser,
                  ),
                ),
              );
            }
          } catch (error) {
            print('카카오 사용자 정보 가져오기 실패: $error');
          }
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }

          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인 시도
          try {
            await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공');
          } catch (error) {
            print('카카오계정으로 로그인 실패: $error');
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패: $error');
        }
      }
    } catch (error) {
      print('KakaoFlutterSdk 초기화 실패: $error');
    }
  }

}
