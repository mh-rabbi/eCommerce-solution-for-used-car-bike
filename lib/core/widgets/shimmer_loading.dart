import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge),
        ),
      ),
    );
  }
}

class ShimmerVehicleCard extends StatelessWidget {
  const ShimmerVehicleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(
            height: 200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLarge),
              topRight: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(height: 20, width: 200),
                const SizedBox(height: 8),
                ShimmerCard(height: 16, width: 150),
                const SizedBox(height: 8),
                ShimmerCard(height: 18, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

