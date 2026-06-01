import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class ShiftReportShimmer extends StatelessWidget {
  const ShiftReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomShimmer.circular(width: 100, height: 100),
          const SizedBox(height: 24),
          CustomShimmer.rectangular(
            width: 300,
            height: 24,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 40),
          CustomShimmer.rectangular(
            width: 600,
            height: 400,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}