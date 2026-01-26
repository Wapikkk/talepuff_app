import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class DailyMoodSelector extends StatefulWidget {
  final String childName;

  const DailyMoodSelector ({
    super.key,
    required this.childName,
  });

  @override
  State<DailyMoodSelector> createState() => _DailyMoodSelectorState();
}

class _DailyMoodSelectorState extends State<DailyMoodSelector> {
  int? _selectedIndex;

  final List<String> _moodAssets = [
    AppAssets.iconSentimentBored,
    AppAssets.iconSentimentDissatisfied,
    AppAssets.iconSentimentNeutral,
    AppAssets.iconSentimentSatisfied,
    AppAssets.iconSentimentExcited,
  ];

  @override
  Widget build(BuildContext build) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How is ${widget.childName}'s mood today?",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
            color: AppColors.darkPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_moodAssets.length, (index){
            return _buildMoodItem(index);
          }),
        ),
      ],
    );
  }

  Widget _buildMoodItem(int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        debugPrint("Mood dipilih: Index $index (Nilai mood: ${index + 1})");
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.5,
          child: Image.asset(
            _moodAssets[index],
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}