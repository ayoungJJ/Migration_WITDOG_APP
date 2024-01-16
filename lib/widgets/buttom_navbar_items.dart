import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final List<BottomNavigationBarItem> bottomNavBarItems = <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: '홈',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset('assets/images/bottom_bar_icon/button_pet_add_icon.svg'),
    label: '다른집 개 등록하기',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset('assets/images/bottom_bar_icon/button_profile.svg'),
    label: '내 정보',
  ),
];
