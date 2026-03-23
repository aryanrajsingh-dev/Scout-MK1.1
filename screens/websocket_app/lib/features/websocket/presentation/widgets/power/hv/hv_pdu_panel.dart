import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/dialects/telemetry.dart';

class HvPduPanel extends ConsumerWidget {
  const HvPduPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(webSocketServiceProvider);

    return StreamBuilder<HvPdu>(
      stream: service.hvPduStream,
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
              const _SectionHeader('HV PDU'),
              const Divider(height: 10),
              _denseMetric('Main Contactor', d.mainContactor == 1 ? 'ON' : 'OFF'),
              const SizedBox(height: 4),
              _denseMetric('Motor Current', '${d.motorCurrent.toStringAsFixed(1)} A'),
              const SizedBox(height: 4),
              _denseMetric('DC-DC Contactor', '${d.dcDcContactor} %'),
              const SizedBox(height: 4),
              _denseMetric('Aux Contactor', '${d.auxContactor} %'),
              const SizedBox(height: 4),
              _denseMetric('DC Bus Voltage', '${d.dcBusVoltage.toStringAsFixed(1)} V'),
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
