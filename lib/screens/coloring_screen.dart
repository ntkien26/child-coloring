import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_strings.dart';
import '../core/responsive/responsive_layout.dart';
import '../core/services/audio_service.dart';
import '../game/themed_effect_game.dart';
import '../models/colorable_region.dart';
import '../models/coloring_page.dart';
import '../models/game_theme.dart';
import '../providers/catalog_provider.dart';
import '../providers/coloring_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/game_ui_kit.dart';
import '../widgets/palette_bar.dart';

class ColoringScreen extends ConsumerStatefulWidget {
  const ColoringScreen({
    super.key,
    required this.page,
    required this.theme,
  });

  final ColoringPage page;
  final GameTheme theme;

  @override
  ConsumerState<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends ConsumerState<ColoringScreen> {
  late final ThemedEffectGame _effectGame;
  bool _muted = AudioService.instance.isMuted;

  @override
  void initState() {
    super.initState();
    _effectGame = ThemedEffectGame(initialTheme: widget.theme);
  }

  void _checkCompletionCelebration() {
    final session = ref.read(coloringSessionProvider);
    if (session.isCompleted && !session.celebrationTriggered) {
      ref.read(coloringSessionProvider.notifier).markCelebrationTriggered();
      ref.read(completedPagesProvider.notifier).markCompleted(widget.page.id);
      AudioService.instance.playSparkle();
      _effectGame.triggerCelebration();
    }
  }

  void _handleRegionTap(ColorableRegion region, Offset localPosition) {
    final notifier = ref.read(coloringSessionProvider.notifier);
    final beforePattern = ref.read(coloringSessionProvider).selectedPattern;
    final selectedColor = ref.read(coloringSessionProvider).selectedColor;
    final changed = notifier.fillRegion(region.id);
    if (!changed) return;

    if (beforePattern == BrushPattern.eraser) {
      AudioService.instance.playErase();
    } else if (beforePattern == BrushPattern.solid) {
      AudioService.instance.playPop();
      _effectGame.spawnBurst(localPosition, accentColor: selectedColor);
    } else {
      AudioService.instance.playSparkle();
      _effectGame.spawnBurst(localPosition, accentColor: selectedColor);
    }
    _checkCompletionCelebration();
  }

  void _handleStrokeStart(
    ColorableRegion region,
    Offset svgPoint,
    Offset localPosition,
  ) {
    final session = ref.read(coloringSessionProvider);
    ref.read(coloringSessionProvider.notifier).startStroke(region.id, svgPoint);
    if (session.selectedPattern == BrushPattern.eraser) {
      AudioService.instance.playErase();
    } else {
      AudioService.instance.playPop();
      _effectGame.spawnBurst(localPosition, accentColor: session.selectedColor);
    }
  }

  void _handleStrokeEnd() {
    ref.read(coloringSessionProvider.notifier).endStroke();
    _checkCompletionCelebration();
  }

  void _handleAddSticker(Offset svgPoint, Offset localPosition) {
    ref.read(coloringSessionProvider.notifier).addSticker(svgPoint);
    AudioService.instance.playSparkle();
    _effectGame.spawnBurst(localPosition);
  }

  @override
  Widget build(BuildContext context) {
    final drawingAsync = ref.watch(parsedDrawingProvider(widget.page.assetPath));
    final session = ref.watch(coloringSessionProvider);
    final lang = ref.watch(localeProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: WarmCartoonBackground(
        child: SafeArea(
          child: drawingAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFD98E45)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48),
                  const SizedBox(height: 10),
                  Text(s.loadError(err)),
                  const SizedBox(height: 12),
                  JuicyButton(
                    color: const Color(0xFFFF7A96),
                    onTap: () => Navigator.of(context).pop(),
                    child: OutlinedComicText(
                      s.backButton,
                      fontSize: 15,
                      fillColor: Colors.white,
                      strokeWidth: 3.4,
                    ),
                  ),
                ],
              ),
            ),
            data: (drawing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ref.read(coloringSessionProvider.notifier).startPage(
                        pageId: widget.page.id,
                        totalColorableRegions: drawing.colorableRegions.length,
                      );
                }
              });

              return ResponsiveLayout(
                phone: (_) => _buildPhoneLayout(drawing, session, lang, s),
                tablet: (_) => _buildTabletLayout(drawing, session, lang, s),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(
    ParsedSvgDrawing drawing,
    ColoringSessionState session,
    AppLanguage lang,
    AppStrings s,
  ) {
    final notifier = ref.read(coloringSessionProvider.notifier);

    return Column(
      children: [
        // Chunky Cartoon Top Bar (Phone)
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            children: [
              JuicyCircleButton(
                icon: Icons.reply_rounded,
                tooltip: s.back,
                color: const Color(0xFFFF7A96),
                size: 42,
                iconSize: 22,
                onTap: () {
                  AudioService.instance.playPop();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.page.localizedName(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: kComicInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _CartoonPercentBar(progress: session.completionProgress),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _ModeToggleChip(
                toolMode: session.toolMode,
                fillLabel: s.tapFill,
                brushLabel: s.brushMode,
                onSelect: (mode) {
                  AudioService.instance.playPop();
                  notifier.selectToolMode(mode);
                },
              ),
              const SizedBox(width: 5),
              JuicyCircleButton(
                icon: Icons.undo_rounded,
                tooltip: s.undo,
                color: const Color(0xFF4DABF7),
                size: 38,
                iconSize: 20,
                enabled: session.canUndo,
                onTap: () {
                  AudioService.instance.playPop();
                  notifier.undo();
                },
              ),
              const SizedBox(width: 4),
              JuicyCircleButton(
                icon: Icons.redo_rounded,
                tooltip: s.redo,
                color: const Color(0xFF4DABF7),
                size: 38,
                iconSize: 20,
                enabled: session.canRedo,
                onTap: () {
                  AudioService.instance.playPop();
                  notifier.redo();
                },
              ),
              const SizedBox(width: 4),
              JuicyCircleButton(
                icon: Icons.delete_sweep_rounded,
                tooltip: s.clear,
                color: const Color(0xFFFF6B6B),
                size: 38,
                iconSize: 20,
                onTap: () {
                  AudioService.instance.playErase();
                  notifier.clearCanvas();
                },
              ),
            ],
          ),
        ),

        // Cartoon Ink-Framed Art Canvas + Flame Overlay
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: _buildCanvasStage(drawing, session, s),
          ),
        ),

        // Cartoon Crayon & Sticker Dock (Phone)
        PaletteBar(
          theme: widget.theme,
          selectedColor: session.selectedColor,
          selectedPattern: session.selectedPattern,
          toolMode: session.toolMode,
          selectedStickerType: session.selectedStickerType,
          isTabletSidebar: false,
          onColorSelected: (color) {
            AudioService.instance.playPop();
            notifier.selectColor(color);
          },
          onPatternSelected: (pattern) {
            AudioService.instance.playPop();
            notifier.selectPattern(pattern);
          },
          onStickerSelected: (type) {
            AudioService.instance.playPop();
            notifier.selectStickerType(type);
          },
        ),
      ],
    );
  }

  /// Ergonomic 3-column Cartoon Tablet Art Studio
  Widget _buildTabletLayout(
    ParsedSvgDrawing drawing,
    ColoringSessionState session,
    AppLanguage lang,
    AppStrings s,
  ) {
    final notifier = ref.read(coloringSessionProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Column 1: Left Chunky Cartoon Tool Rail
          Container(
            width: 102,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEB),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kComicInk, width: 3.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x283B2314),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ToyRailButton(
                    icon: Icons.reply_rounded,
                    label: s.back,
                    color: const Color(0xFFFF7A96),
                    onTap: () {
                      AudioService.instance.playPop();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  _ToyRailButton(
                    icon: Icons.format_color_fill_rounded,
                    label: s.tapFill,
                    selected: session.toolMode == ColoringToolMode.tapFill,
                    color: const Color(0xFFFF922B),
                    onTap: () {
                      AudioService.instance.playPop();
                      notifier.selectToolMode(ColoringToolMode.tapFill);
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToyRailButton(
                    icon: Icons.brush_rounded,
                    label: s.brushMode,
                    selected:
                        session.toolMode == ColoringToolMode.freehandBrush,
                    color: const Color(0xFF9B5DE5),
                    onTap: () {
                      AudioService.instance.playPop();
                      notifier.selectToolMode(ColoringToolMode.freehandBrush);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ToyRailButton(
                    icon: Icons.undo_rounded,
                    label: s.undo,
                    enabled: session.canUndo,
                    color: const Color(0xFF4DABF7),
                    onTap: () {
                      AudioService.instance.playPop();
                      notifier.undo();
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToyRailButton(
                    icon: Icons.redo_rounded,
                    label: s.redo,
                    enabled: session.canRedo,
                    color: const Color(0xFF4DABF7),
                    onTap: () {
                      AudioService.instance.playPop();
                      notifier.redo();
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToyRailButton(
                    icon: Icons.delete_sweep_rounded,
                    label: s.clear,
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      AudioService.instance.playErase();
                      notifier.clearCanvas();
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToyRailButton(
                    icon: _muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    label: _muted ? s.soundOff : s.soundOn,
                    color: const Color(0xFF59D355),
                    onTap: () {
                      setState(() {
                        _muted = !_muted;
                        AudioService.instance.setMuted(_muted);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Cartoon Percentage Ring
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: session.completionProgress,
                          strokeWidth: 7,
                          backgroundColor: const Color(0xFFEBDAB6),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF59D355),
                          ),
                        ),
                        Text(
                          '${(session.completionProgress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: kComicInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Column 2: Large Center Canvas Stage
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: WoodenSignboard(
                    label: widget.page.localizedName(lang).toUpperCase(),
                    fontSize: 16,
                  ),
                ),
                Expanded(child: _buildCanvasStage(drawing, session, s)),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Column 3: Right Fixed 24-Crayon Box & Stickers Panel
          PaletteBar(
            theme: widget.theme,
            selectedColor: session.selectedColor,
            selectedPattern: session.selectedPattern,
            toolMode: session.toolMode,
            selectedStickerType: session.selectedStickerType,
            isTabletSidebar: true,
            onColorSelected: (color) {
              AudioService.instance.playPop();
              notifier.selectColor(color);
            },
            onPatternSelected: (pattern) {
              AudioService.instance.playPop();
              notifier.selectPattern(pattern);
            },
            onStickerSelected: (type) {
              AudioService.instance.playPop();
              notifier.selectStickerType(type);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasStage(
    ParsedSvgDrawing drawing,
    ColoringSessionState session,
    AppStrings s,
  ) {
    final notifier = ref.read(coloringSessionProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kComicInk, width: 3.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x333B2314),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Interactive Coloring Canvas
            Padding(
              padding: const EdgeInsets.all(8),
              child: ColoringCanvas(
                drawing: drawing,
                regionFills: session.regionFills,
                strokes: session.strokes,
                activeStroke: session.activeStroke,
                stickers: session.stickers,
                toolMode: session.toolMode,
                selectedPattern: session.selectedPattern,
                onRegionTap: _handleRegionTap,
                onStrokeStart: _handleStrokeStart,
                onStrokeUpdate: notifier.appendStrokePoint,
                onStrokeEnd: _handleStrokeEnd,
                onAddSticker: _handleAddSticker,
                onStickerDragStart: notifier.snapshotBeforeStickerDrag,
                onStickerDragUpdate: notifier.moveSticker,
                onStickerRemove: (id) {
                  AudioService.instance.playErase();
                  notifier.removeSticker(id);
                },
              ),
            ),

            // Transparent Flame Particle & Cheering Mascot Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: GameWidget(game: _effectGame),
              ),
            ),

            // Joyful 100% completion celebration banner
            if (session.isCompleted)
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7BE86B), Color(0xFF42B839)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kComicInk, width: 3.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x333B2314),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.celebration_rounded,
                          color: Color(0xFFFFF3BF),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: OutlinedComicText(
                            s.celebrationMessage,
                            fontSize: 14.5,
                            fillColor: Colors.white,
                            strokeWidth: 3.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartoonPercentBar extends StatelessWidget {
  const _CartoonPercentBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF8D572B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kComicInk, width: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7BE86B), Color(0xFF42B839)],
                  ),
                ),
              ),
            ),
            Center(
              child: OutlinedComicText(
                '${(progress * 100).round()}%',
                fontSize: 10,
                fillColor: Colors.white,
                strokeWidth: 2.6,
                shadowOffset: Offset.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  const _ModeToggleChip({
    required this.toolMode,
    required this.fillLabel,
    required this.brushLabel,
    required this.onSelect,
  });

  final ColoringToolMode toolMode;
  final String fillLabel;
  final String brushLabel;
  final ValueChanged<ColoringToolMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final isBrush = toolMode == ColoringToolMode.freehandBrush;
    return JuicyButton(
      color: isBrush ? const Color(0xFF9B5DE5) : const Color(0xFFFF922B),
      borderRadius: 18,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      onTap: () => onSelect(
        isBrush ? ColoringToolMode.tapFill : ColoringToolMode.freehandBrush,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBrush ? Icons.brush_rounded : Icons.format_color_fill_rounded,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          OutlinedComicText(
            isBrush ? brushLabel : fillLabel,
            fontSize: 12,
            fillColor: Colors.white,
            strokeWidth: 2.8,
          ),
        ],
      ),
    );
  }
}

class _ToyRailButton extends StatelessWidget {
  const _ToyRailButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: JuicyButton(
        color: selected ? color : Colors.white,
        borderColor: kComicInk,
        borderWidth: selected ? 3.0 : 2.4,
        borderRadius: 18,
        depth: selected ? 4 : 3,
        enabled: enabled,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        onTap: enabled ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected
                  ? Colors.white
                  : (enabled ? color : Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: selected
                    ? Colors.white
                    : (enabled ? kComicInk : Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
