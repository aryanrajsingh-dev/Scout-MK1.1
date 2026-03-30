import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:websocket_app/features/websocket/model/ws_service.dart';

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

final telemetryConnectionProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(webSocketServiceProvider);
  final host = ref.watch(telemetryHostProvider);
  await service.connect('ws://$host:9000');
});
