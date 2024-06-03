import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/planificationController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';
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
  final PlaylistController playlistController = Get.put(PlaylistController());

  List<String> _displayItems = [];
  String? _selectedDisplay;
  DateTime? _selectedDate;
  List<dynamic> _selectedEvents = [];
  List<Appointment> _allAppointments = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    planificationController.fetchScheduleEvent();
    planificationController.getPlaylist();
    playlistController.getPlaylist();
    playerController.fetchData();
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

      _allAppointments = events.map((event) {
        return Appointment(
          startTime: event['start_time'],
          endTime: event['end_time'],
          location: event['CampaignID'],
          color: kSecondaryColor,
          notes: event['DisplayGroupID'],
        );
      }).toList();

      setState(() {
        _displayItems = [
          'Tout',
          'Groupes',
          ...groupDisplayNames,
          'Afficheurs',
          ...playerDisplayNames
        ];
        planificationController.appointmentsDataSource =
            AppointmentDataSource(_allAppointments);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String? getPlayerName(int displayGroupId) {
    var player = playerController.playerList.firstWhere(
      (player) => player.displayGroupId == displayGroupId,
      orElse: () => Player(displayGroupId: 0, display: 'Unknown'),
    );
    return player.display;
  }

  String getPlaylistName(int playlistId) {
    var playlist = playlistController.playlistList.firstWhere(
      (playlist) => playlist.campaignId == playlistId,
      orElse: () => Playlist(
        layoutId: 0,
        campaignId: 0,
        layout: 'Unknown',
        status: '',
        duration: '',
        owner: '',
        playlistId: 0,
        regions: [],
      ),
    );
    print('Playlist ID: $playlistId');
    print('Playlist Name: ${playlist.layout}');
    return playlist.layout;
  }

  void filterEvents() {
    List<Appointment> filteredAppointments;
    if (_selectedDisplay == 'Tout' ||
        _selectedDisplay == 'Groupes' ||
        _selectedDisplay == 'Afficheurs' ||
        _selectedDisplay == null) {
      filteredAppointments = _allAppointments;
    } else {
      filteredAppointments = _allAppointments.where((appointment) {
        if (_displayItems.indexOf(_selectedDisplay!) >
            _displayItems.indexOf('Afficheurs')) {
          // It's a player
          return getPlayerName(int.tryParse(appointment.notes ?? '') ?? 0) ==
              _selectedDisplay;
        } else {
          // It's a group
          return appointment.notes == _selectedDisplay;
        }
      }).toList();
    }

    planificationController.appointmentsDataSource =
        AppointmentDataSource(filteredAppointments);
    setState(() {
      _selectedEvents = filteredAppointments
          .where(
              (appointment) => appointment.startTime!.day == _selectedDate?.day)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Planification',
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
                    filterEvents();
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
                    allowedViews: <CalendarView>[
                      CalendarView.day,
                      CalendarView.week,
                      CalendarView.workWeek,
                      CalendarView.month,
                      CalendarView.schedule
                    ],
                    dataSource: planificationController.appointmentsDataSource,
                    firstDayOfWeek: 1,
                    todayHighlightColor: kSecondaryColor,
                    selectionDecoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.5),
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
                  int playlistId = int.tryParse(event.location ?? '') ?? 0;
                  String playlistName = getPlaylistName(playlistId);
                  int displayGroupId = int.tryParse(event.notes ?? '') ?? 0;

                  String? playerName = getPlayerName(displayGroupId);
                  print('Event: $event');
                  print('Playlist Name: $playlistName');
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
                            '[${DateFormat('HH:mm').format(_selectedEvents[index].startTime!.add(Duration(hours: 1)))} - ${DateFormat('HH:mm').format(_selectedEvents[index].endTime!.add(Duration(hours: 1)))}] $playlistName planifié sur $playerName ',
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
