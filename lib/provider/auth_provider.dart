import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as KakaoUser;
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';
import 'package:testing_pet/widgets/DeviceInfoService.dart';

class AuthProvider with ChangeNotifier {
  KakaoAppUser? _kakaoAppUser;

  KakaoAppUser? get appUser => _kakaoAppUser;

  set appUser(KakaoAppUser? user) {
    _kakaoAppUser = user;
    notifyListeners();
  }

  // 디바이스 저장 메서드
  Future<void> saveDeviceIdToSupabase(String deviceId) async {
    try {
      // 디바이스 정보를 담은 Map 생성
      Map<String, dynamic> deviceInfo = {
        'user_deviceId': deviceId,
      };

      // Supabase 데이터베이스에 디바이스 정보 저장
      final response = await supabase
          .from('device_info')
          .upsert(
            deviceInfo,
            onConflict: 'device_info',
          )
          .single();

      print('print user device : ${response}');
    } catch (e) {
      print('디바이스 정보 저장 중 오류 발생: $e');
    }
  }

  // 카카오 로그인 메서드
  Future<void> kakaologin(BuildContext context) async {
    if (await isKakaoTalkInstalled()) {
      try {
        print('print UserApi : ${UserApi.instance.loginWithKakaoTalk()}');
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> saveKakaoUserInfo(KakaoAppUser appUser) async {
    try {
      // 사용자 등록 여부 확인

      // 사용자가 등록되어 있지 않은 경우에만 upsert 수행
      Map<String, dynamic> kakaoUserInfo = {
        'user_id': await KakaoAppUser.getUserID(),
        'nickname': appUser.nickname,
      };

      // Supabase 데이터베이스에 카카오 사용자 정보 저장
      final response = await supabase.from('Kakao_User').upsert(
            kakaoUserInfo,
            onConflict: 'user_id',
          );

      if (response.error != null) {
        print('카카오 사용자 정보 저장 실패: ${response.error?.message}');
      } else {
        print('카카오 사용자 정보 저장 성공');
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
}
