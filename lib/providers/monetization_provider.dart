import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/monetization_ids.dart';
import '../core/services/ads_service.dart';
import '../core/services/iap_service.dart';
import '../models/coloring_page.dart';

class MonetizationState {
  const MonetizationState({
    this.isInitialized = false,
    this.isBusy = false,
    this.isVipUnlocked = false,
    this.isAdsRemoved = false,
    this.unlockedPageIds = const {},
    this.statusMessage,
  });

  final bool isInitialized;
  final bool isBusy;
  final bool isVipUnlocked;
  final bool isAdsRemoved;
  final Set<String> unlockedPageIds;
  final String? statusMessage;

  bool isPageUnlocked(ColoringPage page) {
    if (!page.isLocked) return true;
    if (isVipUnlocked) return true;
    return unlockedPageIds.contains(page.id);
  }

  MonetizationState copyWith({
    bool? isInitialized,
    bool? isBusy,
    bool? isVipUnlocked,
    bool? isAdsRemoved,
    Set<String>? unlockedPageIds,
    String? statusMessage,
  }) {
    return MonetizationState(
      isInitialized: isInitialized ?? this.isInitialized,
      isBusy: isBusy ?? this.isBusy,
      isVipUnlocked: isVipUnlocked ?? this.isVipUnlocked,
      isAdsRemoved: isAdsRemoved ?? this.isAdsRemoved,
      unlockedPageIds: unlockedPageIds ?? this.unlockedPageIds,
      statusMessage: statusMessage,
    );
  }
}

class MonetizationNotifier extends StateNotifier<MonetizationState> {
  MonetizationNotifier(this._iapService, this._adsService)
      : super(const MonetizationState()) {
    init();
  }

  final IapService _iapService;
  final AdsService _adsService;

  AdsService get adsService => _adsService;

  Future<void> init() async {
    await _iapService.init();
    await _adsService.init();
    state = state.copyWith(
      isInitialized: true,
      isVipUnlocked: _iapService.isVipUnlocked,
      isAdsRemoved: _iapService.isAdsRemoved,
      unlockedPageIds: Set<String>.from(_iapService.unlockedPages),
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    state = state.copyWith(isBusy: true);
    final success = await _iapService.purchaseProduct(productId);
    state = state.copyWith(
      isBusy: false,
      isVipUnlocked: _iapService.isVipUnlocked,
      isAdsRemoved: _iapService.isAdsRemoved,
      unlockedPageIds: Set<String>.from(_iapService.unlockedPages),
      statusMessage: success
          ? 'Mở khóa thành công!'
          : 'Không thể hoàn tất giao dịch lúc này.',
    );
    return success;
  }

  Future<bool> purchaseVip() => purchaseProduct(MonetizationIds.vipUnlockAll);

  Future<bool> unlockPageWithRewardedAd(ColoringPage page) async {
    state = state.copyWith(isBusy: true);
    bool earned = false;
    await _adsService.showRewardedAdForUnlock(
      onRewardEarned: () {
        earned = true;
      },
    );
    if (earned) {
      await _iapService.unlockPage(page.id);
    }
    state = state.copyWith(
      isBusy: false,
      unlockedPageIds: Set<String>.from(_iapService.unlockedPages),
      statusMessage: earned
          ? 'Đã mở khóa tranh "${page.name}"!'
          : 'Chưa hoàn thành xem video thưởng.',
    );
    return earned;
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isBusy: true);
    final restored = await _iapService.restorePurchases();
    state = state.copyWith(
      isBusy: false,
      isVipUnlocked: _iapService.isVipUnlocked,
      isAdsRemoved: _iapService.isAdsRemoved,
      unlockedPageIds: Set<String>.from(_iapService.unlockedPages),
      statusMessage: restored
          ? 'Đã khôi phục gói mua!'
          : 'Không tìm thấy giao dịch trước đó.',
    );
    return restored;
  }

  @override
  void dispose() {
    _iapService.dispose();
    _adsService.dispose();
    super.dispose();
  }
}

final iapServiceProvider = Provider<IapService>(
  (ref) => IapService(mockMode: true),
);

final adsServiceProvider = Provider<AdsService>(
  (ref) => AdsService(mockMode: false),
);

final monetizationProvider =
    StateNotifierProvider<MonetizationNotifier, MonetizationState>((ref) {
  return MonetizationNotifier(
    ref.watch(iapServiceProvider),
    ref.watch(adsServiceProvider),
  );
});
