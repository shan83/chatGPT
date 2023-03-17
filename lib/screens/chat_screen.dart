import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/providers/chat_provider.dart';
import 'package:chat_gpt/services/api_services.dart';
import 'package:chat_gpt/services/services.dart';
import 'package:chat_gpt/widgets/chat_widget.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/chat_model.dart';
import '../providers/models_provider.dart';
import '../services/assets_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = new TextEditingController();
    focusNode = new FocusNode();
    _speech = stt.SpeechToText();
    super.initState();

  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  //List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {

    final modalProvider = Provider.of<ModelsProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('chatGPT'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        actions: [
          IconButton(onPressed: () async {
            await Services.showModelSheet(context);
          }, icon: const Icon(Icons.more_vert_rounded, color: Colors.white,))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.chatList.length,
                  itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.chatList[index].msg,
                    chatIndex: chatProvider.chatList[index].chatIndex,
                  );
              }),
            ),
            if(_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ), ],
              const SizedBox(height: 15,),
              Material(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                            focusNode : focusNode,
                            style: const TextStyle(color: Colors.white),
                            controller: textEditingController,
                            onSubmitted: (value) async {
                              await sendMessageFCT(modalProvider, chatProvider);
                            },
                            decoration: const InputDecoration.collapsed(
                                hintText: 'How can I help you',
                              hintStyle: TextStyle(color: Colors.grey)
                            ),
                          )
                      ),
                      AvatarGlow(
                        animate: _isListening,
                        glowColor: Theme.of(context).primaryColor,
                        endRadius: 20.0,
                        duration: const Duration(milliseconds: 2000),
                        repeatPauseDuration: const Duration(milliseconds: 100),
                        repeat: true,
                        child: IconButton(
                          onPressed: () async {
                            _listen(modalProvider, chatProvider);
                          },
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        ),
                      ),
                      IconButton(onPressed: () async {
                        await sendMessageFCT(modalProvider, chatProvider);
                      },
                          icon: const Icon(Icons.send, color: Colors.white,))
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(ModelsProvider modalProvider, ChatProvider chatProvider) async {
    String msg = textEditingController.text;
    if(_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(
              label: "You can't send multiple messages at a time",
            ),
            backgroundColor: Colors.red,
          )
      );
      return;
    }
    if(msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(
              label: 'Please type a message',
            ),
            backgroundColor: Colors.red,
          )
      );
      return;
    }
    try {
      setState(() {
        _isTyping = true;
        //chatList.add(ChatModel(msg: msg, chatIndex: 0));
        chatProvider.addUsersMessage(msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      //chatList.addAll(await ApiService.sendMessage(
      //    msg,
      //    modalProvider.getCurrentModel
      //));
      await chatProvider.sendMessageAndGetAnswers(msg, modalProvider.getCurrentModel);
      setState(() {

      });
    }catch(error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: TextWidget(
                label: error.toString(),
              ),
            backgroundColor: Colors.red,
          )
      );
    }finally{
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }

  Future<void> _listen(ModelsProvider modalProvider, ChatProvider chatProvider) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            textEditingController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
      await Future.delayed(const Duration(seconds: 5));
      if (textEditingController.text.isNotEmpty) {
        setState(() => _isListening = false);
        _speech.stop();
        await sendMessageFCT(modalProvider, chatProvider);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      await sendMessageFCT(modalProvider, chatProvider);
    }
  }

}
