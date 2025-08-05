import 'package:flutter/material.dart';

class ColorTransitionTabBar extends StatefulWidget
    implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController controller;
  final List<Color> tabColors;

  const ColorTransitionTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    required this.tabColors,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<ColorTransitionTabBar> createState() => _ColorTransitionTabBarState();
}

class _ColorTransitionTabBarState extends State<ColorTransitionTabBar> {
  @override
  Widget build(BuildContext context) {
    final animation = widget.controller.animation;

    if (animation == null) {
      // Fallback in rare cases when animation is null
      final fallbackColor = widget.tabColors[widget.controller.index];
      return _buildTabBar(fallbackColor);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double value = animation.value;
        final int fromIndex = value.floor().clamp(0, widget.tabColors.length - 1);
        final int toIndex = value.ceil().clamp(0, widget.tabColors.length - 1);
        final double t = value - fromIndex;

        final Color indicatorColor = Color.lerp(
          widget.tabColors[fromIndex],
          widget.tabColors[toIndex],
          t,
        )!;

        return _buildTabBar(indicatorColor);
      },
    );
  }

  Widget _buildTabBar(Color indicatorColor) {
    return TabBar(
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      controller: widget.controller,
      isScrollable: true,
      indicatorColor: indicatorColor,
      labelColor: indicatorColor,
      unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
      tabAlignment: TabAlignment.center,
      tabs: widget.tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;

        return Tab(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: widget.tabColors[index],
            ),
          ),
        );
      }).toList(),
    );
  }
}
