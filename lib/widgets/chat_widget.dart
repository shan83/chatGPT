import 'dart:ffi';

import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/services/assets_manager.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatWidget extends StatelessWidget {
  ChatWidget({Key? key, required this.msg, required this.chatIndex}) : super(key: key);

  final String msg;
  final int chatIndex;

  final FlutterTts flutterTts = FlutterTts();
  bool startSpeak = true;
  speak(String text) async {
    startSpeak = false;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  stopSpeak() {
    startSpeak = true;
    flutterTts.stop();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatIndex == 0 ? AssetsManager.userImage : AssetsManager.botImage,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: chatIndex == 0 ?
                  TextWidget(label: msg):
                  DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,

                    ),
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                        repeatForever: false,
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText(
                              msg.trim(),
                          )
                        ]
                    ),
                  )
                ),
                chatIndex == 0 ? const SizedBox.shrink() : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(Icons.thumb_down_alt_outlined,
                        color: Colors.white),
                    IconButton(
                      icon: const Icon(Icons.speaker),
                      tooltip: 'Voice',
                        onPressed: () => startSpeak ? speak(msg) : stopSpeak(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
