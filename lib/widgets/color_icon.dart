import 'dart:developer';

import 'package:flutter/material.dart';

/// A function that returns a colored circle icon with a tooltip
Widget colorIcon(Color color, String tooltip, int selectedIntensity,
    int intensity, {required Function() onTap}) {
  return GestureDetector(
    onTap: () {
      log('The color is $color and the intensity is $intensity');
      onTap();
    },
    child: Tooltip(
      message: tooltip,
      child: CircleAvatar(
        backgroundColor: color,
        radius: intensity == selectedIntensity ? 18 : 15,
        child: intensity == selectedIntensity
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    ),
  );
}
