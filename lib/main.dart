import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/Service/ConnectingService.dart';
import 'package:ranchat_flutter/View/ChatScreen.dart';
import 'package:ranchat_flutter/View/RoomListScreen.dart';
import 'package:ranchat_flutter/View/SettingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
  late Connectingservice _connectingservice; // API, WebSocket 연결을 위한 객체
  var _isLoading = false; // 매칭 중 로딩을 위한 변수
  var _isAnimationEnd = false; // 애니메이션 종료를 위한 변수
  var _isRoomExist = false; // 방이 존재하는지 확인하는 변수

  late AnimationController _animationController; // 애니메이션 컨트롤러
  late Animation<Offset> _logoAnimation;
  late Animation<double> _buttonAnimation; // 애니메이션

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setAnimation(); // 애니메이션 설정
    _setServer(); // 서버 설정
  }

  // #region first setting
  // 애니메이션 설정
  void _setAnimation() {
    _animationController = AnimationController(
      // 애니메이션 컨트롤러 설정 (2초)
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoAnimation = Tween<Offset>(
      // 애니메이션 설정 (위에서 아래로)
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.addStatusListener((status) {
      // 애니메이션 종료 시
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimationEnd = true; // 애니메이션이 종료되었음을 알림
        });
      }
    });

    _animationController.forward(); // 애니메이션 시작
  }

  void _setServer() async {
    // 서버 설정
    _connectingservice = Connectingservice(
        onMatchingSuccess: _onMatchingSuccess); // API, WebSocket 연결을 위한 객체 생성

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.clear();
    String? userId = prefs.getString('userUUID');
    print('main.dart userId: $userId');
    if (userId == null) {
      var uuid = const Uuid();
      var uuidV7 = uuid.v7();
      userId = uuidV7;
      await prefs.setString('userUUID', uuidV7);
      print('uuidV7: $uuidV7');
      _connectingservice.setUserId(userId);
      _connectingservice.apiService?.createUser(_getRandomNickname());
    }
    _connectingservice.setUserId(userId);
    checkRoomExist();
    _connectingservice.websocketService?.connectToWebSocket(); // WebSocket 연결
  }

  void checkRoomExist() {
    _connectingservice.apiService?.checkRoomExist().then((value) {
      setState(() {
        _isRoomExist = value;
      });
    });
  }

  String _getRandomNickname() {
    final random = Random();
    final List<String> frontNickname = [
      '행복한',
      '빛나는',
      '빠른',
      '작은',
      '푸른',
      '깊은',
      '웃는',
      '고요한',
      '따뜻한',
      '하얀',
      '즐거운',
      '맑은',
      '예쁜',
      '강한',
      '조용한',
      '푸른',
      '따뜻한',
      '밝은',
      '신비한',
      '높은',
    ];
    final List<String> backNickname = [
      '고양이',
      '별',
      '바람',
      '새',
      '하늘',
      '바다',
      '사람',
      '숲',
      '햇살',
      '눈',
      '여행',
      '강',
      '꽃',
      '용',
      '밤',
      '나무',
      '마음',
      '햇빛',
      '섬',
      '산',
    ];

    print(
        '랜덤 닉네임 : ${frontNickname[random.nextInt(frontNickname.length)] + backNickname[random.nextInt(backNickname.length)]}');
    return frontNickname[random.nextInt(frontNickname.length)] +
        backNickname[random.nextInt(backNickname.length)];
  }
  // #endregion

  // #region dialog
  // 매칭 중 로딩 다이얼로그
  void _showLoadingDialog(BuildContext context) {
    _isLoading = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child:
                _isLoading ? const LoadingDialog() : null, // 로딩 중이면 로딩 다이얼로그 출력
          );
        });

    _closeLoadingDialog(); // 8초 뒤에 매칭 실패 시 다이얼로그 종료
  }

  // 8초 뒤에 매칭 실패 시 다이얼로그 종료
  void _closeLoadingDialog() async {
    await Future.delayed(const Duration(seconds: 8));
    if (!_isLoading) {
      return;
    } else {
      _connectingservice.websocketService?.cancelMatching();
      _isLoading = false;

      await _connectingservice.apiService?.createRoom().then((roomId) {
        _connectingservice.websocketService?.setRoomId(roomId.toString());
        _connectingservice.apiService?.setRoomId(roomId.toString());
        _connectingservice.websocketService?.enterRoom();
      });
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(connectingservice: _connectingservice)),
      ).then((_) {
        checkRoomExist();
      });
      // Fluttertoast.showToast(
      //   msg: '매칭에 실패하였습니다.',
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.CENTER,
      //   timeInSecForIosWeb: 2,
      //   backgroundColor: Colors.grey,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('매칭에 실패하였습니다.'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    }
  }
  // #endregion

  // #region callback
  // 매칭 성공 시
  void _onMatchingSuccess(dynamic response) {
    final responseJson = response as Map<String, dynamic>;
    if (responseJson['status'] != 'SUCCESS') {
      // 매칭 실패 시
      // Fluttertoast.showToast(
      //   msg: '매칭에 실패하였습니다.',
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.CENTER,
      //   timeInSecForIosWeb: 2,
      //   backgroundColor: Colors.grey,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('매칭에 실패하였습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else {
      // 매칭 성공 시
      final roomId = responseJson['data']['roomId'];
      print('matching success! roomId : $roomId');
      _connectingservice.websocketService?.setRoomId(roomId.toString());
      _connectingservice.apiService?.setRoomId(roomId.toString());
      _connectingservice.websocketService?.enterRoom();
      Navigator.of(context).pop();
      _isLoading = false;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(connectingservice: _connectingservice)),
      ).then((_) {
        checkRoomExist();
      });
    }
    print('chatScreen onMessageReceived: $response');
  }
  // #endregion

  // #region UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 36.0,
              ),
              highlightColor: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Settingscreen(
                          connectingservice:
                              _connectingservice)), // Replace 'SettingScreen' with an existing class or define the 'SettingScreen' class.
                );
              },
            ),
          )
        ],
        // title: const Text(
        //   'Ranchat',
        //   style: TextStyle(fontSize: 40.0),
        // ),
      ),
      body: SlideTransition(
        // 애니메이션 적용
        position: _logoAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _connectingservice.websocketService?.tempRequestMatching();
                },
                child: const Text(
                  'Ran-Chat',
                  style: TextStyle(fontSize: 80.0, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30.0),
              !_isAnimationEnd
                  ? const SizedBox(
                      // 애니메이션이 종료되지 않았을 때
                      height: 50.0,
                    )
                  : ElevatedButton(
                      // 애니메이션이 종료되었을 때
                      onPressed: () {
                        _connectingservice.websocketService?.requestMatching();
                        _showLoadingDialog(context);

                        // Navigator.push(
                        //   // 채팅 화면으로 이동
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => ChatScreen(
                        //           connectingservice: _connectingservice)),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 5.0)),
                      ),
                      child: const SizedBox(
                          width: 150.0,
                          height: 50.0,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('START!',
                                style: TextStyle(fontSize: 30.0)),
                          ))),
              const SizedBox(height: 10.0),
              !_isAnimationEnd
                  ? const SizedBox(
                      // 애니메이션이 종료되지 않았을 때
                      height: 50.0,
                    )
                  : _isRoomExist
                      ? ElevatedButton(
                          // 애니메이션이 종료되었을 때
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoomListScreen(
                                      connectingservice:
                                          _connectingservice)), // 채팅방 목록 화면으로 이동
                            ).then((_) {
                              checkRoomExist();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white, width: 5.0)),
                          ),
                          child: const SizedBox(
                            width: 150.0,
                            height: 50.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('CONTINUE!',
                                  style: TextStyle(fontSize: 30.0)),
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 50,
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.black,
        child: Center(
          child: Text(
            'Copyright © KJI Corp. 2024 All Rights Reserved.',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
  // #endregion
}

// #region loading dialog
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
