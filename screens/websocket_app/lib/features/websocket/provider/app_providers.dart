import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/model/ws_service.dart';
import 'package:websocket_app/features/websocket/view_model/home_viewmodel.dart';
import 'package:websocket_app/features/websocket/view_model/websocket_viewmodel.dart';

final telemetryHostProvider = Provider<String>((ref) {
  if (Platform.isAndroid) {
    return '10.0.2.2';
  }
  return 'localhost';
});

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

final websocketViewModelProvider =
    ChangeNotifierProvider<WebsocketViewModel>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  final host = ref.watch(telemetryHostProvider);
  final vm = WebsocketViewModel(service);
  vm.init(host);
  ref.onDispose(vm.disposeAll);
  return vm;
});

final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((ref) {
  final vm = HomeViewModel();
  vm.init();
  ref.onDispose(vm.disposeAll);

  ref.listen<WebsocketViewModel>(websocketViewModelProvider, (previous, next) {
    vm.setDisplayModel(next.displayModel);
  });

  return vm;
});
