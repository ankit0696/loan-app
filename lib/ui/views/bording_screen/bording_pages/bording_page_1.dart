import 'package:flutter/material.dart';
import 'package:loan_app/ui/widgets/content_box.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BordingPageOne extends StatelessWidget {
  final PageController controller;

  const BordingPageOne({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2C94C),
              Color(0xFFE7C440),
              Color(0xFFD9B136),
              Color(0xFFC9940E),
            ],
          ),
        ),
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
                )),

            Container(
              margin: const EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width * 0.96,
              // make a round around the skip button
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
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
