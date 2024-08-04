import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';

class Settingscreen extends StatefulWidget {
  final Connectingservice connectingservice;
  const Settingscreen({super.key, required this.connectingservice});

  @override
  _SettingscreenState createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late Connectingservice _connectingservice;

  @override
  void initState() {
    super.initState();
    _connectingservice = widget.connectingservice;
  }

  void _showReQuestionDialog(String nickName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('닉네임 변경'),
          content: Text('닉네임을 \'$nickName\'(으)로 변경하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _connectingservice.updateUserName(nickName);
              },
              child: const Text('변경'),
            )
          ],
        );
      },
    );
  }

  bool _isValidNickName(String nickName) {
    final List<String> forbiddenWords = [
      'admin',
      'administrator',
      'sex',
      '섹스',
    ];
    RegExp specialCharRegex = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');

    if (nickName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          duration: Duration(seconds: 1),
        ),
      );
      return false;
    } else if (nickName.length < 2 || nickName.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 2자 이상 10자 이하로 입력해주세요.'),
          duration: Duration(seconds: 1),
        ),
      );
      return false;
    } else if (nickName.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임에 공백이 포함되어 있습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return false;
    } else if (specialCharRegex.hasMatch(nickName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임에 특수문자가 포함되어 있습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return false;
    }
    for (var word in forbiddenWords) {
      if (nickName.contains(word)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('금지된 단어가 포함되어 있습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '기존 닉네임',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _nicknameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '닉네임',
                    hintText: '바꿀 닉네임을 입력해주세요.',
                    hintStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final nickName = _nicknameController.text.trim();
                  if (_isValidNickName(nickName) && nickName.isNotEmpty) {
                    setState(() {
                      // _messages.add(Message(
                      //     message: message,
                      //     color: isMe ? Colors.yellow : Colors.white));
                      _nicknameController.clear();
                    });
                    _showReQuestionDialog(nickName);
                  }
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: const BorderSide(color: Colors.red, width: 2.0)),
                ),
                child: const Text('변경하기', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
