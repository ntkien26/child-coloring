import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_coloring_game/core/constants/app_themes.dart';
import 'package:kids_coloring_game/main.dart';
import 'package:kids_coloring_game/models/coloring_page.dart';
import 'package:kids_coloring_game/models/game_theme.dart';
import 'package:kids_coloring_game/providers/catalog_provider.dart';
import 'package:kids_coloring_game/screens/coloring_screen.dart';
import 'package:kids_coloring_game/screens/drawing_select_screen.dart';
import 'package:kids_coloring_game/screens/home_screen.dart';
import 'package:kids_coloring_game/screens/splash_screen.dart';
import 'package:kids_coloring_game/widgets/game_ui_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('SplashScreen renders cleanly and transitions to HomeScreen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: KidsColoringApp()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(WoodenSignboard), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Advance past splash duration (2200ms) + route transition (320ms)
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntilLoaded(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(StorybookHeroHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen renders cleanly on Phone (390x844) without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await pumpUntilLoaded(tester);

    expect(find.byType(StorybookHeroHeader), findsOneWidget);
    expect(find.byType(WoodenSignboard), findsOneWidget);
    expect(find.byType(SandPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen renders cleanly on Tablet (1024x768) without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await pumpUntilLoaded(tester);

    expect(find.byType(StorybookHeroHeader), findsOneWidget);
    expect(find.byType(WoodenSignboard), findsOneWidget);
    expect(find.byType(SandPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ColoringScreen renders cleanly on Phone (390x844) & Tablet (1024x768)',
      (tester) async {
    const samplePage = ColoringPage(
      id: 'animals_01_cat',
      assetPath: 'assets/svgs/animals_01_cat.svg',
      themeId: GameThemeId.cuteAnimals,
      order: 1,
      name: 'Mèo Con Dễ Thương',
      isLocked: false,
    );
    final theme = AppThemes.byId(GameThemeId.cuteAnimals);

    // Phone layout
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Pre-resolve the real SVG asset inside runAsync (Flutter test FakeAsync zone)
    await tester.runAsync(() async {
      await container.read(parsedDrawingProvider(samplePage.assetPath).future);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ColoringScreen(page: samplePage, theme: theme),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.text('Mèo Con Dễ Thương'), findsOneWidget);
    expect(find.text('24 Màu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Tablet 3-column layout
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Màu & Cọ'), findsOneWidget);
    expect(find.text('Hộp 24 Bút Sáp'), findsOneWidget);

    // Tap another crayon and pump through the bounce animation (regression check for negative padding)
    final secondCrayon = find.byType(Tooltip).at(1);
    await tester.tap(secondCrayon);
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('DrawingSelectScreen enters ColoringScreen directly on first card tap without Play Now button',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final theme = AppThemes.byId(GameThemeId.cuteAnimals);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: DrawingSelectScreen(theme: theme),
        ),
      ),
    );
    await pumpUntilLoaded(tester);

    // Verify "CHƠI NGAY" button is not present
    expect(find.text('CHƠI NGAY'), findsNothing);

    // Tap on the first picture card
    final firstCard = find.text('Mèo Con Dễ Thương');
    expect(firstCard, findsOneWidget);
    await tester.tap(firstCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ColoringScreen is pushed directly on first tap
    expect(find.byType(ColoringScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
