import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';
import 'package:testing_pet/widgets/DeviceInfoService.dart';


Future<void> main() async {
  KakaoSdk.init(nativeAppKey: '95a35ff740dfd9a4092ae9857cd62d2c');
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko-KR', null);

  await Supabase.initialize(
    url: 'https://fnjsdxnejydzzlievpie.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZuanNkeG5lanlkenpsaWV2cGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMyMTMwMjgsImV4cCI6MjAxODc4OTAyOH0.YuPhXNFkhfcLtU_NLg3gexiX9FORcQEqmy_BOGZw78Q',
  );

  String deviceId = await DeviceInfoService.getDeviceId();
  AuthProvider authProvider = AuthProvider();
  await authProvider.saveDeviceIdToSupabase(deviceId);

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
      },
      home: LoginScreen(),
    );
  }
}