// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';
import 'package:ranchat_flutter/src/View/Home/home_view_model.dart';
import 'package:ranchat_flutter/src/View/Home/widget/loading_dialog.dart';
import 'package:ranchat_flutter/src/View/RoomList/room_list_view.dart';
import 'package:ranchat_flutter/src/View/base_view.dart';
import 'package:ranchat_flutter/util/route_path.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  // late Connectingservice _connectingservice; // API, WebSocket 연결을 위한 객체
  // var _isLoading = false; // 매칭 중 로딩을 위한 변수
  var _isAnimationEnd = false; // 애니메이션 종료를 위한 변수

  late AnimationController _animationController; // 애니메이션 컨트롤러
  late Animation<Offset> _logoAnimation;
  late Animation<double> _buttonAnimation;
  bool _isLoading = false; // 로딩 중인지 확인하는 변수

  late HomeViewModel homeViewModel;

  @override
  void initState() {
    super.initState();
    homeViewModel = HomeViewModel(
      roomService: context.read(),
      userService: context.read(),
      websocketService: context.read(),
    );
    homeViewModel.setInit();
    _setAnimation();
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

    _animationController.addStatusListener((status) {
      // 애니메이션 종료 시
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimationEnd = true;
          // _isLoading = context.watch<WebsocketService>().isMatched;
        });
      }
    });

    _animationController.forward(); // 애니메이션 시작
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
    _isLoading = false;
    bool isMatched = context.read<WebsocketService>().isMatched;
    if (isMatched) {
      context.read<WebsocketService>().toggleMatched();
      return;
    } else {
      context.read<WebsocketService>().cancelMatching();
      await homeViewModel.createRoom();
      await homeViewModel.enterRoom();
      Navigator.pop(context);
      homeViewModel.goToChatRoom(context);
    }
  }
  // #endregion

  // #region callback
  // 매칭 성공 시
  // void _onMatchingSuccess(dynamic response) {
  //   final responseJson = response as Map<String, dynamic>;
  //   if (responseJson['status'] != 'SUCCESS') {
  //     // 매칭 실패 시
  //     // Fluttertoast.showToast(
  //     //   msg: '매칭에 실패하였습니다.',
  //     //   toastLength: Toast.LENGTH_LONG,
  //     //   gravity: ToastGravity.CENTER,
  //     //   timeInSecForIosWeb: 2,
  //     //   backgroundColor: Colors.grey,
  //     //   textColor: Colors.white,
  //     //   fontSize: 16.0,
  //     // );
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('매칭에 실패하였습니다.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   } else {
  //     // 매칭 성공 시
  //     final roomId = responseJson['data']['roomId'];
  //     print('matching success! roomId : $roomId');
  //     _connectingservice.websocketService?.setRoomId(roomId.toString());
  //     _connectingservice.apiService?.setRoomId(roomId.toString());
  //     _connectingservice.websocketService?.enterRoom();
  //     Navigator.of(context).pop();
  //     _isLoading = false;
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               ChatScreen(connectingservice: _connectingservice)),
  //     ).then((_) {
  //       checkRoomExist();
  //     });
  //   }
  //   print('chatScreen onMessageReceived: $response');
  // }
  // #endregion

  // #region UI
  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: HomeViewModel(
        roomService: context.read(),
        userService: context.read(),
        websocketService: context.read(),
      ),
      builder: (context, viewModel) {
        if (viewModel.shouldPop) {
          Navigator.pop(context);
          viewModel.resetPopState();
          viewModel.goToChatRoom(context);
        }
        return Consumer<WebsocketService>(
            builder: (context, websocketService, child) {
          websocketService.onMatchingSuccessCallback =
              viewModel.onMatchingSuccess;
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
                        RoutePath.onGenerateRoute(const RouteSettings(
                          name: RoutePath.setting,
                        )),
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
                        viewModel.tempRequestMatching();
                      },
                      child: const Text(
                        'Ran-Talk',
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
                              viewModel.requestMatching();
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
                              foregroundColor: Colors.black,
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.black, width: 5.0)),
                            ),
                            child: const SizedBox(
                              width: 150.0,
                              height: 50.0,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'START!',
                                  style: TextStyle(fontSize: 30.0),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 10.0),
                    !_isAnimationEnd
                        ? const SizedBox(
                            // 애니메이션이 종료되지 않았을 때
                            height: 50.0,
                          )
                        : Consumer<UserService>(
                            builder: (context, userService, child) {
                            return viewModel.isRoomExist
                                ? ElevatedButton(
                                    // 애니메이션이 종료되었을 때
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RoomListView()), // 채팅방 목록 화면으로 이동
                                      ).then((_) {
                                        //checkRoomExist();
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
                                  );
                          }),
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
        });
      },
    );
  }
  // #endregion
}

// #region loading dialog
