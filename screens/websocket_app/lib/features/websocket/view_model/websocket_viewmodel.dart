import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:websocket_app/features/websocket/model/ws_service.dart';

class WebsocketViewModel extends ChangeNotifier {
  final WebSocketService _service;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  WebsocketViewModel(this._service);
  Map<String, dynamic>? _latestTelemetry;
  Map<String, dynamic>? get latestTelemetry => _latestTelemetry;

  Future<void> init(String host) async {
    await _service.connect('ws://$host:9000');
    _subscription = _service.rawStream.listen((msg) {
      if (msg['type'] == 'data') {
        _latestTelemetry = msg;
        notifyListeners();
      }
    });
  }

  void disposeAll() {
    _subscription?.cancel();
    _service.dispose();
  }
}
