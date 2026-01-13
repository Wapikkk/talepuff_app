import 'package:flutter/material.dart';
import 'ui/views/landing/landing_view.dart';
import 'ui/views/main_navigation_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalePuff',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingView(),
        '/main_nav': (context) => const MainNavigationView(),
      },
    );
  }
}