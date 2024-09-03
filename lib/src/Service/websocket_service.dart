import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/DefaultData.dart';
import 'package:ranchat_flutter/src/Model/Message.dart';
import 'package:ranchat_flutter/src/Model/MessageData.dart';
import 'package:ranchat_flutter/src/Service/message_service.dart';
import 'package:ranchat_flutter/src/Service/room_service.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebsocketService with ChangeNotifier {
  StompClient? _stompClient; // WebSocket client

  final UserService userService;
  final RoomService roomService;
  final MessageService messageService;

  var subscriptionToMatchingSuccess;
  var subscriptionToRecieveMessage;

  Function(String)? onMatchingSuccessCallback;
  Function(MessageData)? onReceiveMessageCallback;

  bool isMatched = false;

  final Set<String> subscribedTopics = {};

  WebsocketService({
    required this.userService,
    required this.roomService,
    required this.messageService,
    this.onMatchingSuccessCallback,
  });
  void toggleMatched() {
    isMatched = !isMatched;
    notifyListeners();
  }

  void connectToWebSocket() async {
    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://${Defaultdata.domain}/endpoint',
          stompConnectHeaders: {'userId': userService.userId},
          onConnect: (StompFrame frame) => subscribeToMatchingSuccess(frame),
          onWebSocketError: (dynamic error) => log(error.toString()),
          onWebSocketDone: () => log('WebSocket connect done.'),
          onStompError: (StompFrame frame) => log('Stomp error: ${frame.body}'),
          onDisconnect: (StompFrame frame) =>
              log('Disconnected: ${frame.body}'),
          onDebugMessage: (String message) => log('Debug: $message'),
        ),
      );
      _stompClient?.activate();
    } catch (e) {
      log('error: $e');
    }
  }

  void subscribeToMatchingSuccess(StompFrame frame) async {
    unSubscribeToMatchingSuccess();
    subscriptionToMatchingSuccess = _stompClient?.subscribe(
      destination: '/user/${userService.userId}/queue/v1/matching/success',
      callback: onMatchingSuccess,
      headers: {'matchingSuccess': 'true'},
    );
  }

  void subscribeToRecieveMessage() async {
    unSubscribeToRecieveMessage();

    subscriptionToRecieveMessage = _stompClient?.subscribe(
      destination:
          '/topic/v1/rooms/${roomService.roomDetail.id.toString()}/messages/new',
      callback: onMessageReceived,
      headers: {'recieveMessage': 'true'},
    );
  }

  void unSubscribeToMatchingSuccess() async {
    if (subscriptionToMatchingSuccess != null) {
      subscriptionToMatchingSuccess(
          unsubscribeHeaders: {'matchingSuccess': 'true'});
    }
  }

  void unSubscribeToRecieveMessage() async {
    if (subscriptionToRecieveMessage != null) {
      subscriptionToRecieveMessage(
          unsubscribeHeaders: {'recieveMessage': 'true'});
    }
  }

  // #region recieve
  // 메시지 수신
  void onMessageReceived(StompFrame frame) async {
    final message = Message.fromJson(jsonDecode(frame.body ?? ''));
    print('onMessageReceived: message - $message');

    messageService.addMessage(message.messageData);
    onReceiveMessageCallback!(message.messageData);
  }

  // 매칭 성공
  void onMatchingSuccess(StompFrame frame) async {
    isMatched = true;
    log('Matching Success: ${frame.body} / onMatchingSuccessCallback: $onMatchingSuccessCallback');
    if (frame.body != null && onMatchingSuccessCallback != null) {
      final matchingSuccess = jsonDecode(frame.body ?? '');
      print('matchingSuccess: ${matchingSuccess['data']['roomId']}');
      final roomId = matchingSuccess['data']['roomId'].toString();
      roomService.roomDetail =
          roomService.roomDetail.copyWith(id: int.parse(roomId));
      onMatchingSuccessCallback!(roomId);
    } else {
      print('matchingSuccess is null');
    }
    notifyListeners();
  }

  void setOnMatchingSuccessCallback(void Function(String) callback) {
    onMatchingSuccessCallback = callback;
  }

  void setOnReceiveMessageCallback(void Function(MessageData) callback) {
    onReceiveMessageCallback = callback;
  }
  // #endregion

  // #region send
  // 메시지 전송
  void sendMessage(String content) async {
    print('send message');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination:
              '/v1/rooms/${roomService.roomDetail.id.toString()}/messages/send',
          body: jsonEncode(
            {
              "userId": userService.userId,
              "content": content,
              "contentType": "TEXT",
            },
          ),
        );
      } catch (e) {
        print('send Message error: $e');
      }
    } else {
      print('send message error: not connected');
    }
  }

  // 방 입장
  Future<void> enterRoom() async {
    print(
        'enter room / ${userService.userId} / ${roomService.roomDetail.id.toString()}');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination:
              '/v1/rooms/${roomService.roomDetail.id.toString()}}/enter',
          body: jsonEncode({
            "userId": userService.userId,
          }),
        );
        subscribeToRecieveMessage();
      } catch (e) {
        print('enter room error: $e');
      }
    } else {
      print('enter room error: not connected');
    }
  }

  // 방 퇴장
  void exitRoom() async {
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/rooms/${roomService.roomDetail.id.toString()}/exit',
          body: jsonEncode(
            {
              "userId": userService.userId,
            },
          ),
        );
      } catch (e) {
        log('exit room error: $e');
      }
    }
  }

  // 매칭 요청
  void requestMatching() async {
    print('request matching');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": userService.userId}),
        );
      } catch (e) {
        print('request matching error: $e');
      }
    } else {
      print('request matching error: not connected');
    }
  }

  // 임시로 쓰는 매칭 함수
  void tempRequestMatching() async {
    print('temp request matching');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": '0190964c-ee3a-7e81-a1f8-231b5d97c2a1'}),
        );
      } catch (e) {
        print('request matching error: $e');
      }
    } else {
      print('request matching error: not connected');
    }
  }

  // 매칭 취소
  void cancelMatching() async {
    print('cancel matching');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/cancel',
          body: jsonEncode({"userId": userService.userId}),
        );
      } catch (e) {
        print('cancel matching error: $e');
      }
    } else {
      print('cancel matching error: not connected');
    }
  }
  // #endregion
  // #endregion

  @override
  void dispose() {
    _stompClient?.deactivate();
  }
}
