import 'dart:convert';

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

  void setOnMessageReceivedCallback(Function(MessageData) callback) async {
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

  void connectToWebSocket() async {
    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://${Defaultdata.domain}/endpoint',
          stompConnectHeaders: {'userId': _userId},
          onConnect: (StompFrame frame) => subscribeToMatchingSuccess(frame),
          onWebSocketError: (dynamic error) => print(error.toString()),
          onWebSocketDone: () => print('WebSocket connect done.'),
          onStompError: (StompFrame frame) =>
              print('Stomp error: ${frame.body}'),
          onDisconnect: (StompFrame frame) =>
              print('Disconnected: ${frame.body}'),
          onDebugMessage: (String message) => print('Debug: $message'),
        ),
      );
      _stompClient?.activate();
    } catch (e) {
      print('error: $e');
    }
  }

  void subscribeToMatchingSuccess(StompFrame frame) async {
    print('subscribe to matching success');
    subscriptionToMatchingSuccess = _stompClient?.subscribe(
      destination: '/user/$_userId/queue/v1/matching/success',
      callback: onMatchingSuccess,
      headers: {'matchingSuccess': 'true'},
    );
  }

  void subscribeToRecieveMessage() async {
    print('subscribe to recieve message');
    subscriptionToRecieveMessage = _stompClient?.subscribe(
      destination: '/topic/v1/rooms/$_roomId/messages/new',
      callback: onMessageReceived,
      headers: {'recieveMessage': 'true'},
    );
  }

  void unSubscribeToMatchingSuccess() async {
    subscriptionToMatchingSuccess(
        unsubscribeHeaders: {'matchingSuccess': 'true'});
  }

  void unSubscribeToRecieveMessage() async {
    subscriptionToRecieveMessage(
        unsubscribeHeaders: {'recieveMessage': 'true'});
  }

  // #region recieve
  // 메시지 수신
  void onMessageReceived(StompFrame frame) async {
    print('Received: ${frame.body}');
    if (_onMessageReceivedCallback != null) {
      final message = Message.fromJson(jsonDecode(frame.body ?? ''));

      _onMessageReceivedCallback!(message.messageData);
    }
  }

  // 매칭 성공
  void onMatchingSuccess(StompFrame frame) async {
    print('Matching Success: ${frame.body}');
    if (_onMatchingSuccessCallback != null) {
      final matchingSuccess = jsonDecode(frame.body ?? '');
      _onMatchingSuccessCallback!(matchingSuccess);
    }
  }
  // #endregion

  // #region send
  // 메시지 전송
  void sendMessage(String content) async {
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
        print('send Message error: $e');
      }
    } else {
      print('send message error: not connected');
    }
  }

  // 방 입장
  void enterRoom() async {
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
        print('enter room error: $e');
      }
    } else {
      print('enter room error: not connected');
    }
  }

  // 방 나가기
  void exitRoom({String? roomId}) async {
    roomId ??= _roomId;
    print('exit room : $roomId');
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/rooms/$roomId/exit',
          body: jsonEncode({
            'userId': _userId,
          }),
        );
      } catch (e) {
        print('exit room error: $e');
      }
    } else {
      print('exit room error: not connected');
    }
  }

  // 매칭 요청
  void requestMatching() async {
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": _userId}),
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
    if (_stompClient!.connected) {
      try {
        _stompClient?.send(
          destination: '/v1/matching/apply',
          body: jsonEncode({"userId": userId2}),
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
          body: jsonEncode({"userId": _userId}),
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

  void dispose() {
    _stompClient?.deactivate();
  }
}
