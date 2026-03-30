import 'dart:async';

import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  String _selectedMenu = 'COMPUTE';
  Duration _upTime = Duration.zero;
  Timer? _upTimeTimer;
  double _batteryLevel = 0.85;

  String get selectedMenu => _selectedMenu;
  Duration get upTime => _upTime;
  double get batteryLevel => _batteryLevel;

  void init() {
    _startUpTime();
  }

  void _startUpTime() {
    _upTime = Duration.zero;
    _upTimeTimer?.cancel();
    _upTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _upTime += const Duration(seconds: 1);
      if (_upTime.inSeconds > 0 && _upTime.inSeconds % (4 * 60) == 0) {
        _batteryLevel = (_batteryLevel - 0.02).clamp(0.0, 1.0);
      }
      notifyListeners();
    });
  }

  void selectMenu(String menu) {
    if (_selectedMenu != menu) {
      _selectedMenu = menu;
      notifyListeners();
    }
  }

  void disposeAll() {
    _upTimeTimer?.cancel();
  }
}
