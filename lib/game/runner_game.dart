import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ground.dart';
import 'obstacle.dart';
import 'player.dart';

class RunnerGame extends FlameGame
    with HasCollisionDetection, TapDetector {
  late Player player;
  late ScrollingGround ground;
  late TextComponent scoreText;
  late TextComponent messageText;

  final Random _random = Random();

  double groundY = 0;
  double baseSpeed = 260;
  double speed = 260;
  double score = 0;
  double _spawnTimer = 0;
  double _nextSpawnAt = 1.4;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    groundY = size.y * 0.75;

    ground = ScrollingGround(groundY: groundY, speed: speed)
      ..size = size
      ..position = Vector2.zero();
    add(ground);

    player = Player(groundY: groundY);
    add(player);

    scoreText = TextComponent(
      text: 'Alama: 0',
      position: Vector2(16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    messageText = TextComponent(
      text: '',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(messageText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    score += speed * dt * 0.05;
    scoreText.text = 'Alama: ${score.toInt()}';

    // Slowly ramp difficulty.
    speed = baseSpeed + score * 0.6;
    ground.speed = speed;

    _spawnTimer += dt;
    if (_spawnTimer >= _nextSpawnAt) {
      _spawnTimer = 0;
      _nextSpawnAt = 1.0 + _random.nextDouble() * 1.2;
      add(Obstacle(groundY: groundY, speed: speed));
    }

    // Manual collision check (simple, avoids extra hitbox callback wiring).
    for (final obstacle in children.whereType<Obstacle>()) {
      final playerRect = Rect.fromLTWH(
        player.x - player.width * player.anchor.x,
        player.y - player.height,
        player.width,
        player.height * 0.9,
      );
      final obstacleRect = Rect.fromLTWH(
        obstacle.x - obstacle.width * obstacle.anchor.x,
        obstacle.y - obstacle.height,
        obstacle.width,
        obstacle.height,
      );
      if (playerRect.overlaps(obstacleRect)) {
        _gameOver();
        break;
      }
    }
  }

  void _gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    player.die();
    messageText.text = 'Umepoteza!\nAlama: ${score.toInt()}\nGusa kuanza tena';
  }

  void _restart() {
    isGameOver = false;
    score = 0;
    speed = baseSpeed;
    _spawnTimer = 0;
    messageText.text = '';
    player.reset();
    children.whereType<Obstacle>().toList().forEach((o) => o.removeFromParent());
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver) {
      _restart();
    } else {
      player.jump();
    }
  }
}
