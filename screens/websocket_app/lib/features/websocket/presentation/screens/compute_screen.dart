import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/provider/app_providers.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/left_sidebar/left_sidebar.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/top_header/top_header.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/cpu_card.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/memory_card.dart';
import 'package:websocket_app/features/websocket/presentation/widgets/compute/compute_details_panel.dart';
import 'package:websocket_app/features/websocket/presentation/screens/power_screen.dart';

class ComputeScreen extends ConsumerWidget {
  const ComputeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeVm = ref.watch(homeViewModelProvider);
    final displayModel = homeVm.displayModel;
    final selectedMenu = homeVm.selectedMenu;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: SafeArea(
        child: Column(
          children: [
            TopHeader(
              upTime: homeVm.upTime,
              wifiConnected: true,
              batteryLevel: homeVm.batteryLevel,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LeftSidebar(
                    selectedMenu: selectedMenu,
                    onMenuSelected: (_) {},
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                      child: selectedMenu == 'COMPUTE'
                          ? _buildDashboardGrid(true, displayModel)
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

  Widget _buildDashboardGrid(bool isDesktopWidth, displayModel) {
    final computePanel = ComputeDetailsPanel(displayModel: displayModel);
    final cpuCard = CpuCard(cpuUsage: displayModel?.cpuUsage ?? 0);
    final memoryCard = MemoryCard(memoryUsage: displayModel?.memoryUsage ?? 0);

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
              _buildSoftwareAndTempRow(displayModel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoftwareAndTempRow(displayModel) {
    final softwareVersionText =
        displayModel?.softwareVersion.isNotEmpty == true
            ? displayModel!.softwareVersion
            : 'v1.2.4-stable';
    final temp = displayModel?.temperature.isNotEmpty == true
        ? displayModel!.temperature
        : '44°C';

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
