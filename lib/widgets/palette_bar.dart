import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/color_palette.dart';
import '../core/l10n/app_strings.dart';
import '../models/colorable_region.dart';
import '../models/game_theme.dart';
import '../models/placed_sticker.dart';
import '../providers/locale_provider.dart';
import 'coloring_canvas.dart';
import 'game_ui_kit.dart';

class PaletteBar extends ConsumerStatefulWidget {
  const PaletteBar({
    super.key,
    required this.theme,
    required this.selectedColor,
    required this.selectedPattern,
    required this.toolMode,
    required this.selectedStickerType,
    required this.onColorSelected,
    required this.onPatternSelected,
    required this.onStickerSelected,
    this.isTabletSidebar = false,
  });

  final GameTheme theme;
  final Color selectedColor;
  final BrushPattern selectedPattern;
  final ColoringToolMode toolMode;
  final StickerType selectedStickerType;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<BrushPattern> onPatternSelected;
  final ValueChanged<StickerType> onStickerSelected;
  final bool isTabletSidebar;

  @override
  ConsumerState<PaletteBar> createState() => _PaletteBarState();
}

class _PaletteBarState extends ConsumerState<PaletteBar> {
  int _activeTab = 0; // 0 = 24 Colors, 1 = Special Brushes, 2 = Stickers

  @override
  void didUpdateWidget(covariant PaletteBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toolMode == ColoringToolMode.sticker &&
        oldWidget.toolMode != ColoringToolMode.sticker) {
      _activeTab = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final s = AppStrings(lang);

    if (widget.isTabletSidebar) {
      return _buildTabletSidebar(lang, s);
    }
    return _buildPhoneBottomBar(lang, s);
  }

  Widget _buildPhoneBottomBar(AppLanguage lang, AppStrings s) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFAEB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: kComicInk, width: 3.2),
          left: BorderSide(color: kComicInk, width: 3.2),
          right: BorderSide(color: kComicInk, width: 3.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x283B2314),
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _ToyTabButton(
                label: s.colorsTab,
                icon: Icons.palette_rounded,
                selected: _activeTab == 0,
                color: widget.theme.primaryColor,
                onTap: () => setState(() => _activeTab = 0),
              ),
              const SizedBox(width: 8),
              _ToyTabButton(
                label: s.magicTab,
                icon: Icons.auto_awesome_rounded,
                selected: _activeTab == 1,
                color: const Color(0xFFFFA000),
                onTap: () => setState(() => _activeTab = 1),
              ),
              const SizedBox(width: 8),
              _ToyTabButton(
                label: s.stickerTab,
                icon: Icons.emoji_emotions_rounded,
                selected: _activeTab == 2,
                color: widget.theme.accentColor,
                onTap: () {
                  setState(() => _activeTab = 2);
                  widget.onStickerSelected(widget.selectedStickerType);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: _activeTab == 0
                ? _buildHorizontalCrayons()
                : _activeTab == 1
                    ? _buildSpecialBrushesRow(s)
                    : _buildHorizontalStickers(lang),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSidebar(AppLanguage lang, AppStrings s) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: kComicInk,
          width: 3.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x283B2314),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ToyTabButton(
                label: s.colorsAndBrushTab,
                icon: Icons.palette_rounded,
                selected: _activeTab != 2,
                color: widget.theme.primaryColor,
                onTap: () => setState(() => _activeTab = 0),
              ),
              const SizedBox(width: 8),
              _ToyTabButton(
                label: s.stickerTab,
                icon: Icons.auto_awesome_rounded,
                selected: _activeTab == 2,
                color: widget.theme.accentColor,
                onTap: () {
                  setState(() => _activeTab = 2);
                  widget.onStickerSelected(widget.selectedStickerType);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_activeTab != 2) ...[
            Text(
              s.specialBrushesTitle,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _buildBrushButtons(s, compact: true),
            ),
            const SizedBox(height: 12),
            Text(
              s.crayonsTitle,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                itemCount: AppColorPalette.colors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = AppColorPalette.colors[index];
                  final isSelected =
                      widget.toolMode != ColoringToolMode.sticker &&
                          widget.selectedPattern != BrushPattern.eraser &&
                          widget.selectedColor == item.color;
                  return _ToyCrayonWidget(
                    color: item.color,
                    name: item.name,
                    selected: isSelected,
                    compact: true,
                    onTap: () => widget.onColorSelected(item.color),
                  );
                },
              ),
            ),
          ] else ...[
            Text(
              s.stickerHint,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: StickerType.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final type = StickerType.values[index];
                  final isSelected =
                      widget.toolMode == ColoringToolMode.sticker &&
                          widget.selectedStickerType == type;
                  return _StickerTile(
                    type: type,
                    label: type.localizedLabel(lang),
                    selected: isSelected,
                    accentColor: widget.theme.primaryColor,
                    onTap: () => widget.onStickerSelected(type),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontalCrayons() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: AppColorPalette.colors.length,
      separatorBuilder: (_, _) => const SizedBox(width: 7),
      itemBuilder: (context, index) {
        final item = AppColorPalette.colors[index];
        final isSelected = widget.toolMode != ColoringToolMode.sticker &&
            widget.selectedPattern != BrushPattern.eraser &&
            widget.selectedColor == item.color;
        return _ToyCrayonWidget(
          color: item.color,
          name: item.name,
          selected: isSelected,
          onTap: () => widget.onColorSelected(item.color),
        );
      },
    );
  }

  Widget _buildSpecialBrushesRow(AppStrings s) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      children: _buildBrushButtons(s, compact: false)
          .map((w) => Padding(padding: const EdgeInsets.only(right: 10), child: w))
          .toList(),
    );
  }

  List<Widget> _buildBrushButtons(AppStrings s, {required bool compact}) {
    final specs = [
      (
        BrushPattern.solid,
        s.brushSolid,
        Icons.create_rounded,
        widget.selectedColor.computeLuminance() > 0.85
            ? widget.theme.primaryColor
            : widget.selectedColor,
      ),
      (
        BrushPattern.glitter,
        s.brushGlitter,
        Icons.auto_awesome_rounded,
        const Color(0xFFFFB300),
      ),
      (
        BrushPattern.polkaDot,
        s.brushPolka,
        Icons.grain_rounded,
        const Color(0xFFFF4D8D),
      ),
      (
        BrushPattern.rainbowStripe,
        s.brushRainbow,
        Icons.looks_rounded,
        const Color(0xFF2979FF),
      ),
      (
        BrushPattern.eraser,
        s.brushEraser,
        Icons.cleaning_services_rounded,
        const Color(0xFF64748B),
      ),
    ];

    return specs.map((spec) {
      final isSelected = widget.toolMode != ColoringToolMode.sticker &&
          widget.selectedPattern == spec.$1;
      return JuicyButton(
        color: isSelected ? spec.$4 : Colors.white,
        borderColor: kComicInk,
        borderWidth: isSelected ? 2.8 : 2.2,
        borderRadius: 18,
        depth: isSelected ? 4 : 3,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 14,
          vertical: compact ? 6 : 10,
        ),
        onTap: () => widget.onPatternSelected(spec.$1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              spec.$3,
              size: compact ? 16 : 22,
              color: isSelected ? Colors.white : spec.$4,
            ),
            const SizedBox(width: 5),
            Text(
              spec.$2,
              style: TextStyle(
                fontSize: compact ? 11.5 : 13.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildHorizontalStickers(AppLanguage lang) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      itemCount: StickerType.values.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final type = StickerType.values[index];
        final isSelected = widget.toolMode == ColoringToolMode.sticker &&
            widget.selectedStickerType == type;
        return SizedBox(
          width: 78,
          child: _StickerTile(
            type: type,
            label: type.localizedLabel(lang),
            selected: isSelected,
            accentColor: widget.theme.primaryColor,
            onTap: () => widget.onStickerSelected(type),
          ),
        );
      },
    );
  }
}

class _ToyTabButton extends StatelessWidget {
  const _ToyTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: JuicyButton(
        color: selected ? color : Colors.white,
        borderColor: kComicInk,
        borderWidth: selected ? 2.8 : 2.2,
        borderRadius: 18,
        depth: selected ? 4 : 2.5,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real tapered-tip 3D toy crayon that bounces up when selected.
class _ToyCrayonWidget extends StatelessWidget {
  const _ToyCrayonWidget({
    required this.color,
    required this.name,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final Color color;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          width: compact ? null : 46,
          padding: EdgeInsets.only(
            top: selected ? 0 : (compact ? 6 : 14),
            bottom: 2,
          ),
          child: CustomPaint(
            painter: _CrayonPainter(
              color: color,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }
}

class _CrayonPainter extends CustomPainter {
  _CrayonPainter({
    required this.color,
    required this.selected,
  });

  final Color color;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.30;
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.12, bodyTop, w * 0.88, h - 2),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    );

    final isVeryLight = color.computeLuminance() > 0.88;
    const outlineColor = kComicInk;

    // Selection glow aura
    if (selected) {
      canvas.drawRRect(
        bodyRect.inflate(3),
        Paint()
          ..color = const Color(0xFFFFEA00).withValues(alpha: 0.75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Tapered conical wax tip
    final tipPath = Path()
      ..moveTo(w * 0.22, bodyTop + 2)
      ..lineTo(w * 0.42, 3)
      ..quadraticBezierTo(w * 0.50, 0, w * 0.58, 3)
      ..lineTo(w * 0.78, bodyTop + 2)
      ..close();

    canvas.drawPath(tipPath, Paint()..color = color);
    canvas.drawPath(
      tipPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.6 : 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Main cylindrical crayon body with 3D side shading
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          lightenColor(color, 0.14),
          color,
          darkenColor(color, 0.14),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Paper wrapper band
    final wrapperTop = bodyTop + (h - bodyTop) * 0.16;
    final wrapperBottom = h - (h - bodyTop) * 0.18;
    final wrapperRect = Rect.fromLTRB(w * 0.13, wrapperTop, w * 0.87, wrapperBottom);
    canvas.drawRect(
      wrapperRect,
      Paint()..color = Colors.white.withValues(alpha: isVeryLight ? 0.5 : 0.36),
    );

    // Cute double stripes on wrapper
    final stripePaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.28)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(w * 0.14, wrapperTop + 4),
      Offset(w * 0.86, wrapperTop + 4),
      stripePaint,
    );
    canvas.drawLine(
      Offset(w * 0.14, wrapperBottom - 4),
      Offset(w * 0.86, wrapperBottom - 4),
      stripePaint,
    );

    // Gloss highlight along left edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, bodyTop + 5, w * 0.12, h - bodyTop - 14),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );

    // Crisp outer outline
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.8 : 1.8,
    );

    // Cute check dot when selected
    if (selected) {
      final center = Offset(w * 0.5, (wrapperTop + wrapperBottom) / 2);
      canvas.drawCircle(center, w * 0.17, Paint()..color = Colors.white);
      canvas.drawCircle(
        center,
        w * 0.09,
        Paint()..color = const Color(0xFF1E293B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrayonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.selected != selected;
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({
    required this.type,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final StickerType type;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return JuicyButton(
      color: selected ? accentColor.withValues(alpha: 0.24) : Colors.white,
      borderColor: kComicInk,
      borderWidth: selected ? 3.0 : 2.2,
      borderRadius: 20,
      depth: selected ? 4 : 3,
      padding: const EdgeInsets.all(6),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: _MiniStickerPreviewPainter(type),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2B2D42),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStickerPreviewPainter extends CustomPainter {
  _MiniStickerPreviewPainter(this.type);
  final StickerType type;

  @override
  void paint(Canvas canvas, Size size) {
    StickerPainterHelper.drawSticker(
      canvas,
      type,
      Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide * 0.40,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniStickerPreviewPainter oldDelegate) =>
      oldDelegate.type != type;
}
