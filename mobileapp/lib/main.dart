import 'package:flutter/material.dart';

import 'package:mobileapp/screens/home_page.dart';
import 'package:mobileapp/screens/login_page.dart';
import 'package:mobileapp/screens/profile_page.dart';
import 'package:mobileapp/screens/register_page.dart';

void main() {
  runApp(const MinerApp());
}

class MinerApp extends StatelessWidget {
  const MinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miner Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
