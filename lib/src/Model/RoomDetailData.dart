import 'package:ranchat_flutter/src/Model/ParticipantsData.dart';

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

  RoomDetailData copyWith({
    int? id,
    String? title,
    String? type,
    List<ParticipantsData>? participants,
  }) {
    return RoomDetailData(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      participants: participants ?? this.participants,
    );
  }
}
