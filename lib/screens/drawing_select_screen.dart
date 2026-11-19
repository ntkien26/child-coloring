import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive/responsive_layout.dart';
import '../core/services/audio_service.dart';
import '../models/coloring_page.dart';
import '../models/game_theme.dart';
import '../providers/catalog_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/monetization_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/game_ui_kit.dart';
import '../widgets/parent_shop_sheet.dart';
import '../widgets/safe_banner_ad.dart';
import 'coloring_screen.dart';

/// Screen 2: Cartoon Split Before/After Picture Picker inspired by storybook coloring games.
class DrawingSelectScreen extends ConsumerStatefulWidget {
  const DrawingSelectScreen({
    super.key,
    required this.theme,
  });

  final GameTheme theme;

  @override
  ConsumerState<DrawingSelectScreen> createState() =>
      _DrawingSelectScreenState();
}

class _DrawingSelectScreenState extends ConsumerState<DrawingSelectScreen> {
  bool _muted = AudioService.instance.isMuted;
  bool _routeSettled = false;
  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final anim = ModalRoute.of(context)?.animation;
    if (anim == null || anim.isCompleted || anim.value >= 0.99) {
      _routeSettled = true;
    } else if (_routeAnimation != anim) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
      _routeAnimation = anim;
      anim.addStatusListener(_onRouteAnimationStatus);
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (mounted && !_routeSettled) {
        setState(() => _routeSettled = true);
      }
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      AudioService.instance.setMuted(_muted);
    });
  }

  Future<void> _launchOrUnlockPage(ColoringPage page) async {
    final monetization = ref.read(monetizationProvider);
    if (monetization.isPageUnlocked(page)) {
      AudioService.instance.playPop();
      if (!mounted) return;
      Navigator.of(context).push(
        bouncyGameRoute<void>(
          ColoringScreen(page: page, theme: widget.theme),
        ),
      );
      return;
    }

    AudioService.instance.playPop();
    await _showUnlockPageDialog(page);
  }

  void _onCardTap(ColoringPage page) {
    _launchOrUnlockPage(page);
  }

  Future<void> _showUnlockPageDialog(ColoringPage page) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, dialogRef, _) {
            final busy = dialogRef.watch(monetizationProvider).isBusy;
            final lang = dialogRef.watch(localeProvider);
            final s = dialogRef.watch(stringsProvider);

            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: kParchmentTop,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: kComicInk, width: 3.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CartoonPadlockBadge(label: s.lockedShort),
                      const SizedBox(height: 12),
                      OutlinedComicText(
                        s.unlockPageTitle(page.localizedName(lang)),
                        fontSize: 18,
                        fillColor: const Color(0xFFFFD43B),
                        strokeWidth: 4.0,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.unlockPageBody,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: kComicInk,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: JuicyButton(
                          color: const Color(0xFF59D355),
                          enabled: !busy,
                          borderRadius: 20,
                          depth: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          onTap: busy
                              ? null
                              : () async {
                                  final unlocked = await dialogRef
                                      .read(monetizationProvider.notifier)
                                      .unlockPageWithRewardedAd(page);
                                  if (!ctx.mounted) return;
                                  Navigator.of(ctx).pop();
                                  if (unlocked && mounted) {
                                    AudioService.instance.playSparkle();
                                    Navigator.of(context).push(
                                      bouncyGameRoute<void>(
                                        ColoringScreen(
                                          page: page,
                                          theme: widget.theme,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: OutlinedComicText(
                                  busy ? s.loading : s.watchRewardedAd,
                                  fontSize: 14,
                                  fillColor: Colors.white,
                                  strokeWidth: 3.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: JuicyButton(
                          color: const Color(0xFFFF922B),
                          enabled: !busy,
                          borderRadius: 20,
                          depth: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          onTap: busy
                              ? null
                              : () async {
                                  Navigator.of(ctx).pop();
                                  await openParentVipShop(context, ref);
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_open_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: OutlinedComicText(
                                  s.unlockAllVipParents,
                                  fontSize: 13.5,
                                  fillColor: Colors.white,
                                  strokeWidth: 3.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          s.maybeLater,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: kComicInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(pagesForThemeProvider(widget.theme.id));
    final monetization = ref.watch(monetizationProvider);
    final completedPages = ref.watch(completedPagesProvider);
    final lang = ref.watch(localeProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: WarmCartoonBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Cartoon Bar: Pink Back Pill + Language + Sound
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Row(
                  children: [
                    CartoonBackPill(
                      label: s.backButton,
                      onTap: () {
                        AudioService.instance.playPop();
                        Navigator.of(context).pop();
                      },
                    ),
                    const Spacer(),
                    LanguageTogglePill(
                      language: lang,
                      tooltip: s.languageTooltip,
                      onToggle: () {
                        AudioService.instance.playPop();
                        ref.read(localeProvider.notifier).toggleLanguage();
                      },
                    ),
                    const SizedBox(width: 8),
                    JuicyCircleButton(
                      icon: _muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: const Color(0xFFFF6B6B),
                      tooltip: _muted ? s.soundOn : s.soundOff,
                      size: 44,
                      iconSize: 22,
                      onTap: _toggleMute,
                    ),
                  ],
                ),
              ),

              // Big Golden Stroked Cartoon Theme Header (single active language)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: OutlinedComicText(
                  widget.theme.localizedTitle(lang).toUpperCase(),
                  fontSize: 26,
                  fillColor: const Color(0xFFFFD43B),
                  strokeWidth: 5.5,
                  letterSpacing: 0.8,
                  maxLines: 2,
                ),
              ),

              // Split Before/After Drawing Grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = ScreenUtils.homeGridColumns(
                      constraints.maxWidth,
                    );
                    final hPad =
                        ScreenUtils.horizontalPadding(constraints.maxWidth);

                    return pagesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD98E45),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            s.loadError(err),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: kComicInk,
                            ),
                          ),
                        ),
                      ),
                      data: (pages) {
                        if (pages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                s.emptyThemeMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: kComicInk,
                                ),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.18,
                          ),
                          itemCount: pages.length,
                          itemBuilder: (context, index) {
                            final page = pages[index];
                            final unlocked = monetization.isPageUnlocked(page);
                            final isDone = completedPages.contains(page.id);

                            return _SplitBeforeAfterCard(
                              page: page,
                              theme: widget.theme,
                              isUnlocked: unlocked,
                              isCompleted: isDone,
                              deferThumbnail: !_routeSettled && index >= 2,
                              onTap: () => _onCardTap(page),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SafeBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Split-view card: Left half line-art | dashed divider | Right half colorful preview.
class _SplitBeforeAfterCard extends ConsumerStatefulWidget {
  const _SplitBeforeAfterCard({
    required this.page,
    required this.theme,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.deferThumbnail = false,
  });

  final ColoringPage page;
  final GameTheme theme;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool deferThumbnail;

  @override
  ConsumerState<_SplitBeforeAfterCard> createState() =>
      _SplitBeforeAfterCardState();
}

class _SplitBeforeAfterCardState extends ConsumerState<_SplitBeforeAfterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final drawingAsync = widget.deferThumbnail
        ? null
        : ref.watch(parsedDrawingProvider(widget.page.assetPath));
    final lang = ref.watch(localeProvider);
    final s = ref.watch(stringsProvider);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _pressed ? 0.95 : 1.0,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // White Ink-Outlined Split Card
                  RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kComicInk,
                          width: 2.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kComicInk.withValues(alpha: 0.16),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.5),
                        child: drawingAsync == null
                            ? Center(
                                child: Icon(
                                  widget.theme.icon,
                                  color: widget.theme.primaryColor
                                      .withValues(alpha: 0.28),
                                  size: 36,
                                ),
                              )
                            : drawingAsync.when(
                                loading: () => Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      color: widget.theme.primaryColor,
                                    ),
                                  ),
                                ),
                                error: (_, _) => const Center(
                                  child: Icon(Icons.broken_image_rounded),
                                ),
                                data: (drawing) => Row(
                                  children: [
                                    // Left: Black-and-white line-art
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: DrawingThumbnail(
                                          drawing: drawing,
                                          showColorPreview: false,
                                        ),
                                      ),
                                    ),

                                    // Center Dashed Vertical Divider
                                    SizedBox(
                                      width: 2,
                                      height: double.infinity,
                                      child: CustomPaint(
                                        painter: _DashedVerticalLinePainter(),
                                      ),
                                    ),

                                    // Right: Vibrant Colored Preview
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: DrawingThumbnail(
                                          drawing: drawing,
                                          showColorPreview: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Completed Gold Star top-left
                  if (widget.isCompleted)
                    Positioned(
                      top: -7,
                      left: -6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF59D355),
                          shape: BoxShape.circle,
                          border: Border.all(color: kComicInk, width: 2.2),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFEA00),
                          size: 18,
                        ),
                      ),
                    ),

                  // Golden Cartoon Padlock top-right if locked
                  if (!widget.isUnlocked)
                    Positioned(
                      top: -10,
                      right: -4,
                      child: CartoonPadlockBadge(label: s.lockedShort),
                    ),
                ],
              ),
            ),

            // Clean Bold Single-Language Cartoon Caption Below Card
            const SizedBox(height: 5),
            Text(
              widget.page.localizedName(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: kComicInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedVerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kComicInk.withValues(alpha: 0.55)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const dashHeight = 5.0;
    const dashSpace = 4.5;
    double y = 6.0;
    while (y < size.height - 6.0) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashHeight).clamp(0, size.height - 6.0)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
