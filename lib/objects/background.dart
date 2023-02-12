import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

import '../assets.dart' as Assets;
import '../game.dart';

class ParallaxBackground extends ParallaxComponent<PlatformerGame> {
  Vector2 _lastCameraPosition = Vector2.zero();

  ParallaxBackground({required super.size});

  @override
  Future<void> onLoad() async {
    final clouds = await game.loadParallaxLayer(
      ParallaxImageData(Assets.CLOUDS),
      velocityMultiplier: Vector2(1, 0),
      fill: LayerFill.none,
      alignment: Alignment.topCenter,
    );

    final mist = await game.loadParallaxLayer(
      ParallaxImageData(Assets.MIST),
      velocityMultiplier: Vector2(2, 0),
      fill: LayerFill.none,
      alignment: Alignment.bottomCenter,
    );

    final hills = await game.loadParallaxLayer(
      ParallaxImageData(Assets.HILLS),
      velocityMultiplier: Vector2(3, 0),
      fill: LayerFill.none,
      alignment: Alignment.bottomCenter,
    );

    positionType = PositionType.viewport;
    parallax = Parallax(
      [clouds, mist, hills],
      baseVelocity: Vector2.zero(),
    );
  }

  @override
  void update(double dt) {
    final cameraPosition = gameRef.camera.position;
    final baseVelocity = (cameraPosition - _lastCameraPosition) * 10;
    parallax!.baseVelocity.setFrom(baseVelocity);
    _lastCameraPosition.setFrom(gameRef.camera.position);
    super.update(dt);
  }
}
