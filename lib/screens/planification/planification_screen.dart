import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/planificationController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:convert';

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
  DateTime? _selectedDate;
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    planificationController.fetchScheduleEvent();
    planificationController.getPlaylist();
  }

  void fetchData() async {
    try {
      List<Map<String, dynamic>> events =
          await planificationController.fetchScheduleEvents();

      List<Player> players = await playerController.fetchPlayers();

      List<DisplayGroup> displayGroups =
          await playerController.fetchDisplayGroup();
      List<String> playerDisplayNames =
          players.map((player) => player.display!).toList();
      List<String> groupDisplayNames =
          displayGroups.map((group) => group.displayGroup!).toList();

      events.forEach((event) {
        print('Event: $event');
      });

      List<Appointment> appointments = events.map((event) {
        return Appointment(
          startTime: event['start_time'],
          endTime: event['end_time'],
          subject: 'Event ${event['CampaignID']}',
          color: kSecondaryColor,
          notes: event['DisplayGroupID'],
        );
      }).toList();

      setState(() {
        _displayItems = [
          'Groupes',
          ...groupDisplayNames,
          'Afficheurs',
          ...playerDisplayNames
        ];
        planificationController.appointmentsDataSource =
            AppointmentDataSource(appointments);
      });

      print('Fetched events: $events');
      print('Number of events: ${events.length}');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String? getPlayerName(int displayGroupId) {
    var player = playerController.playerList.firstWhere(
        (player) => player.displayGroupId == displayGroupId,
        orElse: () => Player(displayGroupId: 0, display: 'Unknown'));
    print(player.display);
    return player.display;
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
            flex: 8,
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
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      shape: BoxShape.rectangle,
                    ),
                    showNavigationArrow: false,
                    onTap: (CalendarTapDetails details) {
                      setState(() {
                        _selectedDate = details.date;
                        _selectedEvents = planificationController
                            .appointmentsDataSource.appointments
                            .where((appointment) =>
                                appointment.startTime!.day ==
                                _selectedDate!.day)
                            .toList();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: SizedBox(
              height: double.infinity,
              child: ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  var event = _selectedEvents[index];
                  int playlistId =
                      int.tryParse(event.subject.split(' ').last) ?? 0;
                  String playlistName =
                      planificationController.getPlaylistName(playlistId);
                  int displayGroupId = int.tryParse(event.notes ?? '') ?? 0;

                  String? playerName = getPlayerName(displayGroupId);

                  print('playlist id $playlistId');
                  print('Player id $displayGroupId');
                  print('Player name $playerName');

                  return ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.display_settings_outlined,
                          color: kSecondaryColor,
                          size: 24.0,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '[${DateFormat('HH:mm').format(_selectedEvents[index].startTime!.add(Duration(hours: 1)))} - ${DateFormat('HH:mm').format(_selectedEvents[index].endTime!)}] $playlistName planifié sur $playerName ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: kSecondaryColor,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
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
  AppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }

  @override
  List get appointments => super.appointments!;

  @override
  void add(Appointment appointment) {
    appointments.add(appointment);
  }

  @override
  void clear() {
    appointments.clear();
  }
}
