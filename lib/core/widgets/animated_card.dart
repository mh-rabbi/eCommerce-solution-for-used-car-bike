import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_theme.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final int index;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.index = 0,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: widget.margin ?? const EdgeInsets.all(AppTheme.spacingMD),
          padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: widget.color ?? AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: widget.elevation != null
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: widget.elevation! * 2,
                      offset: Offset(0, widget.elevation!),
                    ),
                  ]
                : AppTheme.shadow2,
          ),
          child: widget.child,
        ),
      ),
    );

    // Wrap with staggered animation if index is provided
    if (widget.index > 0) {
      return AnimationConfiguration.staggeredList(
        position: widget.index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

