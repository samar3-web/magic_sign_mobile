import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/model/Widget.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';

class ModifyDialog extends StatefulWidget {
  final WidgetData widgetData;

  ModifyDialog({required this.widgetData});

  @override
  State<ModifyDialog> createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
  late TextEditingController _durationController;

  PlaylistController controller = PlaylistController();

  @override
  void initState() {
    super.initState();
    _durationController =
        TextEditingController(text: widget.widgetData.duration.toString());
  
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier la durée'),
      content: SingleChildScrollView(
        child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          TextField(
            controller: _durationController,
               style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
            decoration: InputDecoration(labelText: 'Duration',
                        labelStyle: TextStyle(color: kTextBlackColor,fontSize: 17.0)
),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
       ElevatedButton(
  onPressed: () async {
   String? updatedDuration = await controller.editWidget(
  widget.widgetData.widgetId!, 
  _durationController.text,   
);
    Navigator.of(context).pop(updatedDuration); 
  },
  child: Text('Save'),
),

      ],
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}
