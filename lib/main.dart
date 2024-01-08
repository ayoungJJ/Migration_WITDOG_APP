import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as KakaoUser;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_info_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_detail_screen.dart';


Future<void> main() async {
  KakaoSdk.init(nativeAppKey: '8af072c461ea48f446fa772d0662a93e');
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko-KR', null);

  await Supabase.initialize(
    url: 'https://eleuprlegtcsmivkiqjw.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsZXVwcmxlZ3Rjc21pdmtpcWp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE5MTU4MzAsImV4cCI6MjAxNzQ5MTgzMH0.8sG1GbXkt-08Pj8WFTeekp7vTt8FblOPfJiy8jyPi_o',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
      },
      home: LoginScreen(),
    );
  }
}