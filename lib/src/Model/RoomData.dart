class RoomData {
  int id;
  String title;
  String type;
  String latestMessage;
  String latestMessageAt;

  RoomData(
      {required this.id,
      required this.title,
      required this.type,
      required this.latestMessage,
      required this.latestMessageAt});

  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      latestMessage: json['latestMessage'] ?? '',
      latestMessageAt: json['latestMessageAt'] ?? '',
    );
  }

  RoomData copyWith({
    int? id,
    String? title,
    String? type,
    String? latestMessage,
    String? latestMessageAt,
  }) {
    return RoomData(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      latestMessage: latestMessage ?? this.latestMessage,
      latestMessageAt: latestMessageAt ?? this.latestMessageAt,
    );
  }
}
