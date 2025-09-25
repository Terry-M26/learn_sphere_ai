import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/apis/apis.dart';

import 'package:learn_sphere_ai/model/message.dart';

class ChatController extends GetxController {
  final textC = TextEditingController();

  final list = <Message>[
    Message(
      msg: 'Hello, I am Albert, your AI tutor, how can I assist you today?',
      msgType: MessageType.bot,
    ),
  ].obs;

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      //user
      list.add(Message(msg: textC.text, msgType: MessageType.user));
      list.add(Message(msg: 'Thinking...', msgType: MessageType.bot));

      final res = await APIs.getAnswer(textC.text);

      //bot
      list.removeLast();
      list.add(Message(msg: res, msgType: MessageType.bot));

      //clear
      textC.clear();
    }
  }
}
