import 'package:flutter/material.dart';
import 'package:rafahiyatourism/const/color.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundColor1,
                AppColors.backgroundColor2,
                AppColors.backgroundColor3,
              ],
              stops: [1, 1, 1.0],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 1.0,
              colors: [
                AppColors.backgroundColor4,
                AppColors.backgroundColor7,
              ],
              stops: [0.1, 1.0],
            ),
          ),
        ),

        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2,
              colors: [
                AppColors.backgroundColor6,
                AppColors.backgroundColor7,
              ],
              stops: [0.3, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
