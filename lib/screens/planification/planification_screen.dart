import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
    // Récupérer les événements depuis le contrôleur
    List<dynamic> events = await planificationController.fetchScheduleEvents([3], '2024-04-19 00:15:00');

    // Convertir les événements en format utilisable pour le calendrier
    List<Appointment> appointments = events.map((event) {
      return Appointment(
        startTime: DateTime.parse(event['start_time']),
        endTime: DateTime.parse(event['end_time']),
        subject: event['subject'],
        color: Colors.blue, // Couleur de l'événement (peut être personnalisée)
      );
    }).toList();

    // Mettre à jour la source de données du calendrier avec les nouveaux événements
    setState(() {
      planificationController.appointmentsDataSource = AppointmentDataSource(appointments);
    });

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
                    dataSource: planificationController.appointmentsDataSource,
                    firstDayOfWeek: 1,
                    todayHighlightColor: kSecondaryColor,
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: kSecondaryColor),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4)),
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
