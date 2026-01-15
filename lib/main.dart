import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/views/main_navigation_view.dart';

import 'ui/views/landing/landing_view.dart';
import 'ui/view_models/landing_view_model.dart';

import 'ui/views/child_info/child_info_view.dart';
import 'ui/view_models/child_info_view_model.dart';

import 'ui/views/sign_up/signup_view.dart';
import 'ui/view_models/signup_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => ChildInfoViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/child_info': (context) => const ChildInfoView(),
        '/signup': (context) => const SignUpView(),
        '/main_nav': (context) => const MainNavigationView(),
      },
    );
  }
}