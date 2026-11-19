import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import 'game_ui_kit.dart';

/// Child-safe Parental Gate requiring an adult to press and hold for 2.5 seconds.
Future<bool> showParentalGate(
  BuildContext context, {
  String? reason,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => ParentalGateDialog(reason: reason),
  );
  return result ?? false;
}

class ParentalGateDialog extends ConsumerStatefulWidget {
  const ParentalGateDialog({
    super.key,
    this.reason,
  });

  final String? reason;

  @override
  ConsumerState<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends ConsumerState<ParentalGateDialog>
    with SingleTickerProviderStateMixin {
  static const Duration _holdDuration = Duration(milliseconds: 2500);
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_completed) {
          _completed = true;
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    if (!_completed) {
      _controller.forward();
    }
  }

  void _cancelHold() {
    if (!_completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final title = widget.reason ?? s.parentalGateTitle;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kParchmentTop,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: kComicInk, width: 3.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9800), width: 3),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFFF7043),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.parentalGateHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTapDown: (_) => _startHold(),
                onTapUp: (_) => _cancelHold(),
                onTapCancel: _cancelHold,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final pct = (_controller.value * 100).round();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 114,
                          height: 114,
                          child: CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 9,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF43B649),
                            ),
                          ),
                        ),
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: _controller.value > 0
                                ? const Color(0xFF43B649)
                                : const Color(0xFF2196F3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pct > 0 ? '$pct%' : s.holdLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  s.close,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
