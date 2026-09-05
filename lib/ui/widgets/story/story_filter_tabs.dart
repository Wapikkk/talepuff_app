import 'package:flutter/material.dart';

class StoryFilterTabs extends StatelessWidget{
  const StoryFilterTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5D9F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Recent",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text("Favorites", style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 16),
            const Text("Popular", style: TextStyle(color: Colors.white70)),
          ],
        ),
        const Icon(Icons.search, color: Colors.white),
      ],
    );
  }
}