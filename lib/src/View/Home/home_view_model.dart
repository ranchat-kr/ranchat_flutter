import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Service/room_service.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({
    required this.userService,
    required this.roomService,
    required this.websocketService,
  }) {
    setInit();
  }

  final UserService userService;
  final RoomService roomService;
  final WebsocketService websocketService;

  bool isMatched = false;

  void setInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.clear(); // 임시로 사용
    String? userId = prefs.getString('userUUID');
    print('main.dart userId: $userId');
    if (userId == null) {
      var uuid = const Uuid();
      var uuidV7 = uuid.v7();
      userId = uuidV7;
      await prefs.setString('userUUID', uuidV7);

      userService.userId = userId;
      userService.createUser(_getRandomNickname());
    }
    checkRoomExist(userId);

    websocketService.onMatchingSuccessCallback = onMatchingSuccess;
    websocketService.connectToWebSocket();
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

    return frontNickname[random.nextInt(frontNickname.length)] +
        backNickname[random.nextInt(backNickname.length)];
  }

  bool checkRoomExist(String userId) {
    //isLoading = true;

    roomService.checkRoomExist(userId).then((result) {
      return result;
    });
    // isLoading = false;
    return false;
  }

  void requestMatching() {
    websocketService.requestMatching();
  }

  void cancelMatching() {
    websocketService.cancelMatching();
  }

  void tempRequestMatching() {
    websocketService.tempRequestMatching();
  }

  void onMatchingSuccess(dynamic response) async {
    isMatched = true;
    print('homeviewmodel Matching Success: $response');
    notifyListeners();
  }
}
