import 'dart:typed_data';
import 'package:mavlink_nrt/mavlink_message.dart';

class HvBmsTelemetry implements MavlinkMessage {
  static const int _mavlinkMessageId = 60001;
  static const int _mavlinkCrcExtra = 50;
  static const int mavlinkEncodedLength = 21;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  final double packVoltage;
  final double packCurrent;
  final double soc;
  final double soh;
  final double capacityRemaining;
  final double maxCellVoltage;
  final double minCellVoltage;
  final double maxTemp;
  final int faultFlags;

  const HvBmsTelemetry({
    required this.packVoltage,
    required this.packCurrent,
    required this.soc,
    required this.soh,
    required this.capacityRemaining,
    required this.maxCellVoltage,
    required this.minCellVoltage,
    required this.maxTemp,
    required this.faultFlags,
  });

  factory HvBmsTelemetry.parse(ByteData data_) {
    if (data_.lengthInBytes < mavlinkEncodedLength) {
      final padding = mavlinkEncodedLength - data_.lengthInBytes;
      final list = data_.buffer.asUint8List().sublist(0, data_.lengthInBytes)
        ..addAll(List<int>.filled(padding, 0));
      data_ = Uint8List.fromList(list).buffer.asByteData();
    }

    int cursor = 0;

    int readU16() {
      final v = data_.getUint16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readI16() {
      final v = data_.getInt16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readU8() {
      final v = data_.getUint8(cursor);
      cursor += 1;
      return v;
    }

    final packVoltage = readU16() / 10.0;
    final packCurrent = readI16() / 10.0;
    final soc = readU8().toDouble();
    final soh = readU8().toDouble();
    final capacityRemaining = readU16() / 10.0;
    final maxCellVoltage = readU16() / 1000.0;
    final minCellVoltage = readU16() / 1000.0;
    final maxTemp = readI16() / 10.0;
    final faults = readU8();

    return HvBmsTelemetry(
      packVoltage: packVoltage,
      packCurrent: packCurrent,
      soc: soc,
      soh: soh,
      capacityRemaining: capacityRemaining,
      maxCellVoltage: maxCellVoltage,
      minCellVoltage: minCellVoltage,
      maxTemp: maxTemp,
      faultFlags: faults,
    );
  }

  @override
  ByteData serialize() {
    final data_ = ByteData(mavlinkEncodedLength);

    int cursor = 0;

    void writeU16(int value) {
      data_.setUint16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeI16(int value) {
      data_.setInt16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeU8(int value) {
      data_.setUint8(cursor, value);
      cursor += 1;
    }

    writeU16((packVoltage * 10).round());
    writeI16((packCurrent * 10).round());
    writeU8(soc.round());
    writeU8(soh.round());
    writeU16((capacityRemaining * 10).round());
    writeU16((maxCellVoltage * 1000).round());
    writeU16((minCellVoltage * 1000).round());
    writeI16((maxTemp * 10).round());
    writeU8(faultFlags);

    return data_;
  }
}

class HvPduStatus implements MavlinkMessage {
  static const int _mavlinkMessageId = 60002;
  static const int _mavlinkCrcExtra = 51;
  static const int mavlinkEncodedLength = 7;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  final bool mainContactor;
  final double motorCurrent;
  final int dcDcPercent;
  final int auxPercent;
  final double dcBusVoltage;

  const HvPduStatus({
    required this.mainContactor,
    required this.motorCurrent,
    required this.dcDcPercent,
    required this.auxPercent,
    required this.dcBusVoltage,
  });

  factory HvPduStatus.parse(ByteData data_) {
    if (data_.lengthInBytes < mavlinkEncodedLength) {
      final padding = mavlinkEncodedLength - data_.lengthInBytes;
      final list = data_.buffer.asUint8List().sublist(0, data_.lengthInBytes)
        ..addAll(List<int>.filled(padding, 0));
      data_ = Uint8List.fromList(list).buffer.asByteData();
    }

    int cursor = 0;

    int readU8() {
      final v = data_.getUint8(cursor);
      cursor += 1;
      return v;
    }

    int readI16() {
      final v = data_.getInt16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readU16() {
      final v = data_.getUint16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    final mainRaw = readU8();
    final motorRaw = readI16();
    final dcDcPercent = readU8();
    final auxPercent = readU8();
    final dcBusRaw = readU16();

    return HvPduStatus(
      mainContactor: mainRaw == 1,
      motorCurrent: motorRaw / 10.0,
      dcDcPercent: dcDcPercent,
      auxPercent: auxPercent,
      dcBusVoltage: dcBusRaw / 10.0,
    );
  }

  @override
  ByteData serialize() {
    final data_ = ByteData(mavlinkEncodedLength);
    int cursor = 0;

    void writeU8(int value) {
      data_.setUint8(cursor, value);
      cursor += 1;
    }

    void writeI16(int value) {
      data_.setInt16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeU16(int value) {
      data_.setUint16(cursor, value, Endian.little);
      cursor += 2;
    }

    writeU8(mainContactor ? 1 : 0);
    writeI16((motorCurrent * 10).round());
    writeU8(dcDcPercent);
    writeU8(auxPercent);
    writeU16((dcBusVoltage * 10).round());

    return data_;
  }
}

class LvBatteryStatus implements MavlinkMessage {
  static const int _mavlinkMessageId = 60003;
  static const int _mavlinkCrcExtra = 52;
  static const int mavlinkEncodedLength = 4;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  final double voltage;
  final double current;

  const LvBatteryStatus({
    required this.voltage,
    required this.current,
  });

  factory LvBatteryStatus.parse(ByteData data_) {
    if (data_.lengthInBytes < mavlinkEncodedLength) {
      final padding = mavlinkEncodedLength - data_.lengthInBytes;
      final list = data_.buffer.asUint8List().sublist(0, data_.lengthInBytes)
        ..addAll(List<int>.filled(padding, 0));
      data_ = Uint8List.fromList(list).buffer.asByteData();
    }

    int cursor = 0;

    int readU16() {
      final v = data_.getUint16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readI16() {
      final v = data_.getInt16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    final voltageRaw = readU16();
    final currentRaw = readI16();

    return LvBatteryStatus(
      voltage: voltageRaw / 10.0,
      current: currentRaw / 10.0,
    );
  }

  @override
  ByteData serialize() {
    final data_ = ByteData(mavlinkEncodedLength);
    int cursor = 0;

    void writeU16(int value) {
      data_.setUint16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeI16(int value) {
      data_.setInt16(cursor, value, Endian.little);
      cursor += 2;
    }

    writeU16((voltage * 10).round());
    writeI16((current * 10).round());

    return data_;
  }
}

class LvPduStatus implements MavlinkMessage {
  static const int _mavlinkMessageId = 60004;
  static const int _mavlinkCrcExtra = 53;
  static const int mavlinkEncodedLength = 27;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  final double inputVoltage;
  final double inputCurrent;
  final double inputPower;
  final double outputCurrent;
  final double loadPower;
  final List<double> channelCurrents;
  final int channelMask;
  final double temperature;
  final bool canStatus;

  const LvPduStatus({
    required this.inputVoltage,
    required this.inputCurrent,
    required this.inputPower,
    required this.outputCurrent,
    required this.loadPower,
    required this.channelCurrents,
    required this.channelMask,
    required this.temperature,
    required this.canStatus,
  });

  bool channelEnabled(int index) {
    if (index < 0 || index > 5) return false;
    return (channelMask & (1 << index)) != 0;
  }

  bool get canOk => canStatus;

  factory LvPduStatus.parse(ByteData data_) {
    if (data_.lengthInBytes < mavlinkEncodedLength) {
      final padding = mavlinkEncodedLength - data_.lengthInBytes;
      final list = data_.buffer.asUint8List().sublist(0, data_.lengthInBytes)
        ..addAll(List<int>.filled(padding, 0));
      data_ = Uint8List.fromList(list).buffer.asByteData();
    }

    int cursor = 0;

    int readU16() {
      final v = data_.getUint16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readI16() {
      final v = data_.getInt16(cursor, Endian.little);
      cursor += 2;
      return v;
    }

    int readU8() {
      final v = data_.getUint8(cursor);
      cursor += 1;
      return v;
    }

    final inputVoltage = readU16() / 10.0;
    final inputCurrent = readI16() / 10.0;
    final inputPower = readU16().toDouble();
    final outputCurrent = readI16() / 10.0;
    final loadPower = readU16().toDouble();

    final channelCurrents = <double>[];
    for (int i = 0; i < 6; i++) {
      channelCurrents.add(readI16() / 10.0);
    }

    final channelMask = readU8();
    final temperature = readI16() / 10.0;
    final canStatusRaw = readU8();

    return LvPduStatus(
      inputVoltage: inputVoltage,
      inputCurrent: inputCurrent,
      inputPower: inputPower,
      outputCurrent: outputCurrent,
      loadPower: loadPower,
      channelCurrents: channelCurrents,
      channelMask: channelMask,
      temperature: temperature,
      canStatus: canStatusRaw == 1,
    );
  }

  @override
  ByteData serialize() {
    final data_ = ByteData(mavlinkEncodedLength);
    int cursor = 0;

    void writeU16(int value) {
      data_.setUint16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeI16(int value) {
      data_.setInt16(cursor, value, Endian.little);
      cursor += 2;
    }

    void writeU8(int value) {
      data_.setUint8(cursor, value);
      cursor += 1;
    }

    writeU16((inputVoltage * 10).round());
    writeI16((inputCurrent * 10).round());
    writeU16(inputPower.round());
    writeI16((outputCurrent * 10).round());
    writeU16(loadPower.round());

    for (final current in channelCurrents.take(6)) {
      writeI16((current * 10).round());
    }

    while (channelCurrents.length < 6) {
      writeI16(0);
    }

    writeU8(channelMask);
    writeI16((temperature * 10).round());
    writeU8(canStatus ? 1 : 0);

    return data_;
  }
}
