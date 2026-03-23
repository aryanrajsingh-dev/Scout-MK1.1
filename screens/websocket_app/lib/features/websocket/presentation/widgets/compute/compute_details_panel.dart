import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:websocket_app/core/extensions/spacing_extensions.dart';
import 'package:websocket_app/features/websocket/model/display_model.dart';

class ComputeDetailsPanel extends StatelessWidget {
  final DisplayModel? displayModel;

  const ComputeDetailsPanel({super.key, this.displayModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final headerBase = theme.bodyMedium ?? TextStyle(fontSize: 12.sp);
    final cellBase = theme.bodyMedium ?? TextStyle(fontSize: 12.sp);
    final sectionTitleStyle = theme.titleMedium?.copyWith(
          color: Colors.cyan,
          letterSpacing: 1.5,
        ) ??
        TextStyle(
          color: Colors.cyan,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        );
    final headerStyle = headerBase.copyWith(
      color: Colors.white70,
      fontWeight: FontWeight.w600,
    );
    final cellStyle = cellBase.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MISSION COMPUTER HEALTH', style: sectionTitleStyle),
          2.hBox,
          Expanded(
            child: _buildMissionHealthTable(headerStyle, cellStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHealthTable(TextStyle headerStyle, TextStyle cellStyle) {
    const modules = [
      {'name': 'Hardware interface', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'CAN Actuator', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'CAN Sensor', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'RS 485', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Controller', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Localization', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Navigation', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Mission Manager', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Display interface', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Display App', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Logger', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Telemetry', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
      {'name': 'Scheduler', 'active': 'ACTIVE', 'inactive': 'INACTIVE'},
    ];

    return _buildSimpleTable(
      headers: const ['Module', 'Status'],
      rows: modules.map((m) => [m['name']!, m['active']!]).toList(),
      headerStyle: headerStyle,
      cellStyle: cellStyle,
    );
  }

  Widget _buildSimpleTable({
    required List<String> headers,
    required List<List<String>> rows,
    required TextStyle headerStyle,
    required TextStyle cellStyle,
  }) {
    final isStatusTable = headers.length == 2 && headers[1] == 'Status';

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < headers.length; i++)
              Expanded(
                flex: i == 0 ? 3 : 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                  child: Text(headers[i], style: headerStyle),
                ),
              ),
          ],
        ),
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final row in rows)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        for (int i = 0; i < headers.length; i++)
                          Expanded(
                            flex: i == 0 ? 3 : 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                              child: Builder(
                                builder: (context) {
                                  final text = i < row.length ? row[i] : '';
                                  TextStyle style = cellStyle;

                                  if (isStatusTable && i == 1) {
                                    final upper = text.toUpperCase();
                                    if (upper == 'ACTIVE') {
                                      style = style.copyWith(color: Colors.greenAccent);
                                    } else if (upper.contains('NOT') || upper.contains('INACTIVE')) {
                                      style = style.copyWith(color: Colors.redAccent);
                                    }
                                  }

                                  return Text(
                                    text,
                                    style: style,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
