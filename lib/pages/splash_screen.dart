import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool userExists = prefs.getString('userName') != null;

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        if (userExists) {
          // Jika data user ada, langsung ke halaman utama
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          // <<< PERUBAHAN DI SINI >>>
          // Jika data user belum ada, arahkan ke Get Started Page
          Navigator.of(context).pushReplacementNamed('/get_started');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset('assets/logo.png', width: 120)],
        ),
      ),
    );
  }
}
