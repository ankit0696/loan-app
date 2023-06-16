import 'package:flutter/material.dart';
import 'package:loan_app/ui/views/bording_screen/bording_pages/bording_page_1.dart';
import 'package:loan_app/ui/views/bording_screen/bording_pages/bording_page_2.dart';
import 'package:loan_app/ui/widgets/app_background.dart';

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  // controller
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: PageView(
        controller: _pageController,
        children: <Widget>[
          BordingPageOne(controller: _pageController),
          BordingPageTwo(controller: _pageController),
        ],
      ),
    );
  }
}
