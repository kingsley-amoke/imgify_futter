import 'package:flutter/material.dart';
import 'package:imgify/imgify.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const Imgify(),
    ),
  );
}
