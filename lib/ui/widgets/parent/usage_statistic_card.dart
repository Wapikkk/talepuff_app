import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class UsageStatisticCard extends StatelessWidget {
  final String childName;
  final int storiesCount;
  final int minutesCount;
  final int moodCount;

  const UsageStatisticCard({
    super.key,
    required this.childName,
    this.storiesCount = 10,
    this.minutesCount = 30,
    this.moodCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final int totalActive = moodCount + storiesCount + minutesCount;
    final int totalBar = totalActive + 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$childName's listening week overview",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 24,
            width: double.infinity,
            color: AppColors.backgroundOverview,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    _buildBarSegment(
                      width: maxWidth * (totalActive / totalBar),
                      color: AppColors.underline,
                    ),

                    _buildBarSegment(
                      width: maxWidth * ((moodCount + storiesCount) / totalBar),
                      color: AppColors.storiesCount,
                    ),

                    _buildBarSegment(
                      width: maxWidth * (moodCount / totalBar),
                      color: AppColors.adventureBox,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(AppColors.adventureBox, "$moodCount Mood"),
            _buildLegendItem(AppColors.storiesCount, "$storiesCount Stories"),
            _buildLegendItem(AppColors.underline, "$minutesCount Minutes"),
          ],
        ),
      ],
    );
  }

  Widget _buildBarSegment({required double width, required Color color}) {
    return Container(
      width: width,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(15),
          left: Radius.zero,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ],
    );
  }
}