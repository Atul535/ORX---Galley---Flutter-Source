import 'package:flutter/material.dart';

import '../model/bargraph_model.dart';
import '../widgets/bargraph.dart';

int crc16(List<int> data) {
  int crc = 0xFFFF; // Initial CRC value
  int polynomial = 0x1021; // Polynomial for CRC-CCITT

  for (int byte in data) {
    crc ^= (byte << 8); // XOR byte into the high byte of crc

    for (int i = 0; i < 8; i++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ polynomial;
      } else {
        crc <<= 1;
      }
    }
  }

  return crc & 0xFFFF; // Mask to 16-bits
}

Widget buildBargraph({
  required BargraphModel item,
  BargraphTitlePosition titlePosition = BargraphTitlePosition.bottom,
  TextStyle? titleStyle,
  BargraphType type = BargraphType.temperature,
  Color? thumbColorOverride,
  ValueChanged<double>? onValueChangeCallback,
  int titleRotationQuarterTurns = 0,
  String? title,
}) {
  return Bargraph(
    bargraphType: type,
    width: item.width,
    height: item.height,
    id: item.id,
    maxValue: item.maxValue,
    minValue: item.minValue,
    steps: item.steps,
    title: title ?? item.title,
    titlePosition: titlePosition,
    titleStyle: titleStyle,
    titleRotationQuarterTurns: titleRotationQuarterTurns,
    spacing: item.spacing,
    thumbColorOverride: thumbColorOverride,
    onValueChangeCallback: onValueChangeCallback,
  );
}

String makeTextVertical(String text) {
  return text.split('').join('\n'); // ⭐ Každé písmeno na nový řádek
}
