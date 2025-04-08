import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the SplashScreen
import 'qr_scanner.dart';
import 'excel_exporter.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MALAMULO Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with the SplashScreen
    );
  }
}
