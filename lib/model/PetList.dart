class PetList {
  final int id;
  final String petName;
  final String petAge;
  final String petImages;
  final String petGender;
  final String petBreed;
  final bool petFavorite;

  PetList({
    required this.id,
    required this.petName,
    required this.petAge,
    required this.petImages,
    required this.petGender,
    required this.petBreed,
    required this.petFavorite,
  });

  // Map에서 PetList로 변환하는 정적 메서드 추가
  static PetList fromMap(Map<String, dynamic> map) {
    return PetList(
      id: map['id'] as int,
      petName: map['pet_name'] as String,
      petAge: map['pet_age'] as String,
      petImages: map['pet_images'] as String,
      petGender: map['pet_gender'] as String,
      petBreed: map['pet_breed'] as String,
      petFavorite: map['pet_favorite'] as bool,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id 필드 추가
      'pet_name': petName,
      'pet_age': petAge,
      'pet_images': petImages,
      'pet_gender': petGender,
      'pet_breed': petBreed,
      'pet_favorite': petFavorite,
    };
  }
}