import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_tracker/pages/splash_screen.dart';
import 'package:finance_tracker/pages/onboarding_page.dart';
import 'package:finance_tracker/pages/main_page.dart';
// Impor halaman baru
import 'package:finance_tracker/pages/get_started_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        // <<< TAMBAHKAN RUTE BARU DI SINI >>>
        '/get_started': (context) => const GetStartedPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
