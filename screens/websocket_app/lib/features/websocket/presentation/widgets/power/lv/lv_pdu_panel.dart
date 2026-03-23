import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/mavlink/telemetry.dart';

class LvPduPanel extends ConsumerWidget {
  const LvPduPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(webSocketServiceProvider);

    return StreamBuilder<LvPduStatus>(
      stream: service.lvPduStream,
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
              const _SectionHeader('LV PDU'),
              const Divider(height: 10),
              _denseMetric('Input Voltage', '${d.inputVoltage.toStringAsFixed(2)} V'),
              const SizedBox(height: 4),
              _denseMetric('Input Current', '${d.inputCurrent.toStringAsFixed(1)} A'),
              const SizedBox(height: 4),
              _denseMetric('Input Power', '${d.inputPower.toStringAsFixed(1)} W'),
              const SizedBox(height: 4),
              _denseMetric('Output Current', '${d.outputCurrent.toStringAsFixed(1)} A'),
              const SizedBox(height: 4),
              _denseMetric('Load Power', '${d.loadPower.toStringAsFixed(1)} W'),
              const SizedBox(height: 4),
              _denseMetric('Temperature', '${d.temperature.toStringAsFixed(1)} °C'),
              const SizedBox(height: 4),
              _denseMetric('CAN Status', d.canOk ? 'ON' : 'OFF'),
              const SizedBox(height: 4),
              const _SectionHeader('Output Channels'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(6, (index) {
                  final enabled = d.channelEnabled(index);
                  final current =
                      index < d.channelCurrents.length ? d.channelCurrents[index] : 0.0;
                  return _channel('CH ${index + 1}', enabled, current);
                }),
              ),
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

  Widget _channel(String label, bool enabled, double current) {
    final color = enabled ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text(
        '$label  ${current.toStringAsFixed(1)}A',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
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
