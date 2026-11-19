import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/color_palette.dart';
import '../models/colorable_region.dart';
import '../models/placed_sticker.dart';

class ColoringSnapshot {
  const ColoringSnapshot({
    required this.regionFills,
    required this.strokes,
    required this.stickers,
  });

  final Map<String, RegionFill> regionFills;
  final List<BrushStroke> strokes;
  final List<PlacedSticker> stickers;
}

class ColoringSessionState {
  const ColoringSessionState({
    this.pageId = '',
    this.totalColorableRegions = 0,
    required this.selectedColor,
    this.selectedPattern = BrushPattern.solid,
    this.toolMode = ColoringToolMode.tapFill,
    this.selectedStickerType = StickerType.star,
    this.brushSize = 22.0,
    this.regionFills = const {},
    this.strokes = const [],
    this.activeStroke,
    this.stickers = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.celebrationTriggered = false,
  });

  final String pageId;
  final int totalColorableRegions;
  final Color selectedColor;
  final BrushPattern selectedPattern;
  final ColoringToolMode toolMode;
  final StickerType selectedStickerType;
  final double brushSize;
  final Map<String, RegionFill> regionFills;
  final List<BrushStroke> strokes;
  final BrushStroke? activeStroke;
  final List<PlacedSticker> stickers;
  final List<ColoringSnapshot> undoStack;
  final List<ColoringSnapshot> redoStack;
  final bool celebrationTriggered;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  int get coloredRegionCount {
    final coloredIds = <String>{...regionFills.keys};
    for (final stroke in strokes) {
      if (stroke.pattern != BrushPattern.eraser) {
        coloredIds.add(stroke.regionId);
      }
    }
    return coloredIds.length;
  }

  double get completionProgress {
    if (totalColorableRegions <= 0) return 0;
    return (coloredRegionCount / totalColorableRegions).clamp(0.0, 1.0);
  }

  bool get isCompleted =>
      totalColorableRegions > 0 && coloredRegionCount >= totalColorableRegions;

  ColoringSnapshot toSnapshot() {
    return ColoringSnapshot(
      regionFills: Map<String, RegionFill>.from(regionFills),
      strokes: List<BrushStroke>.from(strokes),
      stickers: List<PlacedSticker>.from(stickers),
    );
  }

  ColoringSessionState copyWith({
    String? pageId,
    int? totalColorableRegions,
    Color? selectedColor,
    BrushPattern? selectedPattern,
    ColoringToolMode? toolMode,
    StickerType? selectedStickerType,
    double? brushSize,
    Map<String, RegionFill>? regionFills,
    List<BrushStroke>? strokes,
    BrushStroke? activeStroke,
    bool clearActiveStroke = false,
    List<PlacedSticker>? stickers,
    List<ColoringSnapshot>? undoStack,
    List<ColoringSnapshot>? redoStack,
    bool? celebrationTriggered,
  }) {
    return ColoringSessionState(
      pageId: pageId ?? this.pageId,
      totalColorableRegions:
          totalColorableRegions ?? this.totalColorableRegions,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      toolMode: toolMode ?? this.toolMode,
      selectedStickerType: selectedStickerType ?? this.selectedStickerType,
      brushSize: brushSize ?? this.brushSize,
      regionFills: regionFills ?? this.regionFills,
      strokes: strokes ?? this.strokes,
      activeStroke:
          clearActiveStroke ? null : (activeStroke ?? this.activeStroke),
      stickers: stickers ?? this.stickers,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      celebrationTriggered: celebrationTriggered ?? this.celebrationTriggered,
    );
  }
}

class ColoringSessionNotifier extends StateNotifier<ColoringSessionState> {
  ColoringSessionNotifier()
      : super(
          ColoringSessionState(
            selectedColor: AppColorPalette.colors.first.color,
          ),
        );

  static const int maxHistory = 30;
  int _stickerCounter = 0;

  void startPage({
    required String pageId,
    required int totalColorableRegions,
  }) {
    if (state.pageId == pageId &&
        state.totalColorableRegions == totalColorableRegions) {
      return;
    }
    state = ColoringSessionState(
      pageId: pageId,
      totalColorableRegions: totalColorableRegions,
      selectedColor: state.selectedColor,
      selectedPattern: state.selectedPattern == BrushPattern.eraser
          ? BrushPattern.solid
          : state.selectedPattern,
      toolMode: state.toolMode,
      selectedStickerType: state.selectedStickerType,
      brushSize: state.brushSize,
    );
  }

  void selectColor(Color color) {
    final nextPattern = state.selectedPattern == BrushPattern.eraser
        ? BrushPattern.solid
        : state.selectedPattern;
    final nextToolMode = state.toolMode == ColoringToolMode.sticker
        ? ColoringToolMode.tapFill
        : state.toolMode;
    state = state.copyWith(
      selectedColor: color,
      selectedPattern: nextPattern,
      toolMode: nextToolMode,
    );
  }

  void selectPattern(BrushPattern pattern) {
    final nextToolMode = state.toolMode == ColoringToolMode.sticker
        ? ColoringToolMode.tapFill
        : state.toolMode;
    state = state.copyWith(
      selectedPattern: pattern,
      toolMode: nextToolMode,
    );
  }

  void selectToolMode(ColoringToolMode mode) {
    state = state.copyWith(toolMode: mode);
  }

  void selectStickerType(StickerType type) {
    state = state.copyWith(
      selectedStickerType: type,
      toolMode: ColoringToolMode.sticker,
    );
  }

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size.clamp(10.0, 40.0));
  }

  List<ColoringSnapshot> _pushHistory() {
    final nextUndo = [...state.undoStack, state.toSnapshot()];
    if (nextUndo.length > maxHistory) {
      return nextUndo.sublist(nextUndo.length - maxHistory);
    }
    return nextUndo;
  }

  /// Returns true if a change was applied.
  bool fillRegion(String regionId) {
    final nextFills = Map<String, RegionFill>.from(state.regionFills);
    final nextStrokes = List<BrushStroke>.from(state.strokes);

    if (state.selectedPattern == BrushPattern.eraser) {
      final hadFill = nextFills.remove(regionId) != null;
      final beforeCount = nextStrokes.length;
      nextStrokes.removeWhere((s) => s.regionId == regionId);
      if (!hadFill && nextStrokes.length == beforeCount) return false;

      state = state.copyWith(
        regionFills: nextFills,
        strokes: nextStrokes,
        undoStack: _pushHistory(),
        redoStack: const [],
      );
      return true;
    }

    final newFill = RegionFill(
      color: state.selectedColor,
      pattern: state.selectedPattern,
    );
    if (nextFills[regionId] == newFill) return false;

    nextFills[regionId] = newFill;
    state = state.copyWith(
      regionFills: nextFills,
      undoStack: _pushHistory(),
      redoStack: const [],
    );
    return true;
  }

  void startStroke(String regionId, Offset svgPoint) {
    final strokeColor = state.selectedPattern == BrushPattern.eraser
        ? Colors.white
        : state.selectedColor;
    final stroke = BrushStroke(
      regionId: regionId,
      points: [svgPoint],
      color: strokeColor,
      pattern: state.selectedPattern,
      strokeWidth: state.brushSize,
    );
    state = state.copyWith(activeStroke: stroke);
  }

  void appendStrokePoint(Offset svgPoint) {
    final current = state.activeStroke;
    if (current == null) return;
    if (current.points.isNotEmpty &&
        (current.points.last - svgPoint).distance < 2.0) {
      return;
    }
    state = state.copyWith(
      activeStroke: current.copyWith(
        points: [...current.points, svgPoint],
      ),
    );
  }

  void endStroke() {
    final current = state.activeStroke;
    if (current == null) return;
    final nextStrokes = [...state.strokes, current];
    state = state.copyWith(
      strokes: nextStrokes,
      clearActiveStroke: true,
      undoStack: _pushHistory(),
      redoStack: const [],
    );
  }

  void addSticker(Offset svgPoint) {
    _stickerCounter++;
    final sticker = PlacedSticker(
      id: 'sticker_${DateTime.now().microsecondsSinceEpoch}_$_stickerCounter',
      type: state.selectedStickerType,
      position: Offset(
        svgPoint.dx.clamp(24.0, 476.0),
        svgPoint.dy.clamp(24.0, 476.0),
      ),
    );
    state = state.copyWith(
      stickers: [...state.stickers, sticker],
      undoStack: _pushHistory(),
      redoStack: const [],
    );
  }

  void snapshotBeforeStickerDrag() {
    state = state.copyWith(
      undoStack: _pushHistory(),
      redoStack: const [],
    );
  }

  void moveSticker(String stickerId, Offset newSvgPosition) {
    final clamped = Offset(
      newSvgPosition.dx.clamp(20.0, 480.0),
      newSvgPosition.dy.clamp(20.0, 480.0),
    );
    final updated = state.stickers
        .map((s) => s.id == stickerId ? s.copyWith(position: clamped) : s)
        .toList();
    state = state.copyWith(stickers: updated);
  }

  void removeSticker(String stickerId) {
    final updated = state.stickers.where((s) => s.id != stickerId).toList();
    if (updated.length == state.stickers.length) return;
    state = state.copyWith(
      stickers: updated,
      undoStack: _pushHistory(),
      redoStack: const [],
    );
  }

  void markCelebrationTriggered() {
    if (!state.celebrationTriggered) {
      state = state.copyWith(celebrationTriggered: true);
    }
  }

  void undo() {
    if (!state.canUndo) return;
    final previous = state.undoStack.last;
    final nextUndo = state.undoStack.sublist(0, state.undoStack.length - 1);
    final nextRedo = [...state.redoStack, state.toSnapshot()];
    state = state.copyWith(
      regionFills: previous.regionFills,
      strokes: previous.strokes,
      stickers: previous.stickers,
      undoStack: nextUndo,
      redoStack: nextRedo,
      clearActiveStroke: true,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final restored = state.redoStack.last;
    final nextRedo = state.redoStack.sublist(0, state.redoStack.length - 1);
    final nextUndo = [...state.undoStack, state.toSnapshot()];
    state = state.copyWith(
      regionFills: restored.regionFills,
      strokes: restored.strokes,
      stickers: restored.stickers,
      undoStack: nextUndo,
      redoStack: nextRedo,
      clearActiveStroke: true,
    );
  }

  void clearCanvas() {
    if (state.regionFills.isEmpty &&
        state.strokes.isEmpty &&
        state.stickers.isEmpty) {
      return;
    }
    state = state.copyWith(
      regionFills: const {},
      strokes: const [],
      stickers: const [],
      clearActiveStroke: true,
      undoStack: _pushHistory(),
      redoStack: const [],
      celebrationTriggered: false,
    );
  }
}

final coloringSessionProvider =
    StateNotifierProvider<ColoringSessionNotifier, ColoringSessionState>(
  (ref) => ColoringSessionNotifier(),
);
