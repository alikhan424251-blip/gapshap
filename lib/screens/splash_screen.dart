import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'phone_auth_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = _auth.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const HomeScreen() : const PhoneAuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B8A5F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('G', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF0B8A5F))),
              ),
            ),
            const SizedBox(height: 20),
            const Text('GapShap',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Pakistan ki apni chat app',
                style: TextStyle(fontSize: 15, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
