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
  late Color _previousColor;
  late Color _currentColor;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ColorTransitionTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.index != oldWidget.controller.index) {
      _previousColor = _currentColor;
      _currentColor = widget.tabColors[widget.controller.index];
    }
  }

  @override
  void initState() {
    super.initState();
    _currentColor = widget.tabColors[widget.controller.index];
    _previousColor = _currentColor;

    widget.controller.addListener(() {
      if (!widget.controller.indexIsChanging) return;

      final newColor = widget.tabColors[widget.controller.index];
      setState(() {
        _previousColor = _currentColor;
        _currentColor = newColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: _previousColor, end: _currentColor),
      duration: const Duration(milliseconds: 300),
      builder: (context, color, child) {
        return TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),

          controller: widget.controller,
          isScrollable: true,
          indicatorColor: color,
          labelColor: color,
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
      },
    );
  }
}
