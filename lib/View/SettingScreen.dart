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

  void _showReQuestionDialog() {
    var nickName = _nicknameController.text;
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final message = _nicknameController.text.trim();
                if (message.isNotEmpty) {
                  setState(() {
                    // _messages.add(Message(
                    //     message: message,
                    //     color: isMe ? Colors.yellow : Colors.white));
                    _nicknameController.clear();
                  });
                  _showReQuestionDialog();
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
              child: const Text('변경하기'),
            ),
          ],
        ),
      ),
    );
  }
}
