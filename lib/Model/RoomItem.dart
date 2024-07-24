class Roomitem {
  String id;
  String title;
  String latestMessage;
  String latestSendAt;

  Roomitem(
      {required this.id,
      required this.title,
      required this.latestMessage,
      required this.latestSendAt});

  factory Roomitem.fromJson(Map<String, dynamic> json) {
    return Roomitem(
      id: json['id'],
      title: json['title'],
      latestMessage: json['latestMessage'],
      latestSendAt: json['latestSendAt'],
    );
  }
}
