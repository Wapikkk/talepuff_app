import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget{
  final String title;
  const StoryCard({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7E4),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFA594F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image, color: Colors.white54, size: 40)),
                  Positioned(
                    top: 8, left: 8,
                    child: Icon(Icons.favorite, color: Colors.white.withOpacity(0.8), size: 20),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("7 min ago", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}