import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';

class PlayerGroup extends StatefulWidget {
  const PlayerGroup({Key? key}) : super(key: key);

  static const String routeName = 'PlayerGroup';

  @override
  _PlayerGroupState createState() => _PlayerGroupState();
}

class _PlayerGroupState extends State<PlayerGroup> {
  final PlayerController playerController = Get.put(PlayerController());
  bool _isChecked = false;
  List<int> selectedDynamic = [];
  List<DisplayGroup> displayGroups = [];
  List<Player> availableDisplays = [];

  @override
  void initState() {
    super.initState();
    fetchDisplayGroups();
    fetchAvailableDisplays();
  }

  Future<void> fetchDisplayGroups() async {
    List<DisplayGroup> groups = await playerController.fetchDisplayGroup();
    setState(() {
      displayGroups = groups;
    });
  }

  Future<void> fetchAvailableDisplays() async {
    List<Player> displays = await playerController.fetchPlayers();
    setState(() {
      availableDisplays = displays;
    });
  }

  Future<void> addDisplayGroup(String displayGroup, int isDynamic) async {
    await playerController.addDisplayGroup(
        displayGroup: displayGroup, isDynamic: isDynamic);
    fetchDisplayGroups();
  }

  Future<void> addMemberToGroup(int displayGroupId, int displayId) async {
    await playerController.AddMember(displayGroupId, displayId);
    // Optionally refresh the display groups
    fetchDisplayGroups();
  }

  void showAddGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool isDynamic = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ajouter un groupe d\'affichage',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                  labelText: 'Nom du groupe',
                  labelStyle: TextStyle(color: kSecondaryColor, fontSize: 14.0),
                ),
              ),
              Row(
                children: [
                  Text('Est dynamique'),
                  Checkbox(
                    autofocus: false,
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    value: isDynamic,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          isDynamic = value;
                        } else {}
                        _isChecked = value;
                        print('After update: $value');
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                addDisplayGroup(nameController.text, isDynamic ? 1 : 0);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDeleteDialog(
      int displayGroupId, String displayGroup) async {
    bool deleteConfirmed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer "$displayGroup"'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Êtes-vous sûr de vouloir supprimer ce groupe d\'afficheurs ?'),
              SizedBox(height: 8),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteConfirmed = true;
                Navigator.of(context).pop();
              },
              child: Text('Oui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Non'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      await playerController.deleteGroup(displayGroupId).then((_) {
        fetchDisplayGroups();
      });
    }
  }

  void showAddMemberDialog(BuildContext context, int displayGroupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ajouter des membres au groupe',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableDisplays.length,
              itemBuilder: (context, index) {
                Player display = availableDisplays[index];
                return CheckboxListTile(
                  title: Text(display.display!),
                  value: selectedDynamic.contains(display.displayGroupId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedDynamic.add(display.displayGroupId!);
                      } else {
                        selectedDynamic.remove(display.displayGroupId);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                for (int displayId in selectedDynamic) {
                  addMemberToGroup(displayGroupId, displayId);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groupes d\'afficheurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAddGroupDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: ListView.builder(
          itemCount: displayGroups.length,
          itemBuilder: (context, index) {
            DisplayGroup group = displayGroups[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      group.displayGroup!,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    group.isDynamic == 1
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Option 1',
                      child: Text("Membres"),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Option 2',
                      child: Text('Editer'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Option 3',
                      child: Text('Supprimer'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Option 4',
                      child: Text('Mise en page par défaut'),
                    ),
                  ],
                  onSelected: (String value) async {
                    if (value == 'Option 1') {
                      showAddMemberDialog(context, group.displayGroupId!);
                    } else if (value == 'Option 2') {
                      // Handle Option 2
                    } else if (value == 'Option 3') {
                      _showConfirmDeleteDialog(
                          group.displayGroupId!, group.displayGroup!);
                    } else if (value == 'Option 4') {
                      // Handle Option 4
                    }
                  },
                  child: Icon(Icons.arrow_drop_down),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
