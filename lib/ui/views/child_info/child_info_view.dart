import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/child_info_view_model.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';
import '../../widgets/child_info/gender_picker.dart';
import '../../widgets/child_info/interest_picker.dart';
import '../../widgets/child_info/name_age_input.dart';
import '../../widgets/child_info/child_info_header.dart';

class ChildInfoView extends StatelessWidget{
  const ChildInfoView ({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();

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

                _buildSaveButton(viewModel, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ChildInfoViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              viewModel.saveInfo(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C39),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
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
      ],
    );
  }
}