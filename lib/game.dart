import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:platformer101/hud.dart';

import 'actors/theboy.dart';
import 'assets.dart' as Assets;
import 'objects/background.dart';
import 'objects/coin.dart';
import 'objects/platform.dart';

class PlatformerGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final double mapWidth;
  late final double mapHeight;

  int _coins = 0;
  late int _totalCoins;
  late final Hud hud;

  @override
  Future<void> onLoad() async {
    await images.loadAll(Assets.SPRITES);

    final level = await TiledComponent.load("level1.tmx", Vector2.all(64));

    mapWidth = level.tileMap.map.width * level.tileMap.destTileSize.x;
    mapHeight = level.tileMap.map.height * level.tileMap.destTileSize.y;

    add(ParallaxBackground(size: Vector2(mapWidth, mapHeight)));
    add(level);
    spawnObjects(level.tileMap);

    final theBoy = TheBoy(
      position: Vector2(128, mapHeight - 64),
    );
    add(theBoy);

    camera.viewport = FixedResolutionViewport(Vector2(1920, 1280));
    camera.zoom = 2;
    camera.followComponent(theBoy,
        worldBounds: Rect.fromLTWH(0, 0, mapWidth, mapHeight));

    hud = Hud();
    add(hud);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 69, 186, 230);
  }

  void spawnObjects(RenderableTiledMap tileMap) {
    final platforms = tileMap.getLayer<ObjectGroup>("Platforms");

    for (final platform in platforms!.objects) {
      add(Platform(Vector2(platform.x, platform.y),
          Vector2(platform.width, platform.height)));
    }

    final coins = tileMap.getLayer<ObjectGroup>("Coins");

    for (final coin in coins!.objects) {
      add(Coin(Vector2(coin.x, coin.y)));
    }
    _totalCoins = coins.objects.length;
  }

  void onCoinCollected() {
    _coins++;
    hud.onCoinsNumberUpdated(_coins);

    if (_coins == _totalCoins) {
      final text = TextComponent(
        text: 'U WIN!',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 200,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.center,
        position: camera.viewport.effectiveSize / 2,
      )..positionType = PositionType.viewport;
      add(text);
      Future.delayed(Duration(milliseconds: 200), () => {pauseEngine()});
    }
  }
}
