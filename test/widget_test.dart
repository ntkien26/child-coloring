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

  testWidgets('HomeScreen renders cleanly on Phone (390x844) without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: KidsColoringApp()));
    await pumpUntilLoaded(tester);

    expect(find.text('Bé Tập Tô Màu 2D'), findsOneWidget);
    expect(find.text('Mèo Con Dễ Thương'), findsOneWidget);
    expect(find.text('Sư Tử Nhí'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen renders cleanly on Tablet (1024x768) without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: KidsColoringApp()));
    await pumpUntilLoaded(tester);

    expect(find.text('Bé Tập Tô Màu 2D'), findsOneWidget);
    expect(find.text('Mèo Con Dễ Thương'), findsOneWidget);
    expect(find.text('Sư Tử Nhí'), findsOneWidget);
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
    expect(find.text('Bảng 24 Bút Sáp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
