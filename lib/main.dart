import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/repositories/account_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/authenticated_client.dart';
import 'data/services/auth_gateway.dart';
import 'data/services/auth_service.dart';
import 'data/services/session_store.dart';
import 'ui/view_models/startup_view_model.dart';
import 'ui/views/startup/startup_view.dart';

import '/ui/view_models/navbar_view_model.dart';
import '/ui/views/parent/parent_view.dart';
import 'ui/view_models/parents/parent_view_model.dart';
import 'ui/views/main_navigation_view.dart';

import 'ui/views/landing/landing_view.dart';
import 'ui/view_models/landing_view_model.dart';

import 'ui/views/child_info/child_info_view.dart';
import 'ui/view_models/parents/child_info_view_model.dart';

import 'ui/views/sign_up/signup_view.dart';
import 'ui/view_models/auth/signup_view_model.dart';

import 'ui/views/login/login_view.dart';
import 'ui/view_models/auth/login_view_model.dart';

import 'ui/views/settings/settings_view.dart';
import 'ui/view_models/parents/settings_view_model.dart';

import 'ui/view_models/parents/update_settings_view_model.dart';
import 'ui/views/settings/update_password_view.dart';
import 'ui/views/settings/update_mascot_view.dart';
import 'ui/views/settings/feedback_view.dart';
import 'ui/views/settings/legal_view.dart';
import 'ui/view_models/settings/feedback_view_model.dart';
import 'data/repositories/feedback_repository.dart';
import 'data/repositories/profile_photo_repository.dart';
import 'data/services/profile_photo_service.dart';
import 'data/repositories/legal_repository.dart';
import 'data/services/app_info.dart';
import 'data/services/feedback_service.dart';
import 'ui/views/settings/update_child_name_view.dart';
import 'ui/views/settings/update_email_view.dart';

import 'ui/views/create_story/create_story_view.dart';
import 'ui/view_models/create_story/create_story_view_model.dart';

import 'ui/views/story/story_view.dart';
import 'ui/views/story/story_detail_view.dart';
import 'ui/views/settings/server_address_view.dart';
import 'core/server_address.dart';
import 'data/repositories/story_repository.dart';
import 'data/services/server_check_service.dart';
import 'data/services/story_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await ServerAddress.load();
  final gateway = FirebaseAuthGateway();
  final httpClient = AuthenticatedClient(
    idToken: gateway.idToken,
    baseUrl: () => ServerAddress.baseUrl,
  );
  final api = AuthService(client: httpClient);
  final appInfo = PackageInfoAppInfo();
  final authRepository = AuthRepository(
    gateway: gateway,
    api: api,
    session: SharedPrefsSessionStore(),
  );
  final accountRepository = AccountRepository(gateway: gateway, api: api);
  runApp(
    MultiProvider(
      providers: [
        Provider<http.Client>.value(value: httpClient),
        Provider<ServerChecker>.value(value: ServerCheckService()),
        Provider<AppInfo>.value(value: appInfo),
        Provider<StoryRepository>.value(value: StoryRepository(api: StoryService(client: httpClient))),
        Provider<ProfilePhotoRepository>.value(
          value: ProfilePhotoRepository(api: ProfilePhotoService(client: httpClient)),
        ),
        Provider<LegalRepository>.value(value: LegalRepository()),
        Provider<FeedbackRepository>.value(
          value: FeedbackRepository(api: FeedbackService(client: httpClient), appInfo: appInfo),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedbackViewModel(repository: context.read<FeedbackRepository>()),
        ),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AccountRepository>.value(value: accountRepository),
        ChangeNotifierProvider(create: (_) => NavbarViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(
          create: (context) => ChildInfoViewModel(repository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SignUpViewModel(
            repository: context.read<AuthRepository>(),
            childInfoViewModel: context.read<ChildInfoViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(repository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StartupViewModel(repository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(create: (context) => ParentViewModel(photos: context.read<ProfilePhotoRepository>())),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (context) => UpdateSettingsViewModel(repository: context.read<AccountRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => CreateStoryViewModel()),
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
        '/': (context) => const StartupView(),
        '/landing': (context) => const LandingView(),
        '/child_info': (context) => const ChildInfoView(),
        '/signup': (context) => const SignUpView(),
        '/login': (context) => const LoginView(),
        '/main_nav': (context) => MainNavigationView(),
        '/parent': (context) => const ParentView(),
        '/settings': (context) => const SettingsView(),
        '/update_child_name': (context) => const UpdateChildNameView(),
        '/update_email': (context) => const UpdateEmailView(),
        '/update_password': (context) => const UpdatePasswordView(),
        '/update_mascot': (context) => const UpdateMascotView(),
        '/feedback': (context) => const FeedbackView(),
        '/legal': (context) => const LegalView(),
        '/server_address': (context) => const ServerAddressView(),
        '/story': (context) => const StoryView(),
        '/story_detail': (context) => const StoryDetailView(),
        '/create_story': (context) => const CreateStoryView(),
      },
    );
  }
}