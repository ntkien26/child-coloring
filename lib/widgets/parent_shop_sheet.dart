import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/monetization_ids.dart';
import '../core/services/audio_service.dart';
import '../providers/locale_provider.dart';
import '../providers/monetization_provider.dart';
import 'game_ui_kit.dart';
import 'parental_gate.dart';

Future<void> openParentVipShop(BuildContext context, WidgetRef ref) async {
  final s = ref.read(stringsProvider);
  final passed = await showParentalGate(
    context,
    reason: s.parentalShopTitle,
  );
  if (!passed || !context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ParentShopSheet(),
  );
}

class ParentShopSheet extends ConsumerWidget {
  const ParentShopSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monetization = ref.watch(monetizationProvider);
    final s = ref.watch(stringsProvider);

    final products = [
      (
        id: MonetizationIds.vipUnlockAll,
        title: s.vipProductTitle,
        description: s.vipProductDesc,
        price: '79.000đ',
        color: const Color(0xFFFFA000),
      ),
      (
        id: MonetizationIds.removeAds,
        title: s.removeAdsTitle,
        description: s.removeAdsDesc,
        price: '39.000đ',
        color: const Color(0xFF2196F3),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kParchmentTop,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: kComicInk, width: 3.4),
          left: BorderSide(color: kComicInk, width: 3.4),
          right: BorderSide(color: kComicInk, width: 3.4),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFA000),
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.parentalShopTitle,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...products.map((product) {
              final owned = monetization.isVipUnlocked ||
                  (product.id == MonetizationIds.removeAds &&
                      monetization.isAdsRemoved);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: owned
                        ? const Color(0xFF43B649)
                        : product.color.withValues(alpha: 0.45),
                    width: 2.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    JuicyButton(
                      color: owned ? const Color(0xFF43B649) : product.color,
                      enabled: !owned && !monetization.isBusy,
                      borderRadius: 18,
                      depth: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      onTap: owned || monetization.isBusy
                          ? null
                          : () async {
                              final ok = await ref
                                  .read(monetizationProvider.notifier)
                                  .purchaseProduct(product.id);
                              if (ok) {
                                AudioService.instance.playSparkle();
                              }
                            },
                      child: Text(
                        owned ? s.owned : product.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: monetization.isBusy
                  ? null
                  : () => ref
                      .read(monetizationProvider.notifier)
                      .restorePurchases(),
              icon: const Icon(Icons.restore_rounded),
              label: Text(
                s.restorePurchases,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
