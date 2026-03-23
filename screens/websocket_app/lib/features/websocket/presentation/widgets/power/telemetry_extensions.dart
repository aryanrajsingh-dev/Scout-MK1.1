import 'package:websocket_app/dialects/telemetry.dart';

extension HvBatteryBmsUI on HvBatteryBms {
  double get maxTemp => maxCellTemperature;
  int get faultFlags =>
      ((faultOverVoltage == 1 ? 1 : 0) << 0) |
      ((faultUnderVoltage == 1 ? 1 : 0) << 1) |
      ((faultOverTemperature == 1 ? 1 : 0) << 2) |
      ((faultCellImbalance == 1 ? 1 : 0) << 3);
}

extension HvPduUI on HvPdu {
  int get dcDcPercent => dcDcContactor;
  int get auxPercent => auxContactor;
  bool get mainContactorBool => mainContactor == 1;
}

extension LvPduUI on LvPdu {
  bool get canOk => canStatus == 1;
  List<double> get channelCurrents => [
    outputChannel1,
    outputChannel2,
    outputChannel3,
    outputChannel4,
    outputChannel5,
    outputChannel6,
  ];
  bool channelEnabled(int index) => channelCurrents[index] > 0.01;
}
