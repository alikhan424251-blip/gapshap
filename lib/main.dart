import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GapShapApp());
}

class GapShapApp extends StatelessWidget {
  const GapShapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GapShap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B8A5F), // GapShap green
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
