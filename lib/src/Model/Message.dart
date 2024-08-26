import 'package:ranchat_flutter/src/Model/MessageData.dart';

class Message {
  final String status;
  final String message;
  final String serverDatetime;
  final MessageData messageData;

  Message({
    required this.status,
    required this.message,
    required this.serverDatetime,
    required this.messageData,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    print('Message.fromJson: $json');
    print(json['data']);
    return Message(
      status: json['status'],
      message: json['message'],
      serverDatetime: json['serverDatetime'],
      messageData: MessageData.fromJson(json['data']),
    );
  }

  Message copyWith({
    String? status,
    String? message,
    String? serverDatetime,
    MessageData? messageData,
  }) {
    return Message(
      status: status ?? this.status,
      message: message ?? this.message,
      serverDatetime: serverDatetime ?? this.serverDatetime,
      messageData: messageData ?? this.messageData,
    );
  }
}
