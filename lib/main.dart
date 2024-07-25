import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/View/RoomListScreen.dart';
import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';
import 'package:ranchat_flutter/View/ChatScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Connectingservice _connectingservice;
  var _isLoading = false;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));
    _animationController.forward();

    _connectingservice =
        Connectingservice(onMatchingSuccess: _onMatchingSuccess);
    _connectingservice.connectToWebSocket();
  }

  void _showLoadingDialog(BuildContext context) {
    _isLoading = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: _isLoading ? const LoadingDialog() : null,
          );
        });

    Future.delayed(const Duration(seconds: 8), () {
      if (!_isLoading) return;
      _connectingservice.cancelMatching();
      Navigator.of(context).pop();
      _isLoading = false;

      Fluttertoast.showToast(
        msg: '매칭에 실패하였습니다.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void _onMatchingSuccess(dynamic response) {
    Navigator.of(context).pop();
    _isLoading = false;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatScreen(connectingservice: _connectingservice)),
    );
    print('chatScreen onMessageReceived: $response');
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
        body: SlideTransition(
          position: _animation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ran-chat',
                  style: TextStyle(fontSize: 80.0),
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    // _connectingservice.requestMatching();
                    // _showLoadingDialog(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              connectingservice: _connectingservice)),
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
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Roomlistscreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 5.0)),
                  ),
                  child:
                      const Text('CONTINUE!', style: TextStyle(fontSize: 30.0)),
                ),
              ],
            ),
          ),
        ));
  }
}

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      print('startTimer');
      setState(() {
        _currentStep = (_currentStep + 1) % 5;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('매칭 중', style: TextStyle(fontSize: 30.0)),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildStep(_currentStep % 5 == 0),
                _buildStep(_currentStep % 5 == 1),
                _buildStep(_currentStep % 5 == 2),
                _buildStep(_currentStep % 5 == 3),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
