import 'package:flutter/material.dart';

import 'package:websocket_app/features/websocket/presentation/widgets/power/lv/lv_battery_panel.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/power/lv/lv_pdu_panel.dart';

class LvGroup extends StatelessWidget {
  const LvGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 5, child: LvBatteryPanel()),
        VerticalDivider(width: 1),
        Expanded(flex: 6, child: LvPduPanel()),
      ],
    );
  }
}
