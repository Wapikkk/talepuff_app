import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';
import '../../view_models/parent_view_model.dart';

class BedtimeStory extends StatelessWidget {
  const BedtimeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final parentVM = context.watch<ParentViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Text
        const Text(
          'Auto Bedtime Story',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const Text(
          'automatically play last stories at certain times',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),

        // Switch Toggle
        Transform.scale(
          scale: 0.8,
          alignment: Alignment.centerLeft,
          child: Switch(
            value: parentVM.isAutoStoryEnabled,
            activeColor: AppColors.darkPurple,
            onChanged: (value) => parentVM.toggleAutoStory(value),
          ),
        ),
        const SizedBox(height: 10),

        // Label Enter Time
        const Text(
          'Enter time',
          style: TextStyle(
            color: AppColors.slideBubble,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 10),

        // Time Input Row
        Row(
          children: [
            _buildTimeBox(parentVM.selectedHour),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.slideBubble,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
            ),
            _buildTimeBox(parentVM.selectedMinute),
            const SizedBox(width: 15),
            _buildAMPMSelector(parentVM),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String text) {
    return Container(
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.dividerLine,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          color: AppColors.darkPurple,
          fontFamily: AppAssets.fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAMPMSelector(ParentViewModel vm) {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.centerLeft,
      child: Container(
        width: 55,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.dividerLine,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: vm.isAM ? 4 : 35,
              left: 4,
              right: 4,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.timeSelection,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Column(
              children: [
                _buildAMPMOption('AM', vm.isAM, () => vm.updateTime(vm.selectedHour, vm.selectedMinute, true)),
                _buildAMPMOption('PM', !vm.isAM, () => vm.updateTime(vm.selectedHour, vm.selectedMinute, false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAMPMOption(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkPurple : Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}