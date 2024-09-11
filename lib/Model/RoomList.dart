import 'package:ran_talk/Model/RoomData.dart';

class RoomList {
  final String status;
  final String message;
  final String serverDateTime;
  final List<RoomData> items;
  final int page;
  final int size;
  final int totalCount;
  final int totalPage;
  final bool empty;

  RoomList({
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

  factory RoomList.fromJson(Map<String, dynamic> json) {
    print('MessageList.fromJson: $json');
    print(json['data']);

    var itemsJson = json['data']['items'] as List;
    List<RoomData> itemsList =
        itemsJson.map((itemJson) => RoomData.fromJson(itemJson)).toList();
    return RoomList(
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
