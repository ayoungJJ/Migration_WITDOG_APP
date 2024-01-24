import 'dart:convert';
import 'dart:typed_data';
import 'package:testing_pet/utils/constants.dart';

class PetModel {
  PetModel();

  Future<void> addPet({
    required String userId,
    required Uint8List petImages,
    required String petName,
    required String petBreed,
    required String petSize,
    required String petGender,
    required String petAge,
    required String petPhone,
    required bool isFavorite,
    required String petIdentity,
  }) async {
    try {
      // petImages를 base64로 인코딩
      String encodedImages = _encodeImages(petImages);

      // Add_UserPet 테이블에 데이터 추가
      final response = await supabase.from('Add_UserPet').upsert([
        {
          'user_id': userId,
          'pet_images': encodedImages,
          'pet_name': petName,
          'pet_breed': petBreed,
          'pet_size': petSize,
          'pet_gender': petGender,
          'pet_age': petAge,
          'pet_phone': petPhone,
          'pet_favorite': isFavorite,
          'pet_identity': petIdentity,
        }
      ]);

      print(response);

      if (response != null && response.error != null) {
        throw response.error!;
      }
    } catch (error) {
      print('Error adding pet: $error');
      rethrow;
    }
  }

  static Uint8List _decodeImages(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Uint8List(0);
    }

    try {
      Uint8List decoded = base64Decode(base64String);
      print('Decoded data: $decoded');
      return decoded ?? Uint8List(0);
    } catch (e) {
      print('Error decoding images: $e');
      return Uint8List(0);
    }
  }

  static String _encodeImages(Uint8List images) {
    return base64Encode(images);
  }

  Future<List<Map<String, dynamic>>> getPet(String userId) async {
    try {
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('user_id', userId);

      if (response != null && response != null) {
        throw response;
      }

      // 응답이 리스트인 경우
      if (response.data is List) {
        List<Map<String, dynamic>> dataList = (response.data as List)
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList();

        return dataList;
      }

      // 응답이 단일 객체인 경우
      return [response.data as Map<String, dynamic>];
    } catch (error) {
      print('Error fetching pet: $error');
      rethrow;
    }
  }
}
