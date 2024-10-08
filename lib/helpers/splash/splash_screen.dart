import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemini_ai_app_flutter/ai/ui/standart_ai/eren_ai_standart.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 4),
      () => Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const CoffeeAiScreen())),
    );

    return Scaffold(
      body: Image.asset("lib/assets/logo.webp"),
    );
  }
}
