import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ranchat_flutter/Model/DefaultData.dart';
import 'package:ranchat_flutter/Model/Message.dart';
import 'package:ranchat_flutter/Model/MessageData.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebsocketService {
  StompClient? _stompClient; // WebSocket client
  late String _userId;
  String userId2 = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1";
  late String _roomId;

  var subscriptionToMatchingSuccess;
  var subscriptionToRecieveMessage;
  Function(MessageData)? _onMessageReceivedCallback;
  Function(Map<String, dynamic>)? _onMatchingSuccessCallback;

  WebsocketService(
      {required String userId,
      required String roomId,
      Function(MessageData)? onMessageReceivedCallback,
      Function(Map<String, dynamic>)? onMatchingSuccess}) {
    _userId = userId;
    _roomId = roomId;
    _onMessageReceivedCallback = onMessageReceivedCallback;
    _onMatchingSuccessCallback = onMatchingSuccess;
  }

  void setOnMessageReceivedCallback(Function(MessageData) callback) {
    _onMessageReceivedCallback = callback;
  }

  void setRoomId(String roomId) async {
    print('set room id: $roomId');
    _roomId = roomId;
    print('set room id: $_roomId');
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> connectToWebSocket() async {
    try {
      bool isInternetConnection = await checkInternetConnection();
      print('isInternetConnection: $isInternetConnection');
      if (isInternetConnection) {
        _stompClient = StompClient(
          config: StompConfig(
            url: 'ws://${Defaultdata.domain}/endpoint',
            connectionTimeout: const Duration(seconds: 10),
            stompConnectHeaders: {'userId': _userId},
            heartbeatIncoming: const Duration(seconds: 10),
            heartbeatOutgoing: const Duration(seconds: 10),
            onConnect: (StompFrame frame) => subscribe(frame),
            onWebSocketError: (dynamic error) => print(error.toString()),
            onWebSocketDone: () => onWebSocketDone,
            onStompError: (StompFrame frame) =>
                print('Stomp error: ${frame.body}'),
            onDisconnect: (StompFrame frame) =>
                print('Disconnected: ${frame.body}'),
            onDebugMessage: (String message) => print('Debug: $message'),
          ),
        );
        _stompClient?.activate();
      } else {
        throw Exception('No Internet Connection');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  void onWebSocketDone() {
    print('WebSocket connection lost. Trying to reconnect....');
    reconnectToWebSocket();
  }

  Future<void> reconnectToWebSocket() async {
    const int reconnectDelay = 5000;
    await Future.delayed(const Duration(milliseconds: reconnectDelay));
    await connectToWebSocket();
    await subscribeToRecieveMessage();
  }

  void subscribe(StompFrame frame) async {
    await subscribeToMatchingSuccess(frame);
    await subscribeToRecieveMessage();
  }

  Future<void> subscribeToMatchingSuccess(StompFrame frame) async {
    print('subscribe to matching success');
    try {
      subscriptionToMatchingSuccess = _stompClient?.subscribe(
        destination: '/user/$_userId/queue/v1/matching/success',
        callback: onMatchingSuccess,
        headers: {'matchingSuccess': 'true'},
      );
    } catch (e) {
      throw Exception('<subscribeToMatchingSuccess> Fail');
    }
  }

  Future<void> subscribeToRecieveMessage() async {
    print('subscribe to recieve message');
    try {
      subscriptionToRecieveMessage = _stompClient?.subscribe(
        destination: '/topic/v1/rooms/$_roomId/messages/new',
        callback: onMessageReceived,
        headers: {'recieveMessage': 'true'},
      );
    } catch (e) {
      throw Exception('<subscribeToRecieveMessage> Fail');
    }
  }

  Future<void> unSubscribeToMatchingSuccess() async {
    try {
      await subscriptionToMatchingSuccess(
          unsubscribeHeaders: {'matchingSuccess': 'true'});
    } catch (e) {
      throw Exception('<unSubscribeToMatchingSuccess> Fail');
    }
  }

  Future<void> unSubscribeToRecieveMessage() async {
    try {
      await subscriptionToRecieveMessage(
          unsubscribeHeaders: {'recieveMessage': 'true'});
    } catch (e) {
      throw Exception('<unSubscribeToRecieveMessage> Fail');
    }
  }

  // #region recieve
  // 메시지 수신
  Future<void> onMessageReceived(StompFrame frame) async {
    print('Received: ${frame.body}');
    if (_onMessageReceivedCallback != null) {
      var message = Message.fromJson(jsonDecode(frame.body ?? ''));

      if (message.status == 'SUCCESS') {
        _onMessageReceivedCallback!(message.messageData);
      }
    }
  }

  // 매칭 성공
  Future<void> onMatchingSuccess(StompFrame frame) async {
    print('Matching Success: ${frame.body}');
    if (_onMatchingSuccessCallback != null) {
      final matchingSuccess = jsonDecode(frame.body ?? '');
      _onMatchingSuccessCallback!(matchingSuccess);
    }
  }
  // #endregion

  // #region send
  // 메시지 전송
  Future<void> sendMessage(String content) async {
    print('send message');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
            destination: '/v1/rooms/$_roomId/messages/send',
            body: jsonEncode({
              "userId": _userId,
              "content": content,
              "contentType": "TEXT",
            }));
      } catch (e) {
        throw Exception('<sendMessage> Fail');
      }
    } else {
      throw Exception('<sendMessage> not connected');
    }
  }

  // 방 입장
  Future<void> enterRoom() async {
    print('enter room');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/rooms/$_roomId/enter',
          body: jsonEncode({
            "userId": _userId,
          }),
        );
        subscribeToRecieveMessage();
      } catch (e) {
        throw Exception('<enterRoom> Fail');
      }
    } else {
      throw Exception('<enterRoom> not connected');
    }
  }

  // 방 나가기
  Future<void> exitRoom({String? roomId}) async {
    roomId ??= _roomId;
    print('exit room : $roomId');
    bool isInternetConnection = await checkInternetConnection();
    if (_stompClient!.connected && isInternetConnection) {
      try {
        _stompClient?.send(
          destination: '/v1/rooms/$roomId/exit',
          body: jsonEncode({
            'userId': _userId,
          }),
        );
        print('<exitRoom>');
      } catch (e) {
        print('<exitRoom> catch');
        throw Exception('<exitRoom> Fail');
      }
    } else {
      print('<exitRoom> else');
      throw Exception('<exitRoom> not connected');
    }
  }

  // 매칭 요청
  Future<void> requestMatching() async {
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": _userId}),
        );
      } catch (e) {
        throw Exception('<requestMatching> Fail');
      }
    } else {
      throw Exception('<requestMatching> not connected');
    }
  }

  // 임시로 쓰는 매칭 함수
  Future<void> tempRequestMatching() async {
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": userId2}),
        );
      } catch (e) {
        throw Exception('<tempRequestMatching> Fail');
      }
    } else {
      throw Exception('<tempRequestMatching> not connected');
    }
  }

  // 매칭 취소
  Future<void> cancelMatching() async {
    print('cancel matching');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/cancel',
          body: jsonEncode({"userId": _userId}),
        );
      } catch (e) {
        throw Exception('<cancelMatching> Fail');
      }
    } else {
      throw Exception('<cancelMatching> not connected');
    }
  }
  // #endregion
  // #endregion

  Future<bool> checkInternetConnection() async {
    print('checkInternetConnection');
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      print('connectivityResult: $connectivityResult');
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        print('connectivityResult: true');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('checkInternetConnection error : $e');
      return false;
    }
  }

  void dispose() {
    _stompClient?.deactivate();
  }
}
