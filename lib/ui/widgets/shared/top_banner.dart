import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

enum TopBannerType { success, error, info }

class TopBanner {
  TopBanner._();

  static OverlayEntry? _current;

  static OverlayState overlayOf(BuildContext context) => Overlay.of(context, rootOverlay: true);

  static void show(
    OverlayState overlay,
    String message, {
    Duration duration = const Duration(seconds: 3),
    TopBannerType type = TopBannerType.success,
  }) {
    _current?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopBannerView(
        message: message,
        duration: duration,
        type: type,
        onDismissed: () {
          if (entry.mounted) entry.remove();
          if (identical(_current, entry)) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _TopBannerView extends StatefulWidget {
  final String message;
  final Duration duration;
  final TopBannerType type;
  final VoidCallback onDismissed;

  const _TopBannerView({
    required this.message,
    required this.duration,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_TopBannerView> createState() => _TopBannerViewState();
}

class _TopBannerViewState extends State<_TopBannerView> with SingleTickerProviderStateMixin {
  static const _successBackground = Color(0xFF1F9D6B);
  static const _errorBackground = Color(0xFFC93C4B);

  static const _infoBackground = Color(0xFF4A3F7A);

  Color get _background => switch (widget.type) {
        TopBannerType.success => _successBackground,
        TopBannerType.error => _errorBackground,
        TopBannerType.info => _infoBackground,
      };

  IconData get _icon => switch (widget.type) {
        TopBannerType.success => Icons.check_circle,
        TopBannerType.error => Icons.error,
        TopBannerType.info => Icons.info,
      };

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 240),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));

  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _controller,
              child: GestureDetector(
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -120) _dismiss();
                },
                child: Semantics(
                  liveRegion: true,
                  child: Material(
                    color: _background,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(_icon, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.message,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppAssets.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
