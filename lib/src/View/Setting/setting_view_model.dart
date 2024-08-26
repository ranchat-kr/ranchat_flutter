// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';

class SettingViewModel extends BaseViewModel {
  final UserService userService;
  SettingViewModel({
    required this.userService,
  });

  void updateUserName(String nickname) {
    userService.updateUserName(nickname);
  }
}
