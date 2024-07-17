import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class Connectingservice {
  StompClient? _stompClient;
  final domain = "52.78.91.184:8080";

  void connectToWebSocket() {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$domain/endpoint',
        onConnect: _onConnected,
        onWebSocketError: (dynamic error) => print(error.toString()),
        onWebSocketDone: () => print('WebSocket connect done.'),
        onStompError: (StompFrame frame) => print('Stomp error: ${frame.body}'),
        onDisconnect: (StompFrame frame) =>
            print('Disconnected: ${frame.body}'),
      ),
    );
    _stompClient!.activate();
  }

  void _onConnected(StompFrame frame) {
    print('Connected: ${frame.body}');

    _stompClient!.subscribe(
        destination: '/topic/v1/rooms/1/messages/new',
        callback: _onMessageReceived);
  }

  void _onMessageReceived(StompFrame frame) {
    print('Received: ${frame.body}');
  }

  void sendMessage(String content) {
    _stompClient!.send(
        destination: '/v1/rooms/1/messages/send',
        body: jsonEncode({
          "userId": "0190964c-af3f-7486-8ac3-d3ff10cc1470",
          "content": content,
          "contentType": "TEXT",
        }));
  }

  void dispose() {
    _stompClient!.deactivate();
  }
}
