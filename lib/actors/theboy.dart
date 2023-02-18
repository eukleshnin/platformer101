import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../assets.dart' as Assets;
import '../game.dart';

class TheBoy extends SpriteAnimationComponent
    with KeyboardHandler, HasGameRef<PlatformerGame> {
  final double _moveSpeed = 300;

  int _horizontalDirection = 0;
  final Vector2 _velocity = Vector2.zero();

  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _idleAnimation;

  TheBoy({
    required super.position,
  }) : super(size: Vector2.all(48), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    _idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.THE_BOY),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(20),
        stepTime: 0.12,
      ),
    );

    _runAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.THE_BOY),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(20),
        stepTime: 0.12,
      ),
    );

    animation = _idleAnimation;
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _horizontalDirection = 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (doesReachLeftEdge() || doesReachRightEdge()) {
      _velocity.x = 0;
    } else {
      _velocity.x = _horizontalDirection * _moveSpeed;
    }

    position += _velocity * dt;

    if ((_horizontalDirection < 0 && scale.x > 0) ||
        (_horizontalDirection > 0 && scale.x < 0)) {
      flipHorizontally();
    }

    updateAnimation();
  }

  void updateAnimation() {
    if (_horizontalDirection == 0) {
      animation = _idleAnimation;
    } else {
      animation = _runAnimation;
    }
  }

  bool doesReachLeftEdge() {
    return position.x <= size.x / 2 && _horizontalDirection < 0;
  }

  bool doesReachRightEdge() {
    return position.x >= game.mapWidth - size.x / 2 && _horizontalDirection > 0;
  }
}
