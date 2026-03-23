import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:websocket_app/features/websocket/model/display_model.dart';
import 'package:websocket_app/features/websocket/model/ws_service.dart';

class WebsocketViewModel extends ChangeNotifier {
  final WebSocketService _service;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  DisplayModel? _displayModel;

  WebsocketViewModel(this._service);

  DisplayModel? get displayModel => _displayModel;

  Future<void> init(String host) async {
    await _service.connect('ws://$host:9000');
    _subscription = _service.rawStream.listen((msg) {
      if (msg['type'] == 'data') {
        _displayModel = DisplayModel(
          cpuUsage: msg['cpuUsage'] ?? 0,
          memoryUsage: msg['memoryUsage'] ?? 0,
          temperature: msg['temperature'] ?? '',
          softwareVersion: msg['softwareVersion'] ?? '',
        );
        notifyListeners();
      }
    });
  }

  void disposeAll() {
    _subscription?.cancel();
    _service.dispose();
  }
}
