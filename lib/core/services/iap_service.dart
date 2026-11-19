import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/monetization_ids.dart';

class IapProductInfo {
  const IapProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
  });

  final String id;
  final String title;
  final String description;
  final String priceLabel;
}

class IapService {
  IapService({this.mockMode = true});

  /// Mock mode allows testing VIP/pack unlocks immediately without store billing.
  final bool mockMode;

  static const String _unlockedProductsKey = 'kids_coloring_unlocked_products';
  static const String _unlockedPagesKey = 'kids_coloring_unlocked_pages';

  final Set<String> _unlockedProducts = {};
  final Set<String> _unlockedPages = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _storeAvailable = false;

  Set<String> get unlockedProducts => Set.unmodifiable(_unlockedProducts);
  Set<String> get unlockedPages => Set.unmodifiable(_unlockedPages);
  bool get isVipUnlocked =>
      _unlockedProducts.contains(MonetizationIds.vipUnlockAll);
  bool get isAdsRemoved =>
      isVipUnlocked || _unlockedProducts.contains(MonetizationIds.removeAds);
  bool get isStoreAvailable => _storeAvailable;

  static const List<IapProductInfo> mockCatalog = [
    IapProductInfo(
      id: MonetizationIds.vipUnlockAll,
      title: 'Gói VIP Toàn Bộ Tranh',
      description: 'Mở khóa toàn bộ tranh cao cấp, cọ đặc biệt & tắt quảng cáo.',
      priceLabel: '79.000đ',
    ),
    IapProductInfo(
      id: MonetizationIds.removeAds,
      title: 'Gỡ Quảng Cáo',
      description: 'Trải nghiệm tô màu an toàn, không quảng cáo cho bé.',
      priceLabel: '39.000đ',
    ),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedProducts
      ..clear()
      ..addAll(prefs.getStringList(_unlockedProductsKey) ?? const []);
    _unlockedPages
      ..clear()
      ..addAll(prefs.getStringList(_unlockedPagesKey) ?? const []);

    if (mockMode || kIsWeb) {
      _storeAvailable = true;
      return;
    }

    try {
      final iap = InAppPurchase.instance;
      _storeAvailable = await iap.isAvailable();
      if (_storeAvailable) {
        _purchaseSub = iap.purchaseStream.listen(_handlePurchaseUpdates);
      }
    } catch (e) {
      debugPrint('IAP store init fallback to mock: $e');
      _storeAvailable = false;
    }
  }

  Future<bool> purchaseProduct(String productId) async {
    if (mockMode || kIsWeb || !_storeAvailable) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _unlockedProducts.add(productId);
      await _persist();
      return true;
    }

    try {
      final iap = InAppPurchase.instance;
      final response = await iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) return false;
      final param = PurchaseParam(productDetails: response.productDetails.first);
      return await iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP purchase error: $e');
      return false;
    }
  }

  Future<void> unlockPage(String pageId) async {
    _unlockedPages.add(pageId);
    await _persist();
  }

  Future<bool> restorePurchases() async {
    if (mockMode || kIsWeb || !_storeAvailable) {
      final prefs = await SharedPreferences.getInstance();
      _unlockedProducts
        ..clear()
        ..addAll(prefs.getStringList(_unlockedProductsKey) ?? const []);
      return _unlockedProducts.isNotEmpty;
    }
    try {
      await InAppPurchase.instance.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('IAP restore error: $e');
      return false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _unlockedProducts.add(purchase.productID);
        await _persist();
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedProductsKey, _unlockedProducts.toList());
    await prefs.setStringList(_unlockedPagesKey, _unlockedPages.toList());
  }

  void dispose() {
    _purchaseSub?.cancel();
  }
}
