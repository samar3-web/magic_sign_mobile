import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';

class DeleteDialog extends StatefulWidget {
  final Media media;

  const DeleteDialog({Key? key, required this.media}) : super(key: key);

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  final MediaController mediaController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Supression'),
      content: Text('Voulez-vous vraiment supprimer ${widget.media.name}?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); 
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
                await mediaController.deleteMedia(widget.media.mediaId);
          
          },
          child: Text('Confirmer'),
        ),
      ],
    );
  }
}
