import 'dart:typed_data';
import 'package:mavlink_nrt/mavlink_dialect.dart';
import 'package:mavlink_nrt/mavlink_message.dart';

import 'compute_telemetry.dart';
import 'power_telemetry.dart';

export 'compute_telemetry.dart';
export 'power_telemetry.dart';

class MavlinkDialectTelemetry implements MavlinkDialect {
  static const int mavlinkVersion = 2;

  @override
  int get version => mavlinkVersion;

  @override
  MavlinkMessage? parse(int messageID, ByteData data) {
    switch (messageID) {
      case 1:
        return ComputeTelemetry.parse(data);
      case 60001:
        return HvBmsTelemetry.parse(data);
      case 60002:
        return HvPduStatus.parse(data);
      case 60003:
        return LvBatteryStatus.parse(data);
      case 60004:
        return LvPduStatus.parse(data);
      default:
        return null;
    }
  }

  @override
  int crcExtra(int messageID) {
    switch (messageID) {
      case 1:
        return 138;
      case 60001:
        return 50;
      case 60002:
        return 51;
      case 60003:
        return 52;
      case 60004:
        return 53;
      default:
        return -1;
    }
  }
}
