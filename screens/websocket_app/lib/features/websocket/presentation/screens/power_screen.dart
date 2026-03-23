import 'package:flutter/material.dart';

import 'package:websocket_app/features/websocket/presentation/widgets/power/hv/hv_group.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/power/lv/lv_group.dart';

class PowerScreen extends StatelessWidget {
  const PowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _PowerTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                HvGroup(),
                LvGroup(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerTabBar extends StatelessWidget {
  const _PowerTabBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      child: SizedBox(
        height: 34,
        child: const TabBar(
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          tabs: [
            Tab(text: 'HV'),
            Tab(text: 'LV'),
          ],
        ),
      ),
    );
  }
}
