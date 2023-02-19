import 'package:flame/components.dart';
import 'package:platformer101/game.dart';

import '../assets.dart' as Assets;

class Hud extends PositionComponent with HasGameRef<PlatformerGame> {
  Hud() {
    positionType = PositionType.viewport;
  }

  void onCoinsNumberUpdated(int total) {
    final coin = SpriteComponent.fromImage(game.images.fromCache(Assets.HUD),
        position: Vector2((50 * total).toDouble(), 50), size: Vector2.all(48));
    add(coin);
  }
}
