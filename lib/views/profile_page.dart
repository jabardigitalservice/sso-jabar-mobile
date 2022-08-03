import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sso_jabar/views/login_page.dart';

import '../main.dart';

const encoder = JsonEncoder.withIndent('  ');

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String siapProfileData = '';
  String appProfileData = '';
  String keycloakProfileData = '';

  @override
  void initState() {
    super.initState();

    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo SSO JABAR'),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.orange,
                size: 100,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Data SIAP',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Data SIAP pada mobile app ini tidak diambil langsung dari Server SIAP, melainkan dari Server Aplikasi',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(siapProfileData),
                const Divider(
                  thickness: 2,
                  height: 40,
                ),
                const Text(
                  'Data App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(appProfileData),
                const Divider(
                  thickness: 2,
                  height: 40,
                ),
                const Text(
                  'Data Keycloak',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(keycloakProfileData),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: logout,
        icon: const Icon(Icons.exit_to_app),
        label: const Text("LOGOUT"),
      ),
    );
  }

  Future<void> getProfile() async {
    isLoading = true;
    final spf = await SharedPreferences.getInstance();

    final resultApi = await http.get(Uri.parse(profileUrl),
        headers: {'Authorization': 'Bearer ${spf.getString('accessToken')}'});

    if (resultApi.body.toLowerCase().contains('expired')) {
      if (!mounted) return;
      var snackBar = const SnackBar(content: Text('Token Expired'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );

      await spf.clear();
    } else {
      siapProfileData =
          encoder.convert(jsonDecode(resultApi.body)['data_siap']);
      appProfileData = encoder.convert(jsonDecode(resultApi.body)['data_web']);
      keycloakProfileData = encoder
          .convert(JwtDecoder.decode(spf.getString('accessToken') ?? ''));

      isLoading = false;

      setState(() {});
    }
  }

  Future<void> logout() async {
    final spf = await SharedPreferences.getInstance();
    await const FlutterAppAuth().endSession(EndSessionRequest(
        idTokenHint: spf.getString('idToken'),
        postLogoutRedirectUrl: postLogoutRedirectUrl,
        issuer: issuer));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginPage(),
      ),
    );

    await spf.clear();
  }
}
