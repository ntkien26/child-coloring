import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/audio_service.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await AudioService.instance.init();
  runApp(const ProviderScope(child: KidsColoringApp()));
}

/// Applies the chunky rounded "Baloo 2" look (variable weight axis) to every text style.
TextTheme _chunkyTextTheme(TextTheme t) {
  const variations = [FontVariation('wght', 800)];
  TextStyle? f(TextStyle? s) =>
      s?.copyWith(fontVariations: variations, height: 1.15);
  return t.copyWith(
    displayLarge: f(t.displayLarge),
    displayMedium: f(t.displayMedium),
    displaySmall: f(t.displaySmall),
    headlineLarge: f(t.headlineLarge),
    headlineMedium: f(t.headlineMedium),
    headlineSmall: f(t.headlineSmall),
    titleLarge: f(t.titleLarge),
    titleMedium: f(t.titleMedium),
    titleSmall: f(t.titleSmall),
    bodyLarge: f(t.bodyLarge),
    bodyMedium: f(t.bodyMedium),
    bodySmall: f(t.bodySmall),
    labelLarge: f(t.labelLarge),
    labelMedium: f(t.labelMedium),
    labelSmall: f(t.labelSmall),
  );
}

class KidsColoringApp extends ConsumerWidget {
  const KidsColoringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF7A2F),
        brightness: Brightness.light,
      ),
      fontFamily: 'Baloo2',
    );

    return MaterialApp(
      title: s.appTitle,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(textTheme: _chunkyTextTheme(base.textTheme)),
      home: const SplashScreen(),
    );
  }
}
