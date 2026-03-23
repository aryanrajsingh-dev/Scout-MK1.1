import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'battery_indicator.dart';
import 'mode_indicator.dart';
import 'package:websocket_app/core/utils/time_formatter.dart';

class TopHeader extends StatelessWidget {
	final Duration upTime;
	final bool wifiConnected;
	final double batteryLevel;

	const TopHeader({
		super.key,
		required this.upTime,
		required this.wifiConnected,
		required this.batteryLevel,
	});

	@override
	Widget build(BuildContext context) {
		final modeWidget = const ModeIndicator(mode: 'SAFE HOLD');
		final scoutWidget = Text(
			'SCOUT MK1.1',
			style: const TextStyle(
				color: Colors.white70,
				fontSize: 13,
				fontWeight: FontWeight.w600,
				letterSpacing: 1.4,
			),
		);

		final uptimeWidget = _buildInfoItem(context, 'UP TIME', TimeFormatter.formatUpTime(upTime));

		final wifiWidget = Icon(
			Icons.wifi,
			color: wifiConnected ? Colors.cyan : Colors.grey,
			size: 20,
		);

		final dateTimeWidget = Text(
			'${TimeFormatter.getCurrentDate()}  ${TimeFormatter.getCurrentTime()}',
			style: const TextStyle(
				color: Colors.white,
				fontSize: 13,
				fontWeight: FontWeight.bold,
			),
			overflow: TextOverflow.ellipsis,
			softWrap: false,
		);

		final batteryWidget = BatteryIndicator(batteryLevel: batteryLevel);

		return Container(
			width: double.infinity,
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
			decoration: BoxDecoration(
				color: Colors.black,
				border: Border(
					bottom: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
				),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					scoutWidget,
					modeWidget,
					uptimeWidget,
					wifiWidget,
					dateTimeWidget,
					batteryWidget,
				],
			),
		);
	}

	Widget _buildInfoItem(BuildContext context, String label, String value) {
		final theme = Theme.of(context).textTheme;
		final labelStyle = TextStyle(
			color: Colors.white,
			fontWeight: FontWeight.bold,
			fontSize: 14,
		);
		final valueStyle = TextStyle(
			color: Colors.white,
			fontWeight: FontWeight.bold,
			fontSize: 14,
		);
		return RichText(
			text: TextSpan(
				children: [
					TextSpan(
						text: '$label : ',
						style: labelStyle,
					),
					TextSpan(
						text: value,
						style: valueStyle,
					),
				],
			),
		);
	}
}
