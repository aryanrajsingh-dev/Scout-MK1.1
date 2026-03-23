import 'dart:typed_data';
import 'package:mavlink_nrt/mavlink_dialect.dart';
import 'package:mavlink_nrt/mavlink_message.dart';
import 'package:mavlink_nrt/types.dart';

/// CPU and memory usage plus temperature and software version for SCOUT dashboard.
/// TELEMETRY_STATUS
class TelemetryStatus implements MavlinkMessage {
  static const int _mavlinkMessageId = 1;

  static const int _mavlinkCrcExtra = 138;

  static const int mavlinkEncodedLength = 44;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  /// CPU usage percentage (0-100)
  /// MAVLink type: uint16_t
  /// cpu_usage
  final uint16_t cpuUsage;

  /// Memory usage percentage (0-100)
  /// MAVLink type: uint16_t
  /// memory_usage
  final uint16_t memoryUsage;

  /// Temperature string, e.g. 42C
  /// MAVLink type: char[16]
  /// temperature
  final List<char> temperature;

  /// Software version string
  /// MAVLink type: char[24]
  /// software_version
  final List<char> softwareVersion;

  TelemetryStatus({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.temperature,
    required this.softwareVersion,
  });

  TelemetryStatus copyWith({
    uint16_t? cpuUsage,
    uint16_t? memoryUsage,
    List<char>? temperature,
    List<char>? softwareVersion,
  }) {
    return TelemetryStatus(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      temperature: temperature ?? this.temperature,
      softwareVersion: softwareVersion ?? this.softwareVersion,
    );
  }

  factory TelemetryStatus.parse(ByteData data_) {
    if (data_.lengthInBytes < TelemetryStatus.mavlinkEncodedLength) {
      var len = TelemetryStatus.mavlinkEncodedLength - data_.lengthInBytes;
      var d =
          data_.buffer.asUint8List().sublist(0, data_.lengthInBytes) +
          List<int>.filled(len, 0);
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    var cpuUsage = data_.getUint16(0, Endian.little);
    var memoryUsage = data_.getUint16(2, Endian.little);
    var temperature = MavlinkMessage.asInt8List(data_, 4, 16);
    var softwareVersion = MavlinkMessage.asInt8List(data_, 20, 24);

    return TelemetryStatus(
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      temperature: temperature,
      softwareVersion: softwareVersion,
    );
  }

  @override
  ByteData serialize() {
    var data_ = ByteData(mavlinkEncodedLength);
    data_.setUint16(0, cpuUsage, Endian.little);
    data_.setUint16(2, memoryUsage, Endian.little);
    MavlinkMessage.setInt8List(data_, 4, temperature);
    MavlinkMessage.setInt8List(data_, 20, softwareVersion);
    return data_;
  }
}

/// High Voltage Battery Management System values
/// HV_BATTERY_BMS
class HvBatteryBms implements MavlinkMessage {
  static const int _mavlinkMessageId = 2;

  static const int _mavlinkCrcExtra = 187;

  static const int mavlinkEncodedLength = 29;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  /// Capacity Remaining (Ah)
  /// MAVLink type: float
  /// capacity_remaining
  final float capacityRemaining;

  /// Pack Voltage (V)
  /// MAVLink type: float
  /// pack_voltage
  final float packVoltage;

  /// Pack Current (A)
  /// MAVLink type: float
  /// pack_current
  final float packCurrent;

  /// Max Cell Voltage (V)
  /// MAVLink type: float
  /// max_cell_voltage
  final float maxCellVoltage;

  /// Min Cell Voltage (V)
  /// MAVLink type: float
  /// min_cell_voltage
  final float minCellVoltage;

  /// Max Cell Temperature (C)
  /// MAVLink type: float
  /// max_cell_temperature
  final float maxCellTemperature;

  /// State of Health (%)
  /// MAVLink type: uint8_t
  /// soh
  final uint8_t soh;

  /// Fault: Over Voltage (1=Yes, 0=No)
  /// MAVLink type: uint8_t
  /// fault_over_voltage
  final uint8_t faultOverVoltage;

  /// Fault: Under Voltage (1=Yes, 0=No)
  /// MAVLink type: uint8_t
  /// fault_under_voltage
  final uint8_t faultUnderVoltage;

  /// Fault: Over Temperature (1=Yes, 0=No)
  /// MAVLink type: uint8_t
  /// fault_over_temperature
  final uint8_t faultOverTemperature;

  /// Fault: Cell Imbalance (1=Yes, 0=No)
  /// MAVLink type: uint8_t
  /// fault_cell_imbalance
  final uint8_t faultCellImbalance;

  HvBatteryBms({
    required this.capacityRemaining,
    required this.packVoltage,
    required this.packCurrent,
    required this.maxCellVoltage,
    required this.minCellVoltage,
    required this.maxCellTemperature,
    required this.soh,
    required this.faultOverVoltage,
    required this.faultUnderVoltage,
    required this.faultOverTemperature,
    required this.faultCellImbalance,
  });

  HvBatteryBms copyWith({
    float? capacityRemaining,
    float? packVoltage,
    float? packCurrent,
    float? maxCellVoltage,
    float? minCellVoltage,
    float? maxCellTemperature,
    uint8_t? soh,
    uint8_t? faultOverVoltage,
    uint8_t? faultUnderVoltage,
    uint8_t? faultOverTemperature,
    uint8_t? faultCellImbalance,
  }) {
    return HvBatteryBms(
      capacityRemaining: capacityRemaining ?? this.capacityRemaining,
      packVoltage: packVoltage ?? this.packVoltage,
      packCurrent: packCurrent ?? this.packCurrent,
      maxCellVoltage: maxCellVoltage ?? this.maxCellVoltage,
      minCellVoltage: minCellVoltage ?? this.minCellVoltage,
      maxCellTemperature: maxCellTemperature ?? this.maxCellTemperature,
      soh: soh ?? this.soh,
      faultOverVoltage: faultOverVoltage ?? this.faultOverVoltage,
      faultUnderVoltage: faultUnderVoltage ?? this.faultUnderVoltage,
      faultOverTemperature: faultOverTemperature ?? this.faultOverTemperature,
      faultCellImbalance: faultCellImbalance ?? this.faultCellImbalance,
    );
  }

  factory HvBatteryBms.parse(ByteData data_) {
    if (data_.lengthInBytes < HvBatteryBms.mavlinkEncodedLength) {
      var len = HvBatteryBms.mavlinkEncodedLength - data_.lengthInBytes;
      var d =
          data_.buffer.asUint8List().sublist(0, data_.lengthInBytes) +
          List<int>.filled(len, 0);
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    var capacityRemaining = data_.getFloat32(0, Endian.little);
    var packVoltage = data_.getFloat32(4, Endian.little);
    var packCurrent = data_.getFloat32(8, Endian.little);
    var maxCellVoltage = data_.getFloat32(12, Endian.little);
    var minCellVoltage = data_.getFloat32(16, Endian.little);
    var maxCellTemperature = data_.getFloat32(20, Endian.little);
    var soh = data_.getUint8(24);
    var faultOverVoltage = data_.getUint8(25);
    var faultUnderVoltage = data_.getUint8(26);
    var faultOverTemperature = data_.getUint8(27);
    var faultCellImbalance = data_.getUint8(28);

    return HvBatteryBms(
      capacityRemaining: capacityRemaining,
      packVoltage: packVoltage,
      packCurrent: packCurrent,
      maxCellVoltage: maxCellVoltage,
      minCellVoltage: minCellVoltage,
      maxCellTemperature: maxCellTemperature,
      soh: soh,
      faultOverVoltage: faultOverVoltage,
      faultUnderVoltage: faultUnderVoltage,
      faultOverTemperature: faultOverTemperature,
      faultCellImbalance: faultCellImbalance,
    );
  }

  @override
  ByteData serialize() {
    var data_ = ByteData(mavlinkEncodedLength);
    data_.setFloat32(0, capacityRemaining, Endian.little);
    data_.setFloat32(4, packVoltage, Endian.little);
    data_.setFloat32(8, packCurrent, Endian.little);
    data_.setFloat32(12, maxCellVoltage, Endian.little);
    data_.setFloat32(16, minCellVoltage, Endian.little);
    data_.setFloat32(20, maxCellTemperature, Endian.little);
    data_.setUint8(24, soh);
    data_.setUint8(25, faultOverVoltage);
    data_.setUint8(26, faultUnderVoltage);
    data_.setUint8(27, faultOverTemperature);
    data_.setUint8(28, faultCellImbalance);
    return data_;
  }
}

/// High Voltage Power Distribution Unit values
/// HV_PDU
class HvPdu implements MavlinkMessage {
  static const int _mavlinkMessageId = 3;

  static const int _mavlinkCrcExtra = 19;

  static const int mavlinkEncodedLength = 11;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  /// Motor Current (A)
  /// MAVLink type: float
  /// motor_current
  final float motorCurrent;

  /// DC Bus Voltage (V)
  /// MAVLink type: float
  /// dc_bus_voltage
  final float dcBusVoltage;

  /// Main Contactor (1=ON, 0=OFF)
  /// MAVLink type: uint8_t
  /// main_contactor
  final uint8_t mainContactor;

  /// DC-DC Contactor (%)
  /// MAVLink type: uint8_t
  /// dc_dc_contactor
  final uint8_t dcDcContactor;

  /// Aux Contactor (%)
  /// MAVLink type: uint8_t
  /// aux_contactor
  final uint8_t auxContactor;

  HvPdu({
    required this.motorCurrent,
    required this.dcBusVoltage,
    required this.mainContactor,
    required this.dcDcContactor,
    required this.auxContactor,
  });

  HvPdu copyWith({
    float? motorCurrent,
    float? dcBusVoltage,
    uint8_t? mainContactor,
    uint8_t? dcDcContactor,
    uint8_t? auxContactor,
  }) {
    return HvPdu(
      motorCurrent: motorCurrent ?? this.motorCurrent,
      dcBusVoltage: dcBusVoltage ?? this.dcBusVoltage,
      mainContactor: mainContactor ?? this.mainContactor,
      dcDcContactor: dcDcContactor ?? this.dcDcContactor,
      auxContactor: auxContactor ?? this.auxContactor,
    );
  }

  factory HvPdu.parse(ByteData data_) {
    if (data_.lengthInBytes < HvPdu.mavlinkEncodedLength) {
      var len = HvPdu.mavlinkEncodedLength - data_.lengthInBytes;
      var d =
          data_.buffer.asUint8List().sublist(0, data_.lengthInBytes) +
          List<int>.filled(len, 0);
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    var motorCurrent = data_.getFloat32(0, Endian.little);
    var dcBusVoltage = data_.getFloat32(4, Endian.little);
    var mainContactor = data_.getUint8(8);
    var dcDcContactor = data_.getUint8(9);
    var auxContactor = data_.getUint8(10);

    return HvPdu(
      motorCurrent: motorCurrent,
      dcBusVoltage: dcBusVoltage,
      mainContactor: mainContactor,
      dcDcContactor: dcDcContactor,
      auxContactor: auxContactor,
    );
  }

  @override
  ByteData serialize() {
    var data_ = ByteData(mavlinkEncodedLength);
    data_.setFloat32(0, motorCurrent, Endian.little);
    data_.setFloat32(4, dcBusVoltage, Endian.little);
    data_.setUint8(8, mainContactor);
    data_.setUint8(9, dcDcContactor);
    data_.setUint8(10, auxContactor);
    return data_;
  }
}

/// Low Voltage Battery values
/// LV_BATTERY
class LvBattery implements MavlinkMessage {
  static const int _mavlinkMessageId = 4;

  static const int _mavlinkCrcExtra = 121;

  static const int mavlinkEncodedLength = 8;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  /// Voltage (V)
  /// MAVLink type: float
  /// voltage
  final float voltage;

  /// Current (A)
  /// MAVLink type: float
  /// current
  final float current;

  LvBattery({required this.voltage, required this.current});

  LvBattery copyWith({float? voltage, float? current}) {
    return LvBattery(
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
    );
  }

  factory LvBattery.parse(ByteData data_) {
    if (data_.lengthInBytes < LvBattery.mavlinkEncodedLength) {
      var len = LvBattery.mavlinkEncodedLength - data_.lengthInBytes;
      var d =
          data_.buffer.asUint8List().sublist(0, data_.lengthInBytes) +
          List<int>.filled(len, 0);
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    var voltage = data_.getFloat32(0, Endian.little);
    var current = data_.getFloat32(4, Endian.little);

    return LvBattery(voltage: voltage, current: current);
  }

  @override
  ByteData serialize() {
    var data_ = ByteData(mavlinkEncodedLength);
    data_.setFloat32(0, voltage, Endian.little);
    data_.setFloat32(4, current, Endian.little);
    return data_;
  }
}

/// Low Voltage Power Distribution Unit values
/// LV_PDU
class LvPdu implements MavlinkMessage {
  static const int _mavlinkMessageId = 5;

  static const int _mavlinkCrcExtra = 218;

  static const int mavlinkEncodedLength = 49;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  /// Input Voltage (V)
  /// MAVLink type: float
  /// input_voltage
  final float inputVoltage;

  /// Input Current (A)
  /// MAVLink type: float
  /// input_current
  final float inputCurrent;

  /// Input Power (W)
  /// MAVLink type: float
  /// input_power
  final float inputPower;

  /// Output Current (A)
  /// MAVLink type: float
  /// output_current
  final float outputCurrent;

  /// Load Power (W)
  /// MAVLink type: float
  /// load_power
  final float loadPower;

  /// Temperature (C)
  /// MAVLink type: float
  /// temperature
  final float temperature;

  /// Output Channel 1 Current (A)
  /// MAVLink type: float
  /// output_channel_1
  final float outputChannel1;

  /// Output Channel 2 Current (A)
  /// MAVLink type: float
  /// output_channel_2
  final float outputChannel2;

  /// Output Channel 3 Current (A)
  /// MAVLink type: float
  /// output_channel_3
  final float outputChannel3;

  /// Output Channel 4 Current (A)
  /// MAVLink type: float
  /// output_channel_4
  final float outputChannel4;

  /// Output Channel 5 Current (A)
  /// MAVLink type: float
  /// output_channel_5
  final float outputChannel5;

  /// Output Channel 6 Current (A)
  /// MAVLink type: float
  /// output_channel_6
  final float outputChannel6;

  /// CAN Status (1=ON, 0=OFF)
  /// MAVLink type: uint8_t
  /// can_status
  final uint8_t canStatus;

  LvPdu({
    required this.inputVoltage,
    required this.inputCurrent,
    required this.inputPower,
    required this.outputCurrent,
    required this.loadPower,
    required this.temperature,
    required this.outputChannel1,
    required this.outputChannel2,
    required this.outputChannel3,
    required this.outputChannel4,
    required this.outputChannel5,
    required this.outputChannel6,
    required this.canStatus,
  });

  LvPdu copyWith({
    float? inputVoltage,
    float? inputCurrent,
    float? inputPower,
    float? outputCurrent,
    float? loadPower,
    float? temperature,
    float? outputChannel1,
    float? outputChannel2,
    float? outputChannel3,
    float? outputChannel4,
    float? outputChannel5,
    float? outputChannel6,
    uint8_t? canStatus,
  }) {
    return LvPdu(
      inputVoltage: inputVoltage ?? this.inputVoltage,
      inputCurrent: inputCurrent ?? this.inputCurrent,
      inputPower: inputPower ?? this.inputPower,
      outputCurrent: outputCurrent ?? this.outputCurrent,
      loadPower: loadPower ?? this.loadPower,
      temperature: temperature ?? this.temperature,
      outputChannel1: outputChannel1 ?? this.outputChannel1,
      outputChannel2: outputChannel2 ?? this.outputChannel2,
      outputChannel3: outputChannel3 ?? this.outputChannel3,
      outputChannel4: outputChannel4 ?? this.outputChannel4,
      outputChannel5: outputChannel5 ?? this.outputChannel5,
      outputChannel6: outputChannel6 ?? this.outputChannel6,
      canStatus: canStatus ?? this.canStatus,
    );
  }

  factory LvPdu.parse(ByteData data_) {
    if (data_.lengthInBytes < LvPdu.mavlinkEncodedLength) {
      var len = LvPdu.mavlinkEncodedLength - data_.lengthInBytes;
      var d =
          data_.buffer.asUint8List().sublist(0, data_.lengthInBytes) +
          List<int>.filled(len, 0);
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    var inputVoltage = data_.getFloat32(0, Endian.little);
    var inputCurrent = data_.getFloat32(4, Endian.little);
    var inputPower = data_.getFloat32(8, Endian.little);
    var outputCurrent = data_.getFloat32(12, Endian.little);
    var loadPower = data_.getFloat32(16, Endian.little);
    var temperature = data_.getFloat32(20, Endian.little);
    var outputChannel1 = data_.getFloat32(24, Endian.little);
    var outputChannel2 = data_.getFloat32(28, Endian.little);
    var outputChannel3 = data_.getFloat32(32, Endian.little);
    var outputChannel4 = data_.getFloat32(36, Endian.little);
    var outputChannel5 = data_.getFloat32(40, Endian.little);
    var outputChannel6 = data_.getFloat32(44, Endian.little);
    var canStatus = data_.getUint8(48);

    return LvPdu(
      inputVoltage: inputVoltage,
      inputCurrent: inputCurrent,
      inputPower: inputPower,
      outputCurrent: outputCurrent,
      loadPower: loadPower,
      temperature: temperature,
      outputChannel1: outputChannel1,
      outputChannel2: outputChannel2,
      outputChannel3: outputChannel3,
      outputChannel4: outputChannel4,
      outputChannel5: outputChannel5,
      outputChannel6: outputChannel6,
      canStatus: canStatus,
    );
  }

  @override
  ByteData serialize() {
    var data_ = ByteData(mavlinkEncodedLength);
    data_.setFloat32(0, inputVoltage, Endian.little);
    data_.setFloat32(4, inputCurrent, Endian.little);
    data_.setFloat32(8, inputPower, Endian.little);
    data_.setFloat32(12, outputCurrent, Endian.little);
    data_.setFloat32(16, loadPower, Endian.little);
    data_.setFloat32(20, temperature, Endian.little);
    data_.setFloat32(24, outputChannel1, Endian.little);
    data_.setFloat32(28, outputChannel2, Endian.little);
    data_.setFloat32(32, outputChannel3, Endian.little);
    data_.setFloat32(36, outputChannel4, Endian.little);
    data_.setFloat32(40, outputChannel5, Endian.little);
    data_.setFloat32(44, outputChannel6, Endian.little);
    data_.setUint8(48, canStatus);
    return data_;
  }
}

class MavlinkDialectTelemetry implements MavlinkDialect {
  static const int mavlinkVersion = 2;

  @override
  int get version => mavlinkVersion;

  @override
  MavlinkMessage? parse(int messageID, ByteData data) {
    switch (messageID) {
      case 1:
        return TelemetryStatus.parse(data);
      case 2:
        return HvBatteryBms.parse(data);
      case 3:
        return HvPdu.parse(data);
      case 4:
        return LvBattery.parse(data);
      case 5:
        return LvPdu.parse(data);
      default:
        return null;
    }
  }

  @override
  int crcExtra(int messageID) {
    switch (messageID) {
      case 1:
        return TelemetryStatus._mavlinkCrcExtra;
      case 2:
        return HvBatteryBms._mavlinkCrcExtra;
      case 3:
        return HvPdu._mavlinkCrcExtra;
      case 4:
        return LvBattery._mavlinkCrcExtra;
      case 5:
        return LvPdu._mavlinkCrcExtra;
      default:
        return -1;
    }
  }
}
