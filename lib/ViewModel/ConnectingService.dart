import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'package:ranchat_flutter/Model/Message.dart';
import 'package:ranchat_flutter/Model/MessageList.dart';

import '../Model/MessageData.dart';

class Connectingservice {
  StompClient? _stompClient; // WebSocket client
  final _domain = "dev-api.ranchat.net:8080";
  final String roomId = "1";
  final String userId1 = "0190964c-af3f-7486-8ac3-d3ff10cc1470";
  final String userId2 = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1";
  late String userId = userId1;
  Function(MessageData)? _onMessageReceivedCallback;
  Function(Map<String, dynamic>)? _onMatchingSuccessCallback;
  MessageList messageList = MessageList(
    status: '',
    message: '',
    serverDateTime: '',
    items: [],
    page: 0,
    size: 0,
    totalCount: 0,
    totalPage: 0,
    empty: false,
  );

  Connectingservice(
      {Function(MessageData)? onMessageReceivedCallback,
      Function(dynamic response)? onMatchingSuccess}) {
    _onMessageReceivedCallback = onMessageReceivedCallback;
    _onMatchingSuccessCallback = onMatchingSuccess;
  }

  void setOnMessageReceivedCallback(Function(MessageData) callback) {
    _onMessageReceivedCallback = callback;
  }

  // #region WebSocket
  // #region first setting
  //WebSocket server
  void connectToWebSocket() {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$_domain/endpoint',
        stompConnectHeaders: {'userId': userId},
        onConnect: (StompFrame frame) => _onConnected(frame, roomId),
        onWebSocketError: (dynamic error) => print(error.toString()),
        onWebSocketDone: () => print('WebSocket connect done.'),
        onStompError: (StompFrame frame) => print('Stomp error: ${frame.body}'),
        onDisconnect: (StompFrame frame) =>
            print('Disconnected: ${frame.body}'),
      ),
    );
    _stompClient!.activate();
  }

  // 웹소켓 구독
  void _onConnected(StompFrame frame, String roomId) {
    print('Connected: ${frame.body}');

    _stompClient!.subscribe(
        destination: '/topic/v1/rooms/$roomId/messages/new',
        callback: _onMessageReceived);

    _stompClient!.subscribe(
      destination: '/user/$userId/queue/v1/matching/success',
      callback: _onMatchingSuccess,
    );

    //_enterRoom();
  }
  // #endregion

  // #region recieve
  // 메시지 수신
  void _onMessageReceived(StompFrame frame) {
    print('Received: ${frame.body}');
    if (_onMessageReceivedCallback != null) {
      final message = Message.fromJson(jsonDecode(frame.body ?? ''));

      _onMessageReceivedCallback!(message.messageData);
    }
  }

  // 매칭 성공
  void _onMatchingSuccess(StompFrame frame) {
    print('Matching Success: ${frame.body}');
    if (_onMatchingSuccessCallback != null) {
      final matchingSuccess = jsonDecode(frame.body ?? '');
      _onMatchingSuccessCallback!(matchingSuccess);
    }
  }
  // #endregion

  // #region send
  // 메시지 전송
  void sendMessage(String content) {
    print('send message');
    _stompClient!.send(
        destination: '/v1/rooms/$roomId/messages/send',
        body: jsonEncode({
          "userId": userId,
          "content": content,
          "contentType": "TEXT",
        }));
  }

  // 방 입장
  void _enterRoom() {
    print('enter room');
    _stompClient!.send(
        destination: '/v1/rooms/$roomId/enter',
        body: jsonEncode({
          "userId": userId,
        }));
  }

  // 매칭 요청
  void requestMatching() {
    _stompClient!.send(
      destination: '/v1/matching/apply',
      body: jsonEncode({"userId": userId}),
    );
  }

  // 매칭 취소
  void cancelMatching() {
    _stompClient!.send(
      destination: 'v1/matching/cancel',
      body: jsonEncode({"userId": userId}),
    );
  }
  // #endregion
  // #endregion

  void changeUser() {
    userId = userId == userId1 ? userId2 : userId1;
  }

  void dispose() {
    _stompClient!.deactivate();
  }

  // #region HTTP
  // 메시지 목록 조회
  Future<List<MessageData>> getMessages({int page = 0, int size = 20}) async {
    final response = await http.get(Uri.parse(
        'http://$_domain/v1/rooms/$roomId/messages?page=$page&size=$size'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      messageList = MessageList.fromJson(responseData);
      return messageList.items;
    } else {
      return [];
    }
  }
  // #endregion
}
