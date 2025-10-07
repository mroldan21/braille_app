import 'package:flutter/material.dart';
import '../../../data/models/braille_character.dart';

class BrailleDisplay extends StatefulWidget {
  final BrailleCharacter? character;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const BrailleDisplay({
    super.key,
    this.character,
    this.size = 200,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<BrailleDisplay> createState() => _BrailleDisplayState();
}

class _BrailleDisplayState extends State<BrailleDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(BrailleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.character?.points ??
        [false, false, false, false, false, false];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size * 1.5,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDot(points[0], 1),
                  _buildDot(points[3], 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDot(points[1], 2),
                  _buildDot(points[4], 5),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDot(points[2], 3),
                  _buildDot(points[5], 6),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(bool isActive, int number) {
    final dotSize = widget.size / 4;
    final scale = isActive ? 1.0 : 0.7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: dotSize * scale * _animation.value + dotSize * (1 - _animation.value) * 0.7,
      height: dotSize * scale * _animation.value + dotSize * (1 - _animation.value) * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? widget.activeColor : widget.inactiveColor.withOpacity(0.3),
        border: Border.all(
          color: isActive ? widget.activeColor : widget.inactiveColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : widget.inactiveColor,
            fontSize: dotSize / 3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}