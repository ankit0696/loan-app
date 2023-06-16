import 'package:flutter/material.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/content_box.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BordingPageOne extends StatelessWidget {
  final PageController controller;

  const BordingPageOne({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // use an imahe from assets
            Image.asset(
              'assets/images/bording_page_1.png',
              height: MediaQuery.of(context).size.height * 0.35,
            ),
            const SizedBox(height: 15),
            ContentBox(
              heading: "Easy Loan",
              content:
                  "Cater to all your financial needs with India’s Fastest Loan Provider.",
              onPressed: () {
                // send to next page view
                controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
            const SizedBox(height: 15),
            SmoothPageIndicator(
              controller: controller,
              count: 2,
              effect: const WormEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.white,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width * 0.96,
              // make a round around the skip button
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7A7A7).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // send to next page view
                        controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      child: Row(
                        children: const [
                          Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
