import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/presentation/widgets/power/hv/hv_bms_panel.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/power/hv/hv_pdu_panel.dart';

class HvGroup extends StatelessWidget {
  const HvGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 3, child: HvBmsPanel()),
        VerticalDivider(width: 1),
        Expanded(flex: 2, child: HvPduPanel()),
      ],
    );
  }
}
