import 'package:chat_gpt/widgets/drop_down.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../widgets/text_widget.dart';

class Services {
  static Future<void> showModelSheet(BuildContext context) async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)
            )
        ),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Flexible(child: TextWidget(label: "Choose model : ", fontSize: 16,)),
                Flexible(
                  flex: 2,
                    child: ModelDropDownWidget())
              ],
            ),
          );
        });
  }
}