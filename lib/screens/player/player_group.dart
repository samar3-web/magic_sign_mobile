import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';

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

  @override
  void initState() {
    super.initState();
    fetchDisplayGroups();
  }

  Future<void> fetchDisplayGroups() async {
    List<DisplayGroup> groups = await playerController.fetchDisplayGroup();
    setState(() {
      displayGroups = groups;
    });
  }

  Future<void> addDisplayGroup(String displayGroup, int isDynamic) async {
    await playerController.addDisplayGroup(
        displayGroup: displayGroup, isDynamic: isDynamic);
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
                        } else {
                        }
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
                      // Handle Option 1
                    } else if (value == 'Option 2') {
                      // Handle Option 2
                    } else if (value == 'Option 3') {
                      // Handle Option 3
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
