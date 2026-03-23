import 'dart:async';
import 'dart:io';
import 'package:websocket_app/features/websocket/model/ws_service.dart';

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty ? args.first : 'ws://localhost:8080';
  final service = WebSocketService();
  await service.connect(url);

  final sub = service.rawStream.listen((_) {}, onError: (_) {});

  final done = Completer<void>();
  ProcessSignal.sigint.watch().listen((_) async {
    await sub.cancel();
    service.dispose();
    done.complete();
  });

  await done.future;
}
