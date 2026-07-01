import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScrollingGround extends PositionComponent {
  ScrollingGround({required this.groundY, required this.speed});

  final double groundY;
  double speed;
  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset -= speed * dt;
    if (_offset <= -40) _offset += 40;
  }

  @override
  void render(Canvas canvas) {
    final skyPaint = Paint()..color = const Color(0xFFBFE3F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, groundY), skyPaint);

    final groundPaint = Paint()..color = const Color(0xFF3E8E4C);
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.x, size.y - groundY), groundPaint);

    final stripePaint = Paint()..color = const Color(0xFF356F3D);
    for (double x = _offset; x < size.x; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, groundY, 20, 6), stripePaint);
    }
  }
}
