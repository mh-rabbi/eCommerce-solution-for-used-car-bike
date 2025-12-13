import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.backgroundColor == null
                ? AppTheme.primaryGradient
                : null,
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.shadow2,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

