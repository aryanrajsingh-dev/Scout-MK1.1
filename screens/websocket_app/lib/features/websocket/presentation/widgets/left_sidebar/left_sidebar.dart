import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  final String selectedMenu;
  final ValueChanged<String> onMenuSelected;

  const LeftSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    const labels = <String>['COMPUTE', 'POWER'];

    const textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      fontSize: 13,
    );

    const buttonPadding = EdgeInsets.symmetric(vertical: 6, horizontal: 10);

    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          right: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxButtonWidth =
              (constraints.maxWidth - 12).clamp(0, double.infinity).toDouble();
          final buttonWidth = _buttonWidthForLabels(
            context: context,
            labels: labels,
            style: textStyle,
            padding: buttonPadding,
            maxWidth: maxButtonWidth,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              for (final label in labels) ...[
                _buildButton(
                  context,
                  label,
                  label == selectedMenu,
                  width: buttonWidth,
                  textStyle: textStyle,
                  padding: buttonPadding,
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }

  static double _buttonWidthForLabels({
    required BuildContext context,
    required List<String> labels,
    required TextStyle style,
    required EdgeInsets padding,
    required double maxWidth,
  }) {
    double widest = 0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
    }

    final desired = widest + padding.horizontal + 6;
    if (maxWidth <= 0) return desired;
    return desired.clamp(0, maxWidth);
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    bool isSelected, {
    required double width,
    required TextStyle textStyle,
    required EdgeInsets padding,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        onMenuSelected(label);
      },
      child: SizedBox(
        width: width,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withOpacity(0.4) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.cyan : Colors.cyan.withOpacity(0.4),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
              color: isSelected ? Colors.cyan : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}