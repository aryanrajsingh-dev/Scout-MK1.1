import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:websocket_app/core/utils/app_theme.dart';

class MemoryCard extends StatelessWidget {
	final int memoryUsage;
	final double totalMemoryGB;

	const MemoryCard({
		super.key,
		required this.memoryUsage,
		this.totalMemoryGB = 16,
	});

	@override
	Widget build(BuildContext context) {
		final clamped = memoryUsage.clamp(0, 100);
		final usedValue = clamped / 100 * totalMemoryGB;
		final usedGb = usedValue.toStringAsFixed(1);
		final freeGb = (totalMemoryGB - usedValue).clamp(0, totalMemoryGB).toStringAsFixed(1);

		return ClipRRect(
			borderRadius: BorderRadius.circular(AppTheme.cardRadius),
			child: BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
				child: Container(
					padding: const EdgeInsets.fromLTRB(
						AppTheme.cardPadding,
						AppTheme.cardPadding * 0.55,
						AppTheme.cardPadding,
						AppTheme.cardPadding * 0.55,
					),
					decoration: BoxDecoration(
						color: AppTheme.cardBackground,
						borderRadius: BorderRadius.circular(AppTheme.cardRadius),
						border: Border.all(
							color: AppTheme.cardBorder.withOpacity(0.6),
							width: 1,
						),
						boxShadow: const [
							BoxShadow(
								color: Colors.black54,
								blurRadius: 18,
								offset: Offset(0, 10),
							),
						],
					),
					child: Column(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text(
									'MEMORY USAGE',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										color: AppTheme.accentCyan,
										letterSpacing: 1.5,
									),
								),
								Text(
									'$clamped%',
									style: Theme.of(context).textTheme.headlineSmall?.copyWith(
										color: AppTheme.textPrimary,
										fontWeight: FontWeight.bold,
										fontSize: 18.sp,
									),
								),
							],
						),
						const SizedBox(height: 6),
						Container(
							height: 14,
							decoration: BoxDecoration(
								color: Colors.white.withOpacity(0.06),
								borderRadius: BorderRadius.circular(7),
							),
							child: Align(
								alignment: Alignment.centerLeft,
								child: FractionallySizedBox(
									widthFactor: clamped / 100,
									child: Container(
										decoration: BoxDecoration(
											color: _colorForUsage(clamped),
											borderRadius: BorderRadius.circular(7),
											boxShadow: [
												BoxShadow(
													color: _colorForUsage(clamped).withOpacity(0.5),
													blurRadius: 8,
													spreadRadius: 1,
												),
											],
										),
									),
								),
							),
						),
						const SizedBox(height: 6),
						Row(
							children: [
								Text(
									'$usedGb GB / ${totalMemoryGB.toStringAsFixed(0)} GB',
									style: TextStyle(
										color: AppTheme.textSecondary.withOpacity(0.75),
										fontSize: 11.sp,
									),
								),
								const Spacer(),
								Text(
									'Free $freeGb GB',
									style: TextStyle(
										color: AppTheme.textSecondary.withOpacity(0.85),
										fontSize: 11.sp,
										fontWeight: FontWeight.w500,
									),
									textAlign: TextAlign.right,
								),
							],
						),
					],
				),
				),
			),
		);
	}

	static Color _colorForUsage(int percent) {
		if (percent < 60) return const Color(0xFF00E676);
		if (percent < 85) return const Color(0xFFFFC107);
		return const Color(0xFFFF5252);
	}
}
