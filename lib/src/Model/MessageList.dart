import 'package:ranchat_flutter/src/Model/MessageData.dart';

class MessageList {
  final String status;
  final String message;
  final String serverDateTime;
  late final List<MessageData> items;
  final int page;
  final int size;
  final int totalCount;
  final int totalPage;
  final bool empty;

  MessageList({
    required this.status,
    required this.message,
    required this.serverDateTime,
    required this.items,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPage,
    required this.empty,
  });

  factory MessageList.fromJson(Map<String, dynamic> json) {
    print('MessageList.fromJson: $json');
    print(json['data']);

    var itemsJson = json['data']['items'] as List;
    List<MessageData> itemsList =
        itemsJson.map((itemJson) => MessageData.fromJson(itemJson)).toList();
    return MessageList(
      status: json['status'],
      message: json['message'],
      serverDateTime: json['serverDateTime'],
      items: itemsList,
      page: json['data']['page'],
      size: json['data']['size'],
      totalCount: json['data']['totalCount'],
      totalPage: json['data']['totalPage'],
      empty: json['data']['empty'],
    );
  }

  MessageList copyWith({
    String? status,
    String? message,
    String? serverDateTime,
    List<MessageData>? items,
    int? page,
    int? size,
    int? totalCount,
    int? totalPage,
    bool? empty,
  }) {
    return MessageList(
      status: status ?? this.status,
      message: message ?? this.message,
      serverDateTime: serverDateTime ?? this.serverDateTime,
      items: items ?? this.items,
      page: page ?? this.page,
      size: size ?? this.size,
      totalCount: totalCount ?? this.totalCount,
      totalPage: totalPage ?? this.totalPage,
      empty: empty ?? this.empty,
    );
  }
}
