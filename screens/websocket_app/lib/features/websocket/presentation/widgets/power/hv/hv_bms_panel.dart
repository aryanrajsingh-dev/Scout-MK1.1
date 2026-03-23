import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/dialects/telemetry.dart';

class HvBmsPanel extends ConsumerWidget {
  const HvBmsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(webSocketServiceProvider);

    return StreamBuilder<HvBatteryBms>(
      stream: service.hvBmsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final t = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader('HV Battery (BMS)'),
              const Divider(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _dualMetricRow(
                    'SOH',
                    '${t.soh.toStringAsFixed(0)} %',
                    _sohColor(t.soh.toDouble()),
                    'Capacity Remaining',
                    '${t.capacityRemaining.toStringAsFixed(0)} Ah',
                  ),
                  _dualMetricRow(
                    'Pack Voltage',
                    '${t.packVoltage.toStringAsFixed(1)} V',
                    null,
                    'Pack Current',
                    '${t.packCurrent.toStringAsFixed(1)} A',
                  ),
                  _dualMetricRow(
                    'Max Cell Voltage',
                    '${t.maxCellVoltage.toStringAsFixed(3)} V',
                    null,
                    'Min Cell Voltage',
                    '${t.minCellVoltage.toStringAsFixed(3)} V',
                  ),
                  _dualMetricRow(
                    'Max Cell Temperature',
                    '${t.maxCellTemperature.toStringAsFixed(1)} °C',
                    t.maxCellTemperature > 50 ? Colors.red : null,
                    '',
                    '',
                  ),
                ],
              ),
              const Divider(height: 10),
              const _SectionHeader('FAULTS'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _faultBox('Over Voltage', t.faultOverVoltage != 1),
                  _faultBox('Under Voltage', t.faultUnderVoltage != 1),
                  _faultBox('Over Temperature', t.faultOverTemperature != 1),
                  _faultBox('Cell Imbalance', t.faultCellImbalance != 1),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _sohColor(double soh) {
    if (soh > 80) return Colors.green;
    if (soh > 60) return Colors.orange;
    return Colors.red;
  }

  static TableRow _dualMetricRow(
    String l1,
    String v1,
    Color? c1,
    String l2,
    String v2, [
    Color? c2,
  ]) {
    return TableRow(
      children: [
        _metric(l1, v1, c1),
        _metric(l2, v2, c2),
      ],
    );
  }

  static Widget _metric(String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _faultBox(String label, bool ok) {
    final color = ok ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text(
        label,
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
