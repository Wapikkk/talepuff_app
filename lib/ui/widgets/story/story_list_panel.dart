import 'package:flutter/material.dart';
import 'story_filter_tabs.dart';
import 'story_card.dart';

class StoryListPanel extends StatelessWidget {
  const StoryListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF231F40),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const StoryFilterTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final titles = ["The Sleeping Cloud", "Aira's Brave Journey", "Light in The Forest", "The Sleeping Cloud"];
                return StoryCard(title: titles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}