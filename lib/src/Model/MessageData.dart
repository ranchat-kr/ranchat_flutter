import 'dart:convert';

class MessageData {
  final int id;
  final int roomId;
  final String userId;
  final int participantId;
  final String participantName;
  final String content;
  final String messageType;
  final String contentType;
  final String senderType;
  final String createdAt;

  MessageData({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.participantId,
    required this.participantName,
    required this.content,
    required this.messageType,
    required this.contentType,
    required this.senderType,
    required this.createdAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    print('MessageData.fromJson: $json');
    return MessageData(
      id: json['id'],
      roomId: json['roomId'],
      userId: json['userId'],
      participantId: json['participantId'],
      participantName: json['participantName'],
      content: json['content'],
      messageType: json['messageType'],
      contentType: json['contentType'],
      senderType: json['senderType'],
      createdAt: json['createdAt'],
    );
  }

  MessageData copyWith({
    int? id,
    int? roomId,
    String? userId,
    int? participantId,
    String? participantName,
    String? content,
    String? messageType,
    String? contentType,
    String? senderType,
    String? createdAt,
  }) {
    return MessageData(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      contentType: contentType ?? this.contentType,
      senderType: senderType ?? this.senderType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
