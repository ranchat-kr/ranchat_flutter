import 'dart:convert';

import 'package:ranchat_flutter/Model/Message.dart';
import 'package:ranchat_flutter/Model/MessageList.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;

import '../Model/MessageData.dart';

class Connectingservice {
  StompClient? _stompClient;
  final _domain = "dev-api.ranchat.net:8080";
  final String roomId = "1";
  final String userId1 = "0190964c-af3f-7486-8ac3-d3ff10cc1470";
  final String userId2 = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1";
  late String userId = userId1;
  Function(MessageData)? _onMessageReceivedCallback;
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

  Connectingservice({Function(MessageData)? onMessageReceivedCallback}) {
    _onMessageReceivedCallback = onMessageReceivedCallback;
  }

  ///WebSocket server
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

  void _onConnected(StompFrame frame, String roomId) {
    print('Connected: ${frame.body}');

    _stompClient!.subscribe(
        destination: '/topic/v1/rooms/$roomId/messages/new',
        callback: _onMessageReceived);

    _enterRoom();
  }

  void _onMessageReceived(StompFrame frame) {
    print('Received: ${frame.body}');
    if (_onMessageReceivedCallback != null) {
      final message = Message.fromJson(jsonDecode(frame.body ?? ''));

      _onMessageReceivedCallback!(message.messageData);
    }
  }

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

  void _enterRoom() {
    print('enter room');
    _stompClient!.send(
        destination: '/v1/rooms/$roomId/enter',
        body: jsonEncode({
          "userId": userId,
        }));
  }

  void changeUser() {
    userId = userId == userId1 ? userId2 : userId1;
  }

  void dispose() {
    _stompClient!.deactivate();
  }

  /// API
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
}
