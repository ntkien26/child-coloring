import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/monetization_ids.dart';

class AdsService {
  AdsService({this.mockMode = false});

  final bool mockMode;
  bool _initialized = false;
  RewardedAd? _rewardedAd;

  // Ads stay disabled until an AdMob application ID is configured for Android.
  // Enable explicitly with: --dart-define=ADS_ENABLED=true
  static const bool _adsEnabled = bool.fromEnvironment('ADS_ENABLED');

  bool get isSupportedMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isInitialized => _initialized;

  /// Initializes AdMob with strict COPPA / Families Policy compliance:
  /// - TagForChildDirectedTreatment.yes
  /// - MaxAdContentRating.g
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (mockMode || !_adsEnabled || !isSupportedMobilePlatform) {
      return;
    }

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          ageRestrictedTreatment: AgeRestrictedTreatment.child,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );
      await MobileAds.instance.initialize();
      await loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob init skipped: $e');
    }
  }

  AdRequest createChildSafeAdRequest() {
    return const AdRequest(
      nonPersonalizedAds: true,
    );
  }

  Future<void> loadRewardedAd() async {
    if (mockMode || !_adsEnabled || !isSupportedMobilePlatform) return;
    final unitId = MonetizationIds.rewardedAdUnitId;
    if (unitId.isEmpty) return;

    await RewardedAd.load(
      adUnitId: unitId,
      request: createChildSafeAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd load failed: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Shows a child-safe Rewarded Ad (or mock test flow on Web/Desktop) and
  /// invokes [onRewardEarned] when completed.
  Future<bool> showRewardedAdForUnlock({
    required VoidCallback onRewardEarned,
  }) async {
    if (mockMode ||
        !_adsEnabled ||
        !isSupportedMobilePlatform ||
        _rewardedAd == null) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      onRewardEarned();
      return true;
    }

    final completer = Completer<bool>();
    final ad = _rewardedAd!;
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (adWithoutView, reward) {
        onRewardEarned();
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
