import 'package:flutter/material.dart';
import 'package:metia/widgets/color_transition_tab_bar.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: Text("wdowadoawjd"),
        bottom: ColorTransitionTabBar(
          tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
          controller: _tabController,
          tabColors: [Colors.red, Colors.green, Colors.blue],
        ),
      ),
    );
  }
}
