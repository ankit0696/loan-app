import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final bool isActive;
  final Widget child;
  const CustomCard({super.key, this.isActive = false, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      // padding: const EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
        // color gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isActive ? const Color(0xFFC78E07) : Colors.red.shade600,
            isActive ? const Color(0xFFE7B60B) : Colors.red.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -80,
            right: 20,
            child: ClipRect(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(80.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isActive
                          ? const Color(0xFFF7CF18).withOpacity(0.37)
                          : Colors.red.shade600.withOpacity(0.37),
                      isActive
                          ? const Color(0xFFE7B60B).withOpacity(0.37)
                          : Colors.red.shade200.withOpacity(0.37),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -10,
            child: ClipRect(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(80.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isActive
                          ? const Color(0xFFF7CF18).withOpacity(0.67)
                          : Colors.red.shade600.withOpacity(0.67),
                      isActive
                          ? const Color(0xFFE7B60B).withOpacity(0.67)
                          : Colors.red.shade200.withOpacity(0.67),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(15.0),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Header(
          //               title: formatAmount(loan.amount),
          //               fontSize: 30.0,
          //               color: Colors.white),
          //           Header(
          //               title: loan.date.toIso8601String().split("T")[0],
          //               fontSize: 15.0,
          //               color: Colors.white),
          //         ],
          //       ),
          //       // const Header(
          //       //     title: "₹ 1,00,000", fontSize: 30.0, color: Colors.white),
          //       _loanDetailRow("Principal Left", formatAmount(principleLeft)),
          //       _loanDetailRow("Intrest rate", "${loan.interestRate}%"),
          //       _loanDetailRow("Collateral", loan.collateral),
          //       _loanDetailRow("Intrest Amount", formatAmount(interest)),
          //     ],
          //   ),
          // ),
          child,
        ],
      ),
    );
  }
}
