import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sso_jabar/views/profile_page.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final appAuth = const FlutterAppAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(50, 0, 50, 50),
              child: Image(
                image: AssetImage('assets/images/sidebar-logo.png'),
              ),
            ),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login with SSO Jabar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final spf = await SharedPreferences.getInstance();

    final List<String> scopes = <String>[
      "openid",
      "profile",
      "email",
      "roles",
    ];

    try {
      // app will be open browser and make request to server
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: scopes,
        ),
      );

      await spf.setString('idToken', result?.idToken ?? '');
      await spf.setString('accessToken', result?.accessToken ?? '');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ProfilePage(),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
