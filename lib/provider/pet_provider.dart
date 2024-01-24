import 'package:flutter/material.dart';
import 'package:testing_pet/utils/constants.dart';

class PetProvider with ChangeNotifier {
  String? _petIdentity;

  String? get petIdentity => _petIdentity;

  set loggedInpetId3entity(String value){    // 반려동물 디바이스 로그인 메서드
    _petIdentity = value;
    notifyListeners();
  }

  Future<void> petdevicelogin(String petIdentity) async {
    try {
      // Supabase에서 pet_identity로 펫을 찾아옴
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('pet_identity', petIdentity)
          .single();

      print('login = $response');

      if (response.error != null) {
        // 오류 처리
        print('Error occurred while fetching pet details: ${response.error}');
        return;
      }

      // 펫 정보 가져오기
      final petDetails = response.data;

      if (petDetails != null) {
        // 펫이 존재하면 로그인 성공
        print('Pet login successful! Pet details: $petDetails');
        _petIdentity = petIdentity;

        // 여기에서 로그인 성공 후의 추가 로직을 수행할 수 있음
      } else {
        // 펫이 존재하지 않으면 로그인 실패 처리
        print('Pet not found. Pet login failed.');
      }
    } catch (e) {
      // 예외 처리
      print('Error occurred while verifying pet login: $e');
    }
  }

// 반려동물 식별자 유효성을 확인하는 메서드
  Future<bool> checkPetIdentity(String petIdentity) async {
    try {
      // Supabase에서 pet_identity와 일치하는 Pet 찾기
      final response = await supabase
          .from('Add_UserPet')
          .select('pet_identity')
          .eq('pet_identity', petIdentity)
          .single();

      print(response);

      // 응답이 null이 아니고 'pet_identity' 속성을 포함하는지 확인
      if (response['pet_identity'] != null) {
        // 'pet_identity' 값이 존재하면 유효한 Pet 식별자로 간주
        return true;
      } else {
        // 응답이 null이거나 유효한 데이터를 포함하지 않으면 처리
        print('Supabase response is null or does not contain valid data.');
        return false;
      }
    } catch (e) {
      // exception handling
      print('An error occurred while checking pet identifier: $e');
      return false;
    }
  }
}

