import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:intl/intl.dart';

class ScheduleEventScreen extends StatefulWidget {
  final int campaignId;

  ScheduleEventScreen({required this.campaignId});

  @override
  _ScheduleEventScreenState createState() => _ScheduleEventScreenState();
}

class _ScheduleEventScreenState extends State<ScheduleEventScreen> {
  bool _isChecked = false;
  final PlaylistController playlistController = PlaylistController();
  final PlayerController playerController = PlayerController();
  List<dynamic> displayGroupIds = [];

  List<int> selectedDisplayGroupIds = [];
  TextEditingController fromDtController = TextEditingController();
  TextEditingController toDtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<dynamic> groups = await playerController.fetchData();
      setState(() {
        displayGroupIds = groups;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Planifier un événement'),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayGroupIds.map((groupId) {
                return CheckboxListTile(
                  title: Text(
                    'Afficheur ${groupId['name']}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  value: selectedDisplayGroupIds.contains(groupId['id']),
                  autofocus: false,
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  selected: selectedDisplayGroupIds.contains(groupId['id']),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        selectedDisplayGroupIds.add(groupId['id']);
                      } else {
                        selectedDisplayGroupIds.remove(groupId['id']);
                      }
                      _isChecked = value;
                      print('After update: $selectedDisplayGroupIds');
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Expanded(
          child: TextField(
            controller: fromDtController,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              labelText: 'Date de début (YYYY-MM-DD)',
              labelStyle: TextStyle(color: Colors.black, fontSize: 12.0),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                );
                if (picked != null) {
                  setState(() {
                    fromDtController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
              label: Text(''),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    String minutes = picked.minute.toString().padLeft(2, '0');
                    fromDtController.text += ' ${picked.hour}:$minutes:00';
                  });
                }
              },
              icon: Icon(Icons.access_time),
              label: Text(''),
            ),
          ],
        ),
        TextField(
          controller: toDtController,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
              labelText: 'Date de fin (YYYY-MM-DD HH:MM:SS)',
              labelStyle: TextStyle(color: Colors.black, fontSize: 12.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                );
                if (picked != null) {
                  setState(() {
                    toDtController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
              label: Text(''),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    String minutes = picked.minute.toString().padLeft(2, '0');
                    toDtController.text += ' ${picked.hour}:$minutes:00';
                  });
                }
              },
              icon: Icon(Icons.access_time),
              label: Text(''),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            String fromDt = fromDtController.text;
            String toDt = toDtController.text;

            if (selectedDisplayGroupIds.isNotEmpty) {
              playlistController
                  .scheduleEvent(
                      widget.campaignId, selectedDisplayGroupIds, fromDt, toDt)
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event scheduled successfully')),
                );
                Navigator.of(context).pop();
              }).catchError((error) {
                print(
                    'Erreur lors de la planification de l\'événement: $error');
              });
            } else {
              print('Veuillez sélectionner au moins un groupe d\'affichage.');
            }
          },
          child: Text(
            'Planifier',
          ),
        ),
      ],
    );
  }
}
