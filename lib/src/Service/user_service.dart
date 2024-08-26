import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/User.dart';
import 'package:ranchat_flutter/src/repository/user_repository.dart';

class UserService with ChangeNotifier {
  /// 유저 정보
  User _user = User(id: '', name: '');
  final UserRepository _userRepository = UserRepository();

  String get userId => _user.id;
  String get userName => _user.name;

  set userId(String id) {
    _user.id = id;
    notifyListeners();
  }

  set userName(String name) {
    _user.name = name;
    notifyListeners();
  }

  /// 유저 생성
  Future<void> createUser(String getRandomNickname) async {
    _user = await _userRepository.createUser(userId, getRandomNickname);
  }

  /// 유저 조회
  Future<void> getUser() async {
    _user = await _userRepository.getUser(userId);
  }

  /// 유저 이름 수정
  Future<void> updateUserName(String name) async {
    await _userRepository.updateUserName(userId, name);
    _user = await _userRepository.getUser(userId);
  }

  /// 유저 신고
  Future<void> reportUser(String roomId, String userId, String reportedUserId,
      String selectedReason, String reportReason) {
    return _userRepository.reportUser(
        roomId, userId, reportedUserId, selectedReason, reportReason);
  }
}
