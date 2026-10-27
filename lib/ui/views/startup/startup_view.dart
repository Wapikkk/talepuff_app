import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/auth_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../auth_flow.dart';
import '../../view_models/startup_view_model.dart';
import '../../widgets/app_background.dart';
import '../child_info/child_info_args.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final result = await context.read<StartupViewModel>().restore();
    if (!mounted) return;

    switch (result) {
      case SignedIn():
        AuthFlow.enterApp(context, result);
      case NeedsProfile():
        Navigator.pushReplacementNamed(
          context,
          '/child_info',
          arguments: const ChildInfoArgs(completeProfile: true),
        );
      case SignedOut():
      Navigator.pushReplacementNamed(context, '/landing');
      case AuthFailed():
      case AuthCancelled():
      break;
    }
  }

  Future<void> _changeServer() async {
    await Navigator.pushNamed(context, '/server_address');
    if (mounted) _start();
  }

  Future<void> _signOut() async {
    final viewModel = context.read<StartupViewModel>();
    final navigator = Navigator.of(context);
    await viewModel.signOut();
    navigator.pushReplacementNamed('/landing');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StartupViewModel>();
    final l10n = AppLocalizations.of(context);
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: AppAssets.fontFamily,
    );

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: viewModel.error == null
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.appMessage(viewModel.error!), textAlign: TextAlign.center, style: textStyle),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _start,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnSave),
                        child: Text(l10n.tryAgain, style: const TextStyle(color: Colors.white)),
                      ),
                      if (viewModel.canChangeServer)
                        TextButton(
                          key: const Key('change-server'),
                          onPressed: _changeServer,
                          child: Text(l10n.changeServerAddress, style: textStyle),
                        ),
                      TextButton(
                        onPressed: _signOut,
                        child: Text(l10n.useDifferentAccount, style: textStyle),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
