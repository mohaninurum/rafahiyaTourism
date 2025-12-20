import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final SpinKitType spinKitType;

  const CustomCircularProgressIndicator({
    super.key,
    this.size = 50.0,
    this.color = Colors.blue,
    this.spinKitType = SpinKitType.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildSpinKit(spinKitType),
    );
  }

  Widget _buildSpinKit(SpinKitType type) {
    switch (type) {
      case SpinKitType.circle:
        return SpinKitCircle(
          color: color,
          size: size,
        );
      case SpinKitType.chasingDots:
        return SpinKitChasingDots(
          color: color,
          size: size,
        );
      case SpinKitType.fadingCube:
        return SpinKitFadingCube(
          color: color,
          size: size,
        );
      case SpinKitType.ripple:
        return SpinKitRipple(
          color: color,
          size: size,
        );
      case SpinKitType.doubleBounce:
        return SpinKitDoubleBounce(
          color: color,
          size: size,
        );
      default:
        return SpinKitCircle(
          color: color,
          size: size,
        );
    }
  }
}

enum SpinKitType {
  circle,
  chasingDots,
  fadingCube,
  ripple,
  doubleBounce,
}
