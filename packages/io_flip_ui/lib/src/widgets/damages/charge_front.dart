import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:io_flip_ui/io_flip_ui.dart';
import 'package:provider/provider.dart';

/// {@template charge_front}
/// A widget that renders a [SpriteAnimation] for the charge effect in the back
/// of the card.
/// {@endtemplate}
class ChargeFront extends StatelessWidget {
  /// {@macro charge_front}
  const ChargeFront(
    this.path, {
    required this.size,
    required this.assetSize,
    super.key,
    this.onComplete,
  });

  /// The size of the card.
  final GameCardSize size;

  /// Optional callback to be called when the animation is complete.
  final VoidCallback? onComplete;

  /// Path of the asset containing the sprite sheet.
  final String path;

  /// Size of the assets to use, large or small
  final AssetSize assetSize;

  @override
  Widget build(BuildContext context) {
    final images = context.read<Images>();
    final height = 1.532 * size.height;
    final width = 1.89 * size.width;

    return SizedBox(
      height: height,
      width: width,
      child: SpriteAnimationWidget.asset(
        path: path,
        images: images,
        anchor: Anchor.center,
        onComplete: onComplete,
        data: SpriteAnimationData.sequenced(
          amount: 20,
          amountPerRow: 5,
          textureSize: assetSize == AssetSize.large
              ? Vector2(658, 860)
              : Vector2(395, 516),
          stepTime: 0.04,
          loop: false,
        ),
      ),
    );
  }
}