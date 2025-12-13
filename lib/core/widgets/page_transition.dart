import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmoothPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeInOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class SlidePageTransition extends CustomTransition {
  final bool fromRight;

  SlidePageTransition({this.fromRight = true});

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(fromRight ? 1.0 : -1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeInOutCubic,
        ),
      ),
      child: child,
    );
  }
}

