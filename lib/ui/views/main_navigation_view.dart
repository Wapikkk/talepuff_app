import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/views/home/home_view.dart';
import 'package:talepuff_app/ui/widgets/bottom_navbar.dart';

class MainNavigationView extends StatelessWidget{
  const MainNavigationView ({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const Center(child: Text("Story Page")),
      const Center(child: Text("Create Page")),
      const Center(child: Text("Parents Page")),
    ];

    return Consumer<NavbarViewModel>(
      builder: (context, navVM, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          body: pages[navVM.currentIndex],
          bottomNavigationBar: BottomNavbar(
            currentIndex: navVM.currentIndex,
            onTap: (index) {
              navVM.changeIndex(index);
            },
          ),
        );
      },
    );
  }
}