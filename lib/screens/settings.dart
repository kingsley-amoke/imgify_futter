import 'package:flutter/material.dart';
import 'package:imgify/widgets/my_appbar.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'Settings', centerTitle: true),
      body: const Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
