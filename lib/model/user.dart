
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoAppUser {
  String id;
  String user_id;
  String nickname;
  String profile_image;
  DateTime createdAt;
  dynamic kakaoAccount;

  // 생성자에서 user_id를 제거합니다.
  KakaoAppUser({
    required this.id,
    required this.user_id,
    required this.nickname,
    required this.profile_image,
    required this.createdAt,
    required this.kakaoAccount,
  });

  // 카카오 SDK를 사용하여 현재 사용자의 ID를 가져오는 메서드
  static Future<String> getUserID() async {
    try {
      final user = await UserApi.instance.me();
      return user.id.toString();
    } catch (e) {
      print('Failed to get Kakao user ID: $e');
      // 실패 시 대체할 값 또는 에러 처리 방법을 반환하세요.
      return 'fallback_user_id';
    }
  }
}