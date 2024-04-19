import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/planificationController.dart';
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
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
  try {
    List<dynamic> events = await planificationController.fetchScheduleEvents([3], '2024-04-19 00:15:00');
    // Handle the fetched events data
    print('Fetched events: $events');
    print('Number of events: ${events.length}');
  } catch (e) {
    // Handle any errors that occurred during the fetch operation
    print('Error fetching schedule events: $e');
  }
}

  String? _selectedItem;
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
            child: DropdownButton<String>(
              value: _selectedItem,
              items: [
                DropdownMenuItem(
                  value: 'Item 1',
                  child: Text('Item 1'),
                ),
                DropdownMenuItem(
                  value: 'Item 2',
                  child: Text('Item 2'),
                ),
                // Add more DropdownMenuItem widgets as needed
              ],
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                });
              },
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
                      //title: Text('Item $index'),
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
