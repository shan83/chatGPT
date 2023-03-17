import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_gpt/constants/api_const.dart';
import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<List<ModelsModel>> getModels() async {

    try {
      var response = await http.get(Uri.parse("$BASE_URL/models"),
      headers: {
        'Authorization': 'Bearer $API_KEY'
      });
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse["error"] != null) {
        throw HttpException(jsonResponse["error"]["message"]);
      }
      log('jsonResponse $jsonResponse');
      List temp = [];
      for(var i in jsonResponse["data"]) {
        temp.add(i);
        log('temp ${i["id"]}');
      }
      return ModelsModel.modelsFromSnapShot(temp);
    } catch(error) {
      log('error : $error');
      rethrow;
    }
  }

  //send message

  static Future<List<ChatModel>> sendMessage(String message, String modelId) async {
    try {
      var response = await http.post(Uri.parse("$BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            'Content-Type' : 'application/json'
          },
        body: jsonEncode({
          "model": modelId,
          "prompt": message,
          "max_tokens": 1000,
        }),
          );
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse["error"] != null) {
        throw HttpException(jsonResponse["error"]["message"]);
      }
      List<ChatModel> chatModels = [];
      if (jsonResponse["choices"].length > 0) {
        chatModels = List.generate(jsonResponse["choices"].length, (index) => ChatModel(
            msg: jsonResponse["choices"][index]["text"],
            chatIndex: 1
        ));
      }
      return chatModels;
    } catch(error) {
      log('error : $error');
      rethrow;
    }
  }

}
