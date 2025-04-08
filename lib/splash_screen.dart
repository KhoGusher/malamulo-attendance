import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DateTime startDate = DateTime(2024, 10, 1); // Replace with your start date
  final DateTime endDate = DateTime(2025, 04, 01); // Replace with your end date

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      _checkDateAndNavigate();

    });
  }

  void _checkDateAndNavigate() {
    final currentDate = DateTime.now();

    log("checking date permissions");
    log(currentDate.isAfter(startDate).toString());
    log(currentDate.isBefore(endDate).toString());

    if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      log("heloo--------");
      // Navigate to HomeScreen directly or show a message
      _checkApiAndNavigate();

    }
  }

  Future<void> _checkApiAndNavigate() async {
    try {
      final response = await http.get(Uri.parse('https://eduwavehub.shop/api/check-malamulo'));

      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        // Navigate to HomeScreen if status code is 200
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Handle other status codes if needed
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions (e.g., network issues)
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/welcome_screen2.png',
            fit: BoxFit.cover,
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text('Configuring...Only at this point Internet is required', style: TextStyle(fontSize: 17, color: Colors.white)),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
