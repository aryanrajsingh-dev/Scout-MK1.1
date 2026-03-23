import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:comm_module/comm_module.dart';
import 'package:mavlink_nrt/mavlink_parser.dart';
import 'package:websocket_app/dialects/telemetry.dart';

class WebSocketService {
  late Transport _transport;
  late final Stream<Map<String, dynamic>> rawStream;
  final StreamController<Map<String, dynamic>> _ctrl = StreamController<Map<String, dynamic>>();
  late final MavlinkParser _mavParser;

  Timer? _keepAliveTimer;
  bool _loggedParserActive = false;

  final StreamController<HvBatteryBms> _hvBmsCtrl = StreamController<HvBatteryBms>.broadcast();
  final StreamController<HvPdu> _hvPduCtrl = StreamController<HvPdu>.broadcast();
  final StreamController<LvBattery> _lvBatteryCtrl = StreamController<LvBattery>.broadcast();
  final StreamController<LvPdu> _lvPduCtrl = StreamController<LvPdu>.broadcast();

  Stream<HvBatteryBms> get hvBmsStream => _hvBmsCtrl.stream;
  Stream<HvPdu> get hvPduStream => _hvPduCtrl.stream;
  Stream<LvBattery> get lvBatteryStream => _lvBatteryCtrl.stream;
  Stream<LvPdu> get lvPduStream => _lvPduCtrl.stream;

  WebSocketService() {
    rawStream = _ctrl.stream.asBroadcastStream();

    final dialect = MavlinkDialectTelemetry();
    _mavParser = MavlinkParser(dialect);

    _mavParser.stream.listen((frame) {
      final msg = frame.message;

      if (!_loggedParserActive) {
        _loggedParserActive = true;
        print('[TELEMETRY] MAVLink parser active (${msg.runtimeType})');
      }

      if (msg is TelemetryStatus) {
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
      } else if (msg is HvBatteryBms) {
        _hvBmsCtrl.add(msg);
      } else if (msg is HvPdu) {
        _hvPduCtrl.add(msg);
      } else if (msg is LvBattery) {
        _lvBatteryCtrl.add(msg);
      } else if (msg is LvPdu) {
        _lvPduCtrl.add(msg);
      }
    });
  }

  Future<void> connect(String wsUrl) async {
    final uri = Uri.parse(wsUrl.replaceFirst('ws://', 'http://'));
    final port = uri.hasPort ? uri.port : 9000;

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
    });

    await _transport.send(Uint8List.fromList([0]));

    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await _transport.send(Uint8List.fromList([0]));
      } catch (e) {
      }
    });
  }

  void dispose() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _transport.dispose();
    _ctrl.close();
    _hvBmsCtrl.close();
    _hvPduCtrl.close();
    _lvBatteryCtrl.close();
    _lvPduCtrl.close();
  }
}
