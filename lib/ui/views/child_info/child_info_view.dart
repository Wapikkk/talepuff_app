import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_flow.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';
import '../../widgets/child_info/gender_picker.dart';
import '../../widgets/child_info/interest_picker.dart';
import '../../widgets/child_info/name_age_input.dart';
import '../../widgets/child_info/child_info_header.dart';
import 'child_info_args.dart';

class ChildInfoView extends StatelessWidget{
  const ChildInfoView ({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();
    final args = ModalRoute.of(context)?.settings.arguments;
    final completeProfile = args is ChildInfoArgs && args.completeProfile;

    return Scaffold(
      backgroundColor: AppColors.darkPurple,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ChildInfoHeader(),
                const SizedBox(height: 30),

                const Text(
                    "Basic Info",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppAssets.fontFamily,
                    ),
                ),
                const SizedBox(height: 20),

                const NameAgeInput(), // Widget 1
                const SizedBox(height: 40),

                const GenderPicker(), // Widget 2
                const SizedBox(height: 40),

                const InterestPicker(), // Widget 3
                const SizedBox(height: 60),

                _buildSaveButton(viewModel, context, completeProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ChildInfoViewModel viewModel, BuildContext context, bool completeProfile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (!completeProfile) {
                      viewModel.saveInfo(context);
                      return;
                    }
                    final result = await viewModel.completeProfile();
                    if (!context.mounted || result == null) return;
                    AuthFlow.proceed(context, result);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C39),
              disabledBackgroundColor: const Color(0xFFFF8C39).withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                : Text(
                    completeProfile ? "Save & Continue" : "Save",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppAssets.fontFamily,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: viewModel.errorMessage != null ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    viewModel.errorMessage ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppAssets.fontFamily,
                    ),
                  ),
                ),
              ],
            )
          ),
        ),

        if (completeProfile)
          TextButton(
            onPressed: viewModel.isLoading ? null : () => AuthFlow.logout(context),
            child: Text(
              "Use a different account",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontFamily: AppAssets.fontFamily,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
