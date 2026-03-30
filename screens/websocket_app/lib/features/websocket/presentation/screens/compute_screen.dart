import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/left_sidebar/left_sidebar.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/top_header/top_header.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/cpu_card.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/memory_card.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/compute_details_panel.dart';
import 'package:websocket_app/features/websocket/presentation/screens/power_screen.dart';

class ComputeScreen extends ConsumerStatefulWidget {
  const ComputeScreen({super.key});

  @override
  ConsumerState<ComputeScreen> createState() => _ComputeScreenState();
}

class _ComputeScreenState extends ConsumerState<ComputeScreen> {
  String _selectedMenu = 'COMPUTE';
  Duration _upTime = Duration.zero;
  double _batteryLevel = 0.85;
  Timer? _upTimeTimer;

  @override
  void initState() {
    super.initState();
    _upTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _upTime += const Duration(seconds: 1);
        if (_upTime.inSeconds > 0 && _upTime.inSeconds % (4 * 60) == 0) {
          _batteryLevel = (_batteryLevel - 0.02).clamp(0.0, 1.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _upTimeTimer?.cancel();
    _upTimeTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(telemetryConnectionProvider);

    final service = ref.watch(webSocketServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: SafeArea(
        child: Column(
          children: [
            TopHeader(
              upTime: _upTime,
              wifiConnected: true,
              batteryLevel: _batteryLevel,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LeftSidebar(
                    selectedMenu: _selectedMenu,
                    onMenuSelected: (menu) {
                      setState(() {
                        _selectedMenu = menu;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                      child: _selectedMenu == 'COMPUTE'
                          ? StreamBuilder<Map<String, dynamic>>(
                              stream: service.rawStream,
                              builder: (context, snapshot) {
                                final data = snapshot.data;
                                final cpuUsage = (data?['cpuUsage'] as int?) ?? 0;
                                final memoryUsage = (data?['memoryUsage'] as int?) ?? 0;
                                final temperature = (data?['temperature'] as String?) ?? '';
                                final softwareVersion = (data?['softwareVersion'] as String?) ?? '';

                                return _buildDashboardGrid(
                                  true,
                                  cpuUsage: cpuUsage,
                                  memoryUsage: memoryUsage,
                                  temperature: temperature,
                                  softwareVersion: softwareVersion,
                                );
                              },
                            )
                          : const PowerScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(
    bool isDesktopWidth, {
    required int cpuUsage,
    required int memoryUsage,
    required String temperature,
    required String softwareVersion,
  }) {
    final computePanel = const ComputeDetailsPanel();
    final cpuCard = CpuCard(cpuUsage: cpuUsage);
    final memoryCard = MemoryCard(memoryUsage: memoryUsage);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: computePanel,
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cpuCard,
              const SizedBox(height: 6),
              memoryCard,
              const SizedBox(height: 4),
              _buildSoftwareAndTempRow(softwareVersion, temperature),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoftwareAndTempRow(String softwareVersion, String temperature) {
    final softwareVersionText =
        softwareVersion.isNotEmpty ? softwareVersion : 'v1.2.4-stable';
    final temp = temperature.isNotEmpty ? temperature : '44°C';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Software Version', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            Flexible(
              child: Text(
                softwareVersionText,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Temperature', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(temp, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
