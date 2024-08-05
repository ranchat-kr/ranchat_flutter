class ParticipantsData {
  int id;
  String userId, name;

  ParticipantsData(
      {required this.id, required this.userId, required this.name});

  factory ParticipantsData.fromJson(Map<String, dynamic> json) {
    return ParticipantsData(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
    );
  }
}
