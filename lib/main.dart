import 'package:flutter/material.dart';
import 'package:imgify/imgify.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imgify/services/ad_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AdMobService().initialize();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const Imgify(),
    ),
  );
}
