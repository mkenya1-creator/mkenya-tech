import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  Player({required this.groundY}) : super(size: Vector2(70, 90), anchor: Anchor.bottomCenter);

  final double groundY;

  static const double gravity = 2200;
  static const double jumpSpeed = -820;

  double velocityY = 0;
  bool isOnGround = true;
  bool isDead = false;

  Sprite? _idleSprite;
  Sprite? _runSprite1;
  Sprite? _runSprite2;
  Sprite? _jumpSprite;

  double _animTimer = 0;
  bool _showFrame1 = true;

  @override
  Future<void> onLoad() async {
    position = Vector2(90, groundY);
    add(RectangleHitbox(size: Vector2(56, 82), position: Vector2(7, 8)));

    // Try to load your own sprites. If they're missing, we fall back to a
    // placeholder box so the game still runs while you prepare the art.
    // Drop files named exactly like this into assets/images/:
    //   player_idle.png, player_run1.png, player_run2.png, player_jump.png
    try {
      _idleSprite = await Sprite.load('player_idle.png');
      _runSprite1 = await Sprite.load('player_run1.png');
      _runSprite2 = await Sprite.load('player_run2.png');
      _jumpSprite = await Sprite.load('player_jump.png');
    } catch (_) {
      // No sprites yet — placeholder rendering will be used instead.
    }
  }

  void jump() {
    if (isOnGround && !isDead) {
      velocityY = jumpSpeed;
      isOnGround = false;
    }
  }

  void die() {
    isDead = true;
  }

  void reset() {
    isDead = false;
    velocityY = 0;
    isOnGround = true;
    position = Vector2(90, groundY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    velocityY += gravity * dt;
    y += velocityY * dt;

    if (y >= groundY) {
      y = groundY;
      velocityY = 0;
      isOnGround = true;
    }

    if (isOnGround) {
      _animTimer += dt;
      if (_animTimer > 0.12) {
        _animTimer = 0;
        _showFrame1 = !_showFrame1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _currentSprite();
    if (sprite != null) {
      sprite.render(canvas, size: size);
      return;
    }
    _renderPlaceholder(canvas);
  }

  Sprite? _currentSprite() {
    if (!isOnGround) return _jumpSprite ?? _idleSprite;
    return _showFrame1 ? (_runSprite1 ?? _idleSprite) : (_runSprite2 ?? _idleSprite);
  }

  void _renderPlaceholder(Canvas canvas) {
    final bodyPaint = Paint()..color = isDead ? Colors.grey : const Color(0xFF6C3EF4);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      bodyPaint,
    );

    // Simple face so it reads as "a character" until real art is dropped in.
    final facePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.25), 5, facePaint);
    canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.25), 5, facePaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'WEWE',
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.x / 2 - textPainter.width / 2, size.y * 0.55));
  }
}
