import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';
import 'package:magic_sign_mobile/screens/model/Media.dart';

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
      title: Text('Confirmation'),
      content: Text('Voulez-vous vraiment supprimer ${widget.media.name}?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); // Return false to indicate cancellation
          },
          child: Text('Annuler'),
        ),
       ElevatedButton(
          onPressed: () async {
            // Perform delete operation using the controller
            bool deleteSuccess = await mediaController.deleteMedia(widget.media.mediaId);
            if (deleteSuccess) {
              // Reload data after successful deletion
              mediaController.getMedia();
              // Show snackbar notification
              Get.snackbar('Suppression', 'Le média ${widget.media.name} a été supprimé.', backgroundColor: Colors.green);
            } else {
              // Handle delete failure
              Get.snackbar('Erreur', 'Une erreur s\'est produite lors de la suppression.', backgroundColor: Colors.red);
            }
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Confirmer'),
        ),
      ],
    );
  }
}
