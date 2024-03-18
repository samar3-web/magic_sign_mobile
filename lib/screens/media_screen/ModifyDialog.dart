import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';
import 'package:magic_sign_mobile/screens/model/Media.dart';

class ModifyDialog extends StatefulWidget {
  final Media media;

  ModifyDialog({required this.media});

  @override
  State<ModifyDialog> createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _retiredController;

  MediaController controller = MediaController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.media.name);
    _durationController =
        TextEditingController(text: widget.media.duration.toString());
    _retiredController =
        TextEditingController(text: widget.media.retired.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modify Media'),
      content: SingleChildScrollView(
        child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          TextField(
            controller: _nameController,
            style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w300,
                            ),
            decoration: InputDecoration(labelText: 'Name',
            labelStyle: TextStyle(color: kTextBlackColor,fontSize: 17.0)
                        ),
          ),
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
            await controller.updateMediaData(
              widget.media.mediaId,
              _nameController.text,
              _durationController.text,
              _retiredController.text,
            );
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _retiredController.dispose();
    super.dispose();
  }
}
