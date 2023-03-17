import 'package:chat_gpt/models/chat_model.dart';
import 'package:flutter/material.dart';

import '../services/api_services.dart';

class ChatProvider with ChangeNotifier {

  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUsersMessage(String msg) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(String msg, String choosenModel) async {
    chatList.addAll(await ApiService.sendMessage(
        msg,
        choosenModel
    ));
    notifyListeners();
  }
}
