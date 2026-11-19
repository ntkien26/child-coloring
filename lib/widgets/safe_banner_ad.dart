import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/monetization_ids.dart';
import '../providers/locale_provider.dart';
import '../providers/monetization_provider.dart';
import 'game_ui_kit.dart';

/// Child-safe COPPA banner widget positioned strictly separated from kid touch targets.
class SafeBannerAd extends ConsumerStatefulWidget {
  const SafeBannerAd({super.key});

  @override
  ConsumerState<SafeBannerAd> createState() => _SafeBannerAdState();
}

class _SafeBannerAdState extends ConsumerState<SafeBannerAd> {
  static const bool _adsEnabled = bool.fromEnvironment('ADS_ENABLED');
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadBannerIfSupported());
  }

  void _loadBannerIfSupported() {
    if (!_adsEnabled) return;

    final monetization = ref.read(monetizationProvider);
    if (monetization.isAdsRemoved || monetization.isVipUnlocked) return;

    final adsService = ref.read(adsServiceProvider);
    if (!adsService.isSupportedMobilePlatform) return;

    final unitId = MonetizationIds.bannerAdUnitId;
    if (unitId.isEmpty) return;

    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: adsService.createChildSafeAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    _bannerAd = ad;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monetization = ref.watch(monetizationProvider);
    final s = ref.watch(stringsProvider);

    if (monetization.isAdsRemoved || monetization.isVipUnlocked) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFAEB),
        border: Border(
          top: BorderSide(color: kComicInk, width: 2.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _isLoaded && _bannerAd != null
            ? SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43B649),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'COPPA • G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.safeAdText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
