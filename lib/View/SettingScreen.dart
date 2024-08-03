import 'package:flutter/material.dart';
import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';

class Settingscreen extends StatefulWidget {
  final Connectingservice connectingservice;
  const Settingscreen({super.key, required this.connectingservice});

  @override
  _SettingscreenState createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Settings',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
