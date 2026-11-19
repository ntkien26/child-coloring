import 'package:flutter/material.dart';

import '../core/l10n/app_strings.dart';

enum StickerType {
  star,
  heart,
  crown,
  rainbow,
  flower,
  butterfly,
  sparkle,
  ribbon,
}

extension StickerTypeMeta on StickerType {
  String get label => localizedLabel(AppLanguage.vi);

  String localizedLabel(AppLanguage lang) {
    final en = lang == AppLanguage.en;
    switch (this) {
      case StickerType.star:
        return en ? 'Star' : 'Ngôi sao';
      case StickerType.heart:
        return en ? 'Heart' : 'Trái tim';
      case StickerType.crown:
        return en ? 'Crown' : 'Vương miện';
      case StickerType.rainbow:
        return en ? 'Rainbow' : 'Cầu vồng';
      case StickerType.flower:
        return en ? 'Flower' : 'Bông hoa';
      case StickerType.butterfly:
        return en ? 'Butterfly' : 'Bướm xinh';
      case StickerType.sparkle:
        return en ? 'Sparkle' : 'Lấp lánh';
      case StickerType.ribbon:
        return en ? 'Ribbon' : 'Nơ hồng';
    }
  }

  Color get primaryColor {
    switch (this) {
      case StickerType.star:
        return const Color(0xFFFFCA28);
      case StickerType.heart:
        return const Color(0xFFFF4D6D);
      case StickerType.crown:
        return const Color(0xFFFFB300);
      case StickerType.rainbow:
        return const Color(0xFF42A5F5);
      case StickerType.flower:
        return const Color(0xFFFF70A6);
      case StickerType.butterfly:
        return const Color(0xFFAB47BC);
      case StickerType.sparkle:
        return const Color(0xFF26C6DA);
      case StickerType.ribbon:
        return const Color(0xFFEC407A);
    }
  }
}

class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.type,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  final String id;
  final StickerType type;

  /// Position in SVG coordinate space (0..500).
  final Offset position;
  final double scale;
  final double rotation;

  PlacedSticker copyWith({
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return PlacedSticker(
      id: id,
      type: type,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}
