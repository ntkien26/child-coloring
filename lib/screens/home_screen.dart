import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_themes.dart';
import '../core/responsive/responsive_layout.dart';
import '../core/services/audio_service.dart';
import '../models/coloring_page.dart';
import '../models/game_theme.dart';
import '../providers/catalog_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/monetization_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/game_ui_kit.dart';
import '../widgets/parent_shop_sheet.dart';
import '../widgets/safe_banner_ad.dart';
import 'drawing_select_screen.dart';

/// Screen 1: storybook theme hub (ages 2-5).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _muted = AudioService.instance.isMuted;
  bool _isNavigating = false;

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      AudioService.instance.setMuted(_muted);
    });
  }

  Future<void> _openThemeWorld(GameTheme theme) async {
    if (_isNavigating) return;
    _isNavigating = true;
    AudioService.instance.playThemeSwitch();
    ref.read(selectedThemeIdProvider.notifier).state = theme.id;

    // Brief tactile delay so the theme card bounce animation completes cleanly
    // before the route transition starts.
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) {
      _isNavigating = false;
      return;
    }

    await Navigator.of(context).push(
      bouncyGameRoute<void>(DrawingSelectScreen(theme: theme)),
    );
    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final monetization = ref.watch(monetizationProvider);
    final completedPages = ref.watch(completedPagesProvider);
    final lang = ref.watch(localeProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: WarmCartoonBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              StorybookHeroHeader(
                line1: s.appTitleLine1,
                line2: s.appTitleLine2,
                leftAction: LanguageTogglePill(
                  language: lang,
                  tooltip: s.languageTooltip,
                  onToggle: () {
                    AudioService.instance.playPop();
                    ref.read(localeProvider.notifier).toggleLanguage();
                  },
                ),
                rightAction: JuicyCircleButton(
                  icon: _muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: const Color(0xFFFF6B6B),
                  tooltip: _muted ? s.soundOn : s.soundOff,
                  size: 46,
                  iconSize: 23,
                  onTap: _toggleMute,
                ),
                bottomAction: WoodenSignboard(
                  label: s.chooseThemeSign,
                  fontSize: 18,
                ),
              ),

              // Theme cards inside a sand panel; sized to fit without any overlap.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: SandPanel(
                        child: catalogAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD98E45),
                            ),
                          ),
                          error: (err, _) => Center(
                            child: Text(
                              s.loadError(err),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: kComicInk,
                              ),
                            ),
                          ),
                          data: (catalog) => _buildThemeGrid(
                            catalog,
                            completedPages,
                            monetization,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom action row: its own slot, never overlaps the cards.
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: SizedBox(
                      width: double.infinity,
                      child: JuicyButton(
                        color: monetization.isVipUnlocked
                            ? const Color(0xFF59D355)
                            : const Color(0xFFFF922B),
                        borderRadius: 26,
                        depth: 5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        onTap: () => openParentVipShop(context, ref),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              monetization.isVipUnlocked
                                  ? Icons.verified_rounded
                                  : Icons.lock_open_rounded,
                              color: const Color(0xFFFFF3BF),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: OutlinedComicText(
                                monetization.isVipUnlocked
                                    ? s.vipUnlockedBadge
                                    : s.unlockAll,
                                fontSize: 18,
                                fillColor: Colors.white,
                                strokeWidth: 4.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SafeBannerAd(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeGrid(
    Map<GameThemeId, List<ColoringPage>> catalog,
    Set<String> completedPages,
    MonetizationState monetization,
  ) {
    return LayoutBuilder(
      builder: (context, c) {
        final isTablet = MediaQuery.sizeOf(context).width >=
            ScreenUtils.tabletBreakpoint;
        final cols = isTablet ? 3 : 2;
        final rows = (AppThemes.all.length / cols).ceil();
        const gap = 10.0;

        final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
        final fitH = (c.maxHeight - gap * (rows - 1)) / rows;
        final fits = fitH >= 136;
        final cardH = fits ? fitH.clamp(136.0, cardW * 1.2) : cardW * 0.98;

        final grid = GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: fits,
          physics: fits
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: cardW / cardH,
          ),
          itemCount: AppThemes.all.length,
          itemBuilder: (context, index) {
            final theme = AppThemes.all[index];
            final pages = catalog[theme.id] ?? const <ColoringPage>[];
            final completedCount =
                pages.where((p) => completedPages.contains(p.id)).length;
            final hasLocked =
                pages.any((p) => !monetization.isPageUnlocked(p));
            return _CartoonThemeCard(
              theme: theme,
              pages: pages,
              completedCount: completedCount,
              hasLockedPages: hasLocked,
              cardWidth: cardW,
              onTap: () => _openThemeWorld(theme),
            );
          },
        );

        return fits ? Center(child: grid) : grid;
      },
    );
  }
}

class _CartoonThemeCard extends ConsumerStatefulWidget {
  const _CartoonThemeCard({
    required this.theme,
    required this.pages,
    required this.completedCount,
    required this.hasLockedPages,
    required this.cardWidth,
    required this.onTap,
  });

  final GameTheme theme;
  final List<ColoringPage> pages;
  final int completedCount;
  final bool hasLockedPages;
  final double cardWidth;
  final VoidCallback onTap;

  @override
  ConsumerState<_CartoonThemeCard> createState() => _CartoonThemeCardState();
}

class _CartoonThemeCardState extends ConsumerState<_CartoonThemeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final s = ref.watch(stringsProvider);

    final first = widget.pages.isNotEmpty ? widget.pages[0] : null;
    final second = widget.pages.length > 1 ? widget.pages[1] : null;
    final firstDrawing =
        first != null ? ref.watch(parsedDrawingProvider(first.assetPath)) : null;
    final secondDrawing = second != null
        ? ref.watch(parsedDrawingProvider(second.assetPath))
        : null;

    final cardBase = widget.theme.cardGradient.first;
    final cardDeep = widget.theme.cardGradient.last;
    final ledge = darkenColor(cardDeep, 0.24);
    final titleSize = (widget.cardWidth * 0.105).clamp(14.0, 21.0);

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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: 6,
                bottom: -6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ledge,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kComicInk, width: 2.8),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, _pressed ? 4.5 : 0.0),
                child: RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [lightenColor(cardBase, 0.12), cardBase, cardDeep],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kComicInk, width: 2.8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Stack(
                        children: [
                          // Soft glossy shine
                          Positioned(
                            top: -18,
                            left: 12,
                            right: 12,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                          ),
                          // Ground patch that the characters stand on
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 40,
                            height: 26,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.26),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 36),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: OutlinedComicText(
                                      widget.theme
                                          .localizedShortTitle(lang)
                                          .toUpperCase(),
                                      fontSize: titleSize,
                                      fillColor: Colors.white,
                                      strokeWidth: 4.4,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: _StickerCharacter(
                                          drawingAsync: firstDrawing,
                                          fallbackIcon: widget.theme.icon,
                                        ),
                                      ),
                                      if (secondDrawing != null)
                                        Expanded(
                                          child: _StickerCharacter(
                                            drawingAsync: secondDrawing,
                                            fallbackIcon: widget.theme.icon,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CartoonProgressBar(
                                  completed: widget.completedCount,
                                  total: widget.pages.length,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.hasLockedPages)
                Positioned(
                  top: -10,
                  right: -4,
                  child: CartoonPadlockBadge(label: s.lockedShort),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerCharacter extends StatelessWidget {
  const _StickerCharacter({
    required this.drawingAsync,
    required this.fallbackIcon,
  });

  final AsyncValue? drawingAsync;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (drawingAsync == null) {
      return Icon(fallbackIcon, color: Colors.white, size: 36);
    }
    return drawingAsync!.when(
      loading: () => Icon(fallbackIcon, color: Colors.white70, size: 30),
      error: (_, _) => Icon(fallbackIcon, color: Colors.white70, size: 30),
      data: (drawing) => Padding(
        padding: const EdgeInsets.all(1),
        child: DrawingThumbnail(
          drawing: drawing,
          showColorPreview: true,
          transparentBackground: true,
          stickerStyle: true,
        ),
      ),
    );
  }
}
