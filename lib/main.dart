import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:talepuff_app/ui/view_models/home_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'ui/views/main_navigation_view.dart';

import 'ui/views/landing/landing_view.dart';
import 'ui/view_models/landing_view_model.dart';

import 'ui/views/child_info/child_info_view.dart';
import 'ui/view_models/child_info_view_model.dart';

import 'ui/views/sign_up/signup_view.dart';
import 'ui/view_models/signup_view_model.dart';

import 'ui/views/login/login_view.dart';
import 'ui/view_models/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavbarViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ChildInfoViewModel()),
        ChangeNotifierProxyProvider<ChildInfoViewModel, SignUpViewModel>(
          create: (context) => SignUpViewModel(
            childInfoViewModel: Provider.of<ChildInfoViewModel>(context, listen: false),
          ),
          update: (context, childInfo, signUp){
            return SignUpViewModel(childInfoViewModel: childInfo);
          },
        ),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
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
        '/login': (context) => const LoginView(),
        '/main_nav': (context) => MainNavigationView(),
      },
    );
  }
}