import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MonetizationIds {
  MonetizationIds._();

  // IAP Product IDs
  static const String vipUnlockAll = 'kids_coloring_vip_all';
  static const String removeAds = 'kids_coloring_remove_ads';
  static const String packAnimals = 'kids_coloring_pack_animals';
  static const String packVehicles = 'kids_coloring_pack_vehicles';
  static const String packToys = 'kids_coloring_pack_toys';
  static const String packDino = 'kids_coloring_pack_dino';
  static const String packOcean = 'kids_coloring_pack_ocean';
  static const String packSpace = 'kids_coloring_pack_space';

  static const Set<String> allProductIds = {
    vipUnlockAll,
    removeAds,
    packAnimals,
    packVehicles,
    packToys,
    packDino,
    packOcean,
    packSpace,
  };

  // Official Google AdMob Test Ad Unit IDs (Safe for COPPA/Families development)
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }
}
