import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../assets.dart' as Assets;
import '../game.dart';
import '../objects/platform.dart';

class TheBoy extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<PlatformerGame> {
  final double _moveSpeed = 300;
  final double _jumpSpeed = 500;

  int _horizontalDirection = 0;
  bool _hasJumped = false;

  final Vector2 _velocity = Vector2.zero();
  final double _maxGravitySpeed = 300;
  final double _gravity = 15;

  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _fallAnimation;

  final Vector2 up = Vector2(0, -1);
  final Vector2 down = Vector2(0, 1);
  Component? _standingOn;

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

    _jumpAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.THE_BOY),
      SpriteAnimationData.range(
        start: 4,
        end: 4,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    _fallAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.THE_BOY),
      SpriteAnimationData.range(
        start: 5,
        end: 5,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    animation = _idleAnimation;

    add(CircleHitbox());
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

    _hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

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
    _velocity.y += _gravity;

    if (_hasJumped) {
      if (_standingOn != null) {
        _velocity.y = -_jumpSpeed;
      }
      _hasJumped = false;
    }

    _velocity.y = _velocity.y.clamp(-_jumpSpeed, _maxGravitySpeed);

    position += _velocity * dt;

    if ((_horizontalDirection < 0 && scale.x > 0) ||
        (_horizontalDirection > 0 && scale.x < 0)) {
      flipHorizontally();
    }

    updateAnimation();
  }

  void updateAnimation() {
    if (_standingOn != null) {
      if (_horizontalDirection == 0) {
        animation = _idleAnimation;
      } else {
        animation = _runAnimation;
      }
    } else {
      if (_velocity.y > 0) {
        animation = _fallAnimation;
      } else {
        animation = _jumpAnimation;
      }
    }
  }

  bool doesReachLeftEdge() {
    return position.x <= size.x / 2 && _horizontalDirection < 0;
  }

  bool doesReachRightEdge() {
    return position.x >= game.mapWidth - size.x / 2 && _horizontalDirection > 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionVector = absoluteCenter - mid;
        double penetrationDepth = (size.x / 2) - collisionVector.length;

        collisionVector.normalize();
        if (up.dot(collisionVector) > 0.9) {
          _standingOn = other;
        } else if (down.dot(collisionVector) > 0.9) {
          _velocity.y += _gravity;
        }

        position += collisionVector.scaled(penetrationDepth);
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other == _standingOn) {
      _standingOn = null;
    }
    super.onCollisionEnd(other);
  }
}
