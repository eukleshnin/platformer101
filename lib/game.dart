import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'actors/theboy.dart';
import 'assets.dart' as Assets;

class PlatformerGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Future<void> onLoad() async {
    await images.loadAll(Assets.SPRITES);

    final theBoy = TheBoy(
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(theBoy);
  }
}
