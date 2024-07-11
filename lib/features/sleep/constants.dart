import 'package:flutter/material.dart';

const kBackgroundColor = Color.fromARGB(255, 23, 27, 73);
const kCardColor = Color.fromARGB(255, 79, 69, 133);
const kPrimaryTextColor = Color.fromARGB(255, 104, 203, 233);
const kSecondaryTextColor = Color.fromARGB(255, 156, 156, 156);
const kDividerColor = Colors.grey;

class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final BoxShadow boxShadow;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.boxShadow,
  });

  @override
  _AnimatedGradientContainerState createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 110, 14, 134),
      end: const Color.fromARGB(255, 182, 190, 197),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? const Color.fromARGB(255, 243, 13, 13),
                const Color.fromARGB(255, 39, 189, 216),
                const Color.fromARGB(255, 70, 18, 192)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: widget.borderRadius,
            boxShadow: [widget.boxShadow],
          ),
          padding: widget.padding,
          height: widget.height,
          width: widget.width,
          child: widget.child,
        );
      },
    );
  }
}
