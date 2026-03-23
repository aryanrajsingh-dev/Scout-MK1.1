import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:comm_module/comm_module.dart';
import 'package:mavlink_nrt/mavlink_parser.dart';
import 'package:websocket_app/mavlink/telemetry.dart';

class WebSocketService {
  late Transport _transport;
  late final Stream<Map<String, dynamic>> rawStream;
  final StreamController<Map<String, dynamic>> _ctrl = StreamController<Map<String, dynamic>>();
  late final MavlinkParser _mavParser;

  final StreamController<HvBmsTelemetry> _hvBmsCtrl = StreamController<HvBmsTelemetry>.broadcast();
  final StreamController<HvPduStatus> _hvPduCtrl = StreamController<HvPduStatus>.broadcast();
  final StreamController<LvBatteryStatus> _lvBatteryCtrl = StreamController<LvBatteryStatus>.broadcast();
  final StreamController<LvPduStatus> _lvPduCtrl = StreamController<LvPduStatus>.broadcast();

  Stream<HvBmsTelemetry> get hvBmsStream => _hvBmsCtrl.stream;
  Stream<HvPduStatus> get hvPduStream => _hvPduCtrl.stream;
  Stream<LvBatteryStatus> get lvBatteryStream => _lvBatteryCtrl.stream;
  Stream<LvPduStatus> get lvPduStream => _lvPduCtrl.stream;

  WebSocketService() {
    rawStream = _ctrl.stream.asBroadcastStream();

    final dialect = MavlinkDialectTelemetry();
    _mavParser = MavlinkParser(dialect);

    _mavParser.stream.listen((frame) {
      final msg = frame.message;
      if (msg is ComputeTelemetry) {
        String _charsToString(List<int> chars) {
          final bytes = chars
              .takeWhile((c) => c != 0)
              .map((c) => c & 0xFF)
              .toList();
          return String.fromCharCodes(bytes);
        }

        _ctrl.add({
          'type': 'data',
          'cpuUsage': msg.cpuUsage,
          'memoryUsage': msg.memoryUsage,
          'temperature': _charsToString(msg.temperature),
          'softwareVersion': _charsToString(msg.softwareVersion),
        });
      } else if (msg is HvBmsTelemetry) {
        _hvBmsCtrl.add(msg);
      } else if (msg is HvPduStatus) {
        _hvPduCtrl.add(msg);
      } else if (msg is LvBatteryStatus) {
        _lvBatteryCtrl.add(msg);
      } else if (msg is LvPduStatus) {
        _lvPduCtrl.add(msg);
      }
    });
  }

  Future<void> connect(String wsUrl) async {
    final uri = Uri.parse(wsUrl.replaceFirst('ws://', 'http://'));
    final port = uri.hasPort ? uri.port : 8080;

    InternetAddress serverAddress;
    try {
      final addrs = await InternetAddress.lookup(uri.host);
      serverAddress = addrs.firstWhere(
        (a) => a.type == InternetAddressType.IPv4,
        orElse: () => addrs.first,
      );
    } catch (e) {
      serverAddress = uri.host == 'localhost'
          ? InternetAddress.loopbackIPv4
          : InternetAddress(uri.host);
    }

    _transport = UdpTransport(
      address: InternetAddress.anyIPv4,
      port: 0,
      remoteAddress: serverAddress,
      remotePort: port,
    );

   await _transport.connect();

    _transport.onData.listen((data) {
      _mavParser.parse(data);
      print('Received data: ${data.length} bytes');
    });

    await _transport.send(Uint8List.fromList([0]));
  }

  void dispose() {
    _transport.dispose();
    _ctrl.close();
    _hvBmsCtrl.close();
    _hvPduCtrl.close();
    _lvBatteryCtrl.close();
    _lvPduCtrl.close();
  }
}
