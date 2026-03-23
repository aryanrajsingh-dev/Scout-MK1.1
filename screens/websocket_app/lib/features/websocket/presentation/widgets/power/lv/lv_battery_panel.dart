import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/dialects/telemetry.dart';

class LvBatteryPanel extends ConsumerWidget {
  const LvBatteryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(webSocketServiceProvider);

    return StreamBuilder<LvBattery>(
      stream: service.lvBatteryStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final d = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader('LV Battery'),
              const Divider(height: 10),
              _denseMetric('Voltage', '${d.voltage.toStringAsFixed(2)} V'),
              const SizedBox(height: 4),
              _denseMetric('Current', '${d.current.toStringAsFixed(2)} A'),
            ],
          ),
        );
      },
    );
  }

  Widget _denseMetric(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}
