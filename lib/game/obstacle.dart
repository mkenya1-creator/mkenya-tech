import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent with HasGameReference, CollisionCallbacks {
  Obstacle({required double groundY, required this.speed})
      : super(
          size: Vector2(40, 55),
          anchor: Anchor.bottomCenter,
          position: Vector2(420, groundY),
        );

  final double speed;
  bool scored = false;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;
    if (x < -60) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFE0483E);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
  }
}
