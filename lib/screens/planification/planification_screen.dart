import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/planificationController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PlanificationScreen extends StatefulWidget {
  const PlanificationScreen({Key? key}) : super(key: key);
  static const String routeName = 'PlanificationScreen';
  @override
  State<PlanificationScreen> createState() => _PlanificationScreenState();
}

class _PlanificationScreenState extends State<PlanificationScreen> {
  final PlanificationController planificationController =
      Get.put(PlanificationController());
  final PlayerController playerController = Get.put(PlayerController());

  List<String> _displayItems = [];
  String? _selectedDisplay;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<Player> players = await playerController.fetchPlayers();
      List<DisplayGroup> displayGroups =
          await playerController.fetchDisplayGroup();

      List<String> playerDisplayNames =
          players.map((player) => player.display!).toList();
      List<String> groupDisplayNames =
          displayGroups.map((group) => group.displayGroup!).toList();

      setState(() {
        _displayItems = [
          'Groupes',
          ...groupDisplayNames,
          'Afficheurs',
          ...playerDisplayNames
        ];
      });

      List<dynamic> events = await planificationController
          .fetchScheduleEvents([3], '2024-04-19 00:15:00');
      planificationController.fetchScheduleEvent();
      print('Fetched events: $events');
      print('Number of events: ${events.length}');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planification'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kSecondaryColor, width: 2),
                color: Colors.white,
              ),
              child: PopupMenuButton<String>(
                child: Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDisplay ?? "Sélectionner l'afficheur "),
                      Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                    ],
                  ),
                ),
                onSelected: (String value) {
                  setState(() {
                    _selectedDisplay = value;
                  });
                },
                itemBuilder: (BuildContext context) =>
                    _displayItems.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: (choice == "Groupes" || choice == "Afficheurs")
                            ? kSecondaryColor
                            : Colors.transparent,
                      ),
                      child: Text(choice),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SfCalendar(
                    view: CalendarView.month,
                    dataSource: AppointmentDataSource([]),
                    firstDayOfWeek: 1,
                    todayHighlightColor: kSecondaryColor,
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: kSecondaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      shape: BoxShape.rectangle,
                    ),
                    showNavigationArrow: false,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              height: double.infinity,
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  return ListTile(
                      // Title could be customized if needed
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Define a method to create the list of appointments
  List<Appointment> _getAppointments() {
    List<Appointment> appointments = <Appointment>[];

    // Add sample appointments for demonstration
    appointments.add(Appointment(
      startTime: DateTime.now().subtract(Duration(days: 1)),
      endTime:
          DateTime.now().subtract(Duration(days: 1)).add(Duration(hours: 1)),
      subject: 'Sample Event 1',
      color: Colors.blue, // You can customize the color of the event
    ));
    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 2)),
      subject: 'Sample Event 2',
      color: Colors.green, // You can customize the color of the event
    ));
    // Add more appointments as needed...

    // Return the list of appointments
    return appointments;
  }
}

class AppointmentDataSource extends CalendarDataSource {
  // Define a constructor to initialize the appointments list
  AppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }

  // Override the appointments getter to return the list of appointments
  @override
  List get appointments => super.appointments!;

  // Override the add method to add new appointments to the list
  @override
  void add(Appointment appointment) {
    appointments.add(appointment);
  }

  // Override the clear method to remove all appointments from the list
  @override
  void clear() {
    appointments.clear();
  }
  // Add more methods as needed to manipulate the appointments data
}
