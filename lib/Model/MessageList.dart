import 'package:ranchat_flutter/Model/MessageData.dart';

class MessageList {
  final String status;
  final String message;
  final String serverDateTime;
  final List<MessageData> items;
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
}
