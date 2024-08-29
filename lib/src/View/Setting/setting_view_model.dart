// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ranchat_flutter/src/Model/User.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';

class SettingViewModel extends BaseViewModel {
  final UserService userService;
  SettingViewModel({
    required this.userService,
  }) {
    user = User(id: userService.userId, name: userService.userName);
  }

  User? user;

  get userName {
    return user?.name;
  }

  set setUserName(String name) {
    user = user?.copyWith(name: name);
    notifyListeners();
  }

  void updateUserName(String nickname) async {
    await userService.updateUserName(nickname);
    user = user?.copyWith(name: nickname);
    notifyListeners();
  }
}
