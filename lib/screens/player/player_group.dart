import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  List<DisplayGroup> displayGroups =
      []; // Liste pour stocker les groupes d'afficheurs

  @override
  void initState() {
    super.initState();
    fetchDisplayGroups(); // Appel de la méthode pour récupérer les données des groupes d'afficheurs
  }

  // Méthode pour récupérer les données des groupes d'afficheurs
  Future<void> fetchDisplayGroups() async {
    List<DisplayGroup> groups = await playerController.fetchDisplayGroup();
    setState(() {
      displayGroups = groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groupes d\'afficheurs'),
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
                    SizedBox(
                        width: 8.0), // Espacement entre le texte et l'icône
                    group.isDynamic == 1
                        ? Icon(Icons.check_circle,
                            color: Colors
                                .green) // Icône valide si isDynamic est vrai
                        : Icon(Icons.cancel,
                            color: Colors
                                .red), // Icône invalide si isDynamic est faux
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
                      child: Text('Supprimer '),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Option 4',
                      child: Text('Mise en page par défaut '),
                    ),
                  ],
                  onSelected: (String value) async {
                    if (value == 'Option 1') {
                    } else if (value == 'Option 2') {
                    } else if (value == 'Option 3') {
                    } else if (value == 'Option 4') {}
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
