import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int _currentStep = 0; // 로딩 다이얼로그의 현재 단계
  Timer? _timer; // 타이머

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer(); // 타이머 시작
  }

  // 타이머 시작
  void _startTimer() {
    try {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        // 0.5초마다
        print('startTimer');
        setState(() {
          _currentStep = (_currentStep + 1) % 5; // 다음 단계로 이동
          print('_currentStep: $_currentStep');
        });
      });
    } catch (e) {
      print('startTimer error: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebsocketService>(
        builder: (context, websocketService, child) {
      if (websocketService.isMatched) {
        return const SizedBox.shrink();
      }
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
                  // 로딩 단계 표시
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
    });
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
