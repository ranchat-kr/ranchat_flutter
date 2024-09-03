import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/RoomData.dart';
import 'package:ranchat_flutter/src/Model/RoomDetailData.dart';
import 'package:ranchat_flutter/src/repository/room_repository.dart';

class RoomService with ChangeNotifier {
  /// 방 리스트
  List<RoomData> _roomList = [];
  List<RoomData> get roomList => _roomList;

  set roomList(List<RoomData> value) {
    _roomList = value;
    notifyListeners();
  }

  /// 현재 방 상세 정보
  RoomDetailData _roomDetail = RoomDetailData(
    id: 0,
    title: '',
    type: '',
    participants: [],
  );
  RoomDetailData get roomDetail => _roomDetail;

  set roomDetail(RoomDetailData value) {
    _roomDetail = value.copyWith();
    notifyListeners();
  }

  final RoomRepository _roomRepository = RoomRepository();

  /// 방 리스트 조회
  Future<void> getRoomList(int page, int size, String userId) async {
    _roomList =
        await _roomRepository.getRooms(page: page, size: size, userId: userId);
    notifyListeners();
  }

  /// 방 존재 여부 확인
  Future<bool> checkRoomExist(String userId) async {
    return await _roomRepository.checkRoomExist(userId);
  }

  /// 방 상세 조회
  Future<RoomDetailData> getRoomDetail(String userId, String roomId) async {
    RoomDetailData roomDetail =
        await _roomRepository.getRoomDetail(userId, roomId);
    _roomDetail = roomDetail.copyWith();
    return roomDetail;
  }

  /// 방 생성
  Future<String> createRoom(String userId) async {
    final res = await _roomRepository.createRoom(userId);
    return res;
  }
}
