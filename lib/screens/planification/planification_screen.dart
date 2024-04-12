import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PlanificationScreen extends StatefulWidget {
  const PlanificationScreen({Key? key}) : super(key: key);

  static const String routeName = 'PlanificationScreen';

  @override
  State<PlanificationScreen> createState() => _PlanificationScreenState();
}

class _PlanificationScreenState extends State<PlanificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planification'),
      ),
       body: Center(
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: AppointmentDataSource([]),
        ),
       ),
    );
  }

  // Define a method to create the list of appointments
  List<Appointment> _getAppointments() {
    List<Appointment> appointments = <Appointment>[];

    // Add sample appointments for demonstration
    appointments.add(Appointment(
      startTime: DateTime.now().subtract(Duration(days: 1)),
      endTime: DateTime.now().subtract(Duration(days: 1)).add(Duration(hours: 1)),
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