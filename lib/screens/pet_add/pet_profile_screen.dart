import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/model/pet_model.dart';

class PetProfileScreen extends StatefulWidget {
  final KakaoAppUser? appUser;

  const PetProfileScreen({Key? key, this.appUser}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late PetModel _petModel;
  Map<String, dynamic>? petProfileData;

  String get formattedTime {
    return petProfileData != null
        ? DateFormat('yyyy년 MM월 dd일').format(
        DateTime.parse(petProfileData!['created_date'] ?? DateTime.now().toString()))
        : '';
  }

  @override
  void initState() {
    super.initState();
    _petModel = PetModel();
    _loadAndProcessPetData();
  }

  Future<List<Map<String, dynamic>>?> _loadPetData() async {
    try {
      List<Map<String, dynamic>> data = await _petModel.getPet(widget.appUser!.user_id);
      print('Pet Data: $data');
      return data;
    } catch (error) {
      print('Error loading pet profile data: $error');
      return null;
    }
  }

  // _loadPetData에서 받은 데이터를 처리하는 함수
  void _processPetData(List<Map<String, dynamic>>? data) {
    if (data != null && data.isNotEmpty) {
      // 여러 펫 데이터가 있는 경우, 첫 번째 데이터를 사용하거나 필요에 맞게 처리
      setState(() {
        petProfileData = data[0];
      });
    } else {
      // 데이터가 없는 경우에 대한 처리
      setState(() {
        petProfileData = null;
      });
    }
  }

  // 사용 예시
  Future<void> _loadAndProcessPetData() async {
    List<Map<String, dynamic>>? data = await _loadPetData();
    _processPetData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: petProfileData != null
          ? _buildPetProfile()
          : Center(
        child: Text('로딩 중...'),
      ),
    );
  }

  Widget _buildPetProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('펫 이름: ${petProfileData!['pet_name']}'),
          Text('펫 나이: ${petProfileData!['pet_age']}'),
          Text('펫 종: ${petProfileData!['pet_breed']}'),
          Text(formattedTime),
        ],
      ),
    );
  }
}