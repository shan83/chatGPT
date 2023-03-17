import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/services/api_services.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelDropDownWidget extends StatefulWidget {
  const ModelDropDownWidget({Key? key}) : super(key: key);

  @override
  State<ModelDropDownWidget> createState() => _ModelDropDownWidgetState();
}

class _ModelDropDownWidgetState extends State<ModelDropDownWidget> {

  String? currentModel;

  @override
  Widget build(BuildContext context) {

    final modalProvider = Provider.of<ModelsProvider>(context, listen: false);
    currentModel = modalProvider.getCurrentModel;
    return FutureBuilder<List<ModelsModel>>(
        future: modalProvider.getAllModels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: TextWidget(label: snapshot.error.toString()),);
          }
          return snapshot.data == null || snapshot.data!.isEmpty ? SizedBox.shrink() :
            FittedBox(
              child: DropdownButton(
                  dropdownColor: scaffoldBackgroundColor,
                  iconEnabledColor: Colors.white,
                  items: List<DropdownMenuItem<String>>.generate(
                      snapshot.data!.length,
                          (index) => DropdownMenuItem(
                            value: snapshot.data![index].id,
                              child: TextWidget(
                                  label: snapshot.data![index].id,
                                fontSize: 15,
                              )
                          )
                  ),
                  value: currentModel,
                  onChanged: (value) {
                    setState(() {
                      currentModel = value.toString();
                    });
                    modalProvider.setCurrentModel(value.toString());
                  }
              ),
            );
        }
    );
  }

  /*
  * DropdownButton(
      dropdownColor: scaffoldBackgroundColor,
        iconEnabledColor: Colors.white,
        items: getModelsItem,
        value: currentModel,
        onChanged: (value) {
            setState(() {
              currentModel = value.toString();
            });
        }
    );
  * */
}
