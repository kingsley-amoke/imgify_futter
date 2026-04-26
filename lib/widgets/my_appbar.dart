import 'package:flutter/material.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:provider/provider.dart';

import 'connectivity_banner.dart';

AppBar myAppbar(
  BuildContext context, {
  required String title,
  bool showBackIcon = true,
  bool centerTitle = false,
  List<Widget>? actions = const [ ConnectivityBanner(),],
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    centerTitle: centerTitle,
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        fontSize: 20,
      ),
    ),
    leading: showBackIcon
        ? IconButton(
            onPressed: () {
              context.read<ImageProviderState>().deleteProcessed();
              context.read<ImageProviderState>().clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left),
          )
        : null,
    actions: actions ,
  );
}
