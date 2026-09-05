import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '/ui/view_models/home_view_model.dart';
import '/ui/view_models/navbar_view_model.dart';
import '/ui/views/parent/parent_view.dart';
import '/ui/view_models/parent_view_model.dart';
import 'ui/views/main_navigation_view.dart';

import 'ui/views/landing/landing_view.dart';
import 'ui/view_models/landing_view_model.dart';

import 'ui/views/child_info/child_info_view.dart';
import 'ui/view_models/child_info_view_model.dart';

import 'ui/views/sign_up/signup_view.dart';
import 'ui/view_models/signup_view_model.dart';

import 'ui/views/login/login_view.dart';
import 'ui/view_models/login_view_model.dart';

import 'ui/views/settings/settings_view.dart';
import 'ui/view_models/settings_view_model.dart';

import 'ui/view_models/update_settings_view_model.dart';
import 'ui/views/settings/update_password_view.dart';
import 'ui/views/settings/update_child_name_view.dart';
import 'ui/views/settings/update_email_view.dart';

import 'ui/views/create_story/create_story_view.dart';
import 'ui/view_models/create_story_view_model.dart';

import 'ui/views/story/story_view.dart';
import 'ui/view_models/story_view_model.dart';

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
        ChangeNotifierProvider(create: (_) => ParentViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => CreateStoryViewModel()),
        ChangeNotifierProvider(create: (_) => StoryViewModel()),
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
        '/parent': (context) => const ParentView(),
        '/settings': (context) => const SettingsView(),
        '/update_child_name': (context) => const UpdateChildNameView(),
        '/update_email': (context) => const UpdateEmailView(),
        '/update_password': (context) => const UpdatePasswordView(),
        '/story': (context) => const StoryView(),
        '/create_story': (context) => const CreateStoryView(),
      },
    );
  }
}