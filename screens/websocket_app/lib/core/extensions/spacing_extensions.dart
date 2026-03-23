import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SpacingExtensions on num {
  SizedBox get hBox => SizedBox(height: toDouble().h);
  SizedBox get wBox => SizedBox(width: toDouble().w);
}
