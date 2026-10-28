import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/auth_result.dart';
import 'view_models/auth/login_view_model.dart';
import 'view_models/navbar_view_model.dart';
import 'view_models/parents/child_info_view_model.dart';
import 'view_models/parents/parent_view_model.dart';
import 'view_models/totem/totem_view_model.dart';
import 'views/child_info/child_info_args.dart';

class AuthFlow {
  AuthFlow._();

  static void proceed(BuildContext context, AuthResult result) {
    debugPrint('[auth] proceed: ${result.runtimeType}');
    switch (result) {
      case SignedIn():
        enterApp(context, result);
      case NeedsProfile():
        Navigator.pushNamed(
          context,
          '/child_info',
          arguments: const ChildInfoArgs(completeProfile: true),
        );
      case AuthFailed():
      case SignedOut():
      case AuthCancelled():
        break;
    }
  }

  static void enterApp(BuildContext context, SignedIn session) {
    context.read<LoginViewModel>().applySession(session);
    context.read<NavbarViewModel>().reset();
    context.read<ChildInfoViewModel>().applyProfile(session.profile);
    context.read<TotemViewModel>().refresh();
    context.read<ParentViewModel>().setInitiateData(
          session.profile.id.toString(),
          session.profile.photoUrl,
          session.profile.name,
        );
    Navigator.pushNamedAndRemoveUntil(context, '/main_nav', (route) => false);
  }

  static Future<void> logout(BuildContext context) async {
    final login = context.read<LoginViewModel>();
    final childInfo = context.read<ChildInfoViewModel>();
    final parent = context.read<ParentViewModel>();
    final totem = context.read<TotemViewModel>();
    final navigator = Navigator.of(context);

    await login.logout();
    childInfo.reset();
    parent.setInitiateData(null, null, null);
    totem.reset();
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
