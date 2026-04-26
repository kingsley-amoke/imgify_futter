import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:imgify/providers/batch_processing_provider.dart';
import 'package:imgify/providers/connectivity_provider.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/providers/pro_status_provider.dart';
import 'package:imgify/providers/usage_provider.dart';
import 'package:imgify/screens/home_screen.dart';
import 'package:imgify/screens/splash_screen.dart';
import 'package:imgify/services/ad_service.dart';
import 'package:imgify/services/usage_limit_service.dart';
import 'package:provider/provider.dart';

class Imgify extends StatelessWidget {
  const Imgify({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        Provider(create: (_) => UsageLimitService()),
        Provider(create: (_) => AdMobService()),

        ChangeNotifierProxyProvider2<UsageLimitService, AdMobService, UsageProvider>(
          create: (_) => UsageProvider(UsageLimitService(), AdMobService()),
          update: (_, usageService, adService, previous) =>
          previous!..init(),
        ),
        ChangeNotifierProxyProvider<UsageProvider, ImageProviderState>(
          create: (_) => ImageProviderState(),
          update: (_, usageProvider, imageProvider) {
            imageProvider ??= ImageProviderState();
            imageProvider.updateUsageProvider(usageProvider);
            return imageProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => BatchProcessingProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),

        ChangeNotifierProxyProvider<ConnectivityProvider, ProStatusProvider>(
          create: (_) => ProStatusProvider(),
          update: (_, connectivity, proStatus) {
            proStatus ??= ProStatusProvider();

            proStatus.updateConnectivity(connectivity);

            return proStatus;
          },
        ),
      ],
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'IMGIFY',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/home': (_) =>const HomeScreen(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
