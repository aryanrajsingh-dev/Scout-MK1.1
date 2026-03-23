import 'dart:typed_data';
import 'package:mavlink_nrt/mavlink_message.dart';
import 'package:mavlink_nrt/types.dart';

class ComputeTelemetry implements MavlinkMessage {
  static const int _mavlinkMessageId = 1;
  static const int _mavlinkCrcExtra = 138;
  static const int mavlinkEncodedLength = 44;

  @override
  int get mavlinkMessageId => _mavlinkMessageId;

  @override
  int get mavlinkCrcExtra => _mavlinkCrcExtra;

  final uint16_t cpuUsage;
  final uint16_t memoryUsage;
  final List<char> temperature;
  final List<char> softwareVersion;

  ComputeTelemetry({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.temperature,
    required this.softwareVersion,
  });

  ComputeTelemetry copyWith({
    uint16_t? cpuUsage,
    uint16_t? memoryUsage,
    List<char>? temperature,
    List<char>? softwareVersion,
  }) {
    return ComputeTelemetry(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      temperature: temperature ?? this.temperature,
      softwareVersion: softwareVersion ?? this.softwareVersion,
    );
  }

  factory ComputeTelemetry.parse(ByteData data_) {
    if (data_.lengthInBytes < ComputeTelemetry.mavlinkEncodedLength) {
      final len = ComputeTelemetry.mavlinkEncodedLength - data_.lengthInBytes;
      final d = data_.buffer.asUint8List().sublist(0, data_.lengthInBytes)
        ..addAll(List<int>.filled(len, 0));
      data_ = Uint8List.fromList(d).buffer.asByteData();
    }
    final cpuUsage = data_.getUint16(0, Endian.little);
    final memoryUsage = data_.getUint16(2, Endian.little);
    final temperature = MavlinkMessage.asInt8List(data_, 4, 16);
    final softwareVersion = MavlinkMessage.asInt8List(data_, 20, 24);

    return ComputeTelemetry(
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      temperature: temperature,
      softwareVersion: softwareVersion,
    );
  }

  @override
  ByteData serialize() {
    final data_ = ByteData(mavlinkEncodedLength);
    data_.setUint16(0, cpuUsage, Endian.little);
    data_.setUint16(2, memoryUsage, Endian.little);
    MavlinkMessage.setInt8List(data_, 4, temperature);
    MavlinkMessage.setInt8List(data_, 20, softwareVersion);
    return data_;
  }
}
