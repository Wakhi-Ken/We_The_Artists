// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnimatedGradientAvatar extends StatefulWidget {
  final String initials;
  final double size;
  final List<Color> gradientColors;

  const AnimatedGradientAvatar({
    super.key,
    required this.initials,
    required this.size,
    required this.gradientColors,
  });

  @override
  State<AnimatedGradientAvatar> createState() => _AnimatedGradientAvatarState();
}

class _AnimatedGradientAvatarState extends State<AnimatedGradientAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_animation.value * 0.5),
            ),
            borderRadius: BorderRadius.circular(widget.size * 0.25),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.size * 0.35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
