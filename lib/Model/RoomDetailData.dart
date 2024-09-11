import 'package:ran_talk/Model/ParticipantsData.dart';

class RoomDetailData {
  final int id;
  final String title;
  final String type;
  final List<ParticipantsData> participants;

  RoomDetailData(
      {required this.id,
      required this.title,
      required this.type,
      required this.participants});

  factory RoomDetailData.fromJson(Map<String, dynamic> json) {
    var data = json['data'] as Map<String, dynamic>;
    var participantsJson = data['participants'] as List;
    List<ParticipantsData> participantsList = participantsJson
        .map((itemJson) => ParticipantsData.fromJson(itemJson))
        .toList();
    return RoomDetailData(
      id: data['id'],
      title: data['title'],
      type: data['type'],
      participants: participantsList,
    );
  }
}
