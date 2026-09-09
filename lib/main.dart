import 'package:flutter/material.dart';
import 'views/dashboard_view.dart';

void main() {
  runApp(const ArkasApp());
}

class ArkasApp extends StatelessWidget {
  const ArkasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARKAS SD Zainul Hasan Genggong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const DashboardView(),
    );
  }
}