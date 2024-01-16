// fetch_profile_image.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testing_pet/utils/constants.dart';

Future<String?> fetchProfileImage(String userId) async {
  final response = await supabase.from('images')
      .select('image_data').eq('user_id', userId).single();

  if (response != null) {
    final imageData = response['image_data'] as String?;
    return imageData;
  } else {
    return null;
  }
}

Widget buildProfileImage(String? imageData) {
  if (imageData != null && imageData.isNotEmpty) {
    final bytes = base64Decode(imageData);
    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(bytes),
    );
  } else {
    return CircleAvatar(
      radius: 50,
      child: Icon(Icons.account_circle, size: 50, color: Colors.white),
      backgroundColor: Colors.grey,
    );
  }
}
