import 'package:flutter/material.dart';
import 'package:ranchat_flutter/chatScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranchat',
      theme: ThemeData(
        fontFamily: 'DungGeunMo',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          // title: const Text(
          //   'Ranchat',
          //   style: TextStyle(fontSize: 40.0),
          // ),
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPress: () {
                _showLoadingDialog(context);
              },
              child: const Text(
                'Ran-chat',
                style: TextStyle(fontSize: 80.0),
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 5.0)),
              ),
              child: const Text('START!', style: TextStyle(fontSize: 30.0)),
            ),
          ],
        ),
      ),
    );
  }
}
