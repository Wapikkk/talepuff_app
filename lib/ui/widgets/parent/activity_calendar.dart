import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class ActivityCalendar extends StatelessWidget {
  const ActivityCalendar ({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> weekDays = [
      {'day': 'SUN', 'date': '4', 'color': const Color(0xFFD32F2F)},
      {'day': 'MON', 'date': '5', 'color': const Color(0xFF00D1B2)},
      {'day': 'TUE', 'date': '6', 'color': const Color(0xFFFF8A00)},
      {'day': 'WED', 'date': '7', 'color': const Color(0xFFD32F2F)},
      {'day': 'THU', 'date': '8', 'isToday': true},
      {'day': 'FRI', 'date': '9', 'color': null},
      {'day': 'SAT', 'date': '10', 'color': null},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "This Week",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.black26,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((data) => _buildDayItem(data)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayItem(Map<String, dynamic> data) {
    bool isToday = data['isToday'] ?? false;

    return Column(
      children: [
        Text(
          data['day'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? AppColors.darkPurple : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            data['date'],
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : AppColors.darkPurple,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (!isToday && data['color'] != null)
          Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          const SizedBox(height: 3),
      ],
    );
  }
}