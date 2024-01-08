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

  Future<Map<String, dynamic>?> getPet(String petId) async {
    try {
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('pet_id', petId)
          .single();

      if (response != null && response != null) {
        throw response!;
      }

      return response.data as Map<String, dynamic>?;
    } catch (error) {
      print('Error fetching pet: $error');
      rethrow;
    }
  }
}
