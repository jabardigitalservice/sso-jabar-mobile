import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sso_jabar/views/profile_page.dart';

import 'views/login_page.dart';

const String clientId = '';
const String issuer = '';
const String redirectUrl = 'com.example.ssojabar://login-callback';
const String postLogoutRedirectUrl = 'com.example.ssojabar:/';
const String profileUrl = '';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo SSO Jabar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: ((context, snapshot) {
          return snapshot.hasData && snapshot.data!
              ? const ProfilePage()
              : const LoginPage();
        }),
      ),
    );
  }

  Future<bool> checkLogin() async {
    final spf = await SharedPreferences.getInstance();

    return spf.getString('accessToken') != null &&
        spf.getString('accessToken')!.isNotEmpty;
  }
}
