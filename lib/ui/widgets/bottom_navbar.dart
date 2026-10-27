import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem('home', AppAssets.iconHome),
    _NavItem('story', AppAssets.iconStory),
    _NavItem('create', AppAssets.iconCreate),
    _NavItem('parents', AppAssets.iconParents),
  ];

  static const double _barHeight = 56;
  static const double _indicatorWidth = 30;
  static const Duration _slide = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(25),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _items.length;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      key: const Key('nav-indicator'),
                      duration: _slide,
                      curve: Curves.easeInOutCubic,
                      top: 5,
                      left:
                          itemWidth * currentIndex +
                          (itemWidth - _indicatorWidth) / 2,
                      width: _indicatorWidth,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.darkPurple,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          Expanded(
                            child: _NavButton(
                              item: _items[i],
                              selected: i == currentIndex,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final String asset;
  const _NavItem(this.id, this.asset);

  String label(AppLocalizations l10n) => switch (id) {
        'home' => l10n.navHome,
        'story' => l10n.navStory,
        'create' => l10n.navCreate,
        _ => l10n.navParents,
      };
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = item.label(AppLocalizations.of(context));
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        key: Key('nav-${item.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<Color?>(
          duration: BottomNavbar._slide,
          curve: Curves.easeInOutCubic,
          tween: ColorTween(
            end: selected ? AppColors.darkPurple : AppColors.primaryPurple,
          ),
          builder: (context, color, _) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item.asset,
                  width: 20,
                  height: 20,
                  color: color,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppAssets.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
