import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../data/models/story.dart';
import '../../view_models/story/story_filter_view_model.dart';

class StoryFilterTabs extends StatefulWidget {
  const StoryFilterTabs({super.key});

  @override
  State<StoryFilterTabs> createState() => _StoryFilterTabsState();
}

class _StoryFilterTabsState extends State<StoryFilterTabs> {
  static const double _height = 40;
  static const double _iconSlot = 40;
  static const Duration _slide = Duration(milliseconds: 280);
  static const Curve _curve = Curves.easeInOutCubic;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSearch(StoryFilterViewModel viewModel) {
    viewModel.toggleSearch(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) viewModel.searchFocusNode.requestFocus();
    });
  }

  void _closeSearch(StoryFilterViewModel viewModel) {
    viewModel.toggleSearch(false);
    viewModel.searchFocusNode.unfocus();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryFilterViewModel>();
    final searching = viewModel.isSearching;

    return TapRegion(
      enabled: searching,
      onTapOutside: (_) => _closeSearch(viewModel),
      child: SizedBox(
        height: _height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  right: _iconSlot + 12,
                  child: IgnorePointer(
                    ignoring: searching,
                    child: AnimatedOpacity(
                      key: const Key('tabs-layer'),
                      duration: _slide,
                      curve: _curve,
                      opacity: searching ? 0 : 1,
                      child: AnimatedSlide(
                        duration: _slide,
                        curve: _curve,
                        offset: searching
                            ? const Offset(-0.25, 0)
                            : Offset.zero,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _SlidingTabs(
                              selected: viewModel.tab,
                              onSelected: viewModel.setTab,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: _slide,
                    curve: _curve,
                    width: searching ? constraints.maxWidth : _iconSlot,
                    height: _height,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: searching ? 0.15 : 0,
                      ),
                      borderRadius: BorderRadius.circular(_height / 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_height / 2),
                      child: Row(
                        children: [
                          GestureDetector(
                            key: const Key('open-search'),
                            behavior: HitTestBehavior.opaque,
                            onTap: searching
                                ? null
                                : () => _openSearch(viewModel),
                            child: const SizedBox(
                              width: _iconSlot,
                              height: _height,
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: searching,
                              focusNode: viewModel.searchFocusNode,
                              onChanged: viewModel.search,
                              textInputAction: TextInputAction.search,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                hintText: 'Search stories...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(right: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlidingTabs extends StatelessWidget {
  final StoryTab selected;
  final ValueChanged<StoryTab> onSelected;

  const _SlidingTabs({required this.selected, required this.onSelected});

  static const double _padding = 18;
  static const double _height = 36;
  static const TextStyle _style = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  double _textWidth(BuildContext context, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(_style),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = StoryTab.values;
    final widths = [
      for (final tab in tabs) _textWidth(context, tab.label) + _padding * 2,
    ];
    final selectedIndex = tabs.indexOf(selected);
    final pillLeft = widths
        .take(selectedIndex)
        .fold<double>(0, (sum, width) => sum + width);

    return SizedBox(
      width: widths.fold<double>(0, (sum, width) => sum + width),
      height: _height,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            left: pillLeft,
            width: widths[selectedIndex],
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [AppColors.btnStory, AppColors.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(_height / 2),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                GestureDetector(
                  key: Key('tab-${tabs[i].name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(tabs[i]),
                  child: SizedBox(
                    width: widths[i],
                    height: _height,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOutCubic,
                        style: _style.copyWith(
                          color: tabs[i] == selected
                              ? Colors.black
                              : Colors.white70,
                        ),
                        child: Text(tabs[i].label),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
