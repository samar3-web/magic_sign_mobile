import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/sqlitedb/database_service.dart';
import 'package:sqflite/sqflite.dart';

class MagicSignDB {
  final afficheurTable = 'afficheur';
  final mediaTable = 'media';
  final eventTable = 'events';
  final playlistTable = 'playlist';
  final layoutTable = 'layoutImages';

  Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $afficheurTable (
  displayId INT,
      display VARCHAR(255),
  clientAddress VARCHAR(255),
  lastAccessed INT,
  loggedIn INT,
  licensed INT,
  defaultLayout VARCHAR(255),
  displayGroupId INT,
  defaultLayoutId INT,
  license VARCHAR(255),
  incSchedule INT,
  emailAlert INT,
  wakeOnLanEnabled INT,
  sync INT,
  PRIMARY KEY (displayId)
  );""");

    await database.execute("""
    CREATE TABLE IF NOT EXISTS $mediaTable (
  mediaId INTEGER PRIMARY KEY,
  ownerId INTEGER,
  name TEXT,
  mediaType TEXT,
  storedAs TEXT,
  duration TEXT,
  owner TEXT,
  retired TEXT,
  createdDt TEXT,
  fileSize TEXT,
  localImagePath TEXT,
  sync INT
);
""");

    database.execute("""
    CREATE TABLE IF NOT EXISTS $eventTable (
  eventID TEXT PRIMARY KEY,
  eventTypeId INTEGER,
  CampaignID TEXT,
  userID TEXT,
  is_priority INTEGER,
  FromDT INTEGER,
  ToDT INTEGER,
  DisplayOrder INTEGER,
  DisplayGroupID TEXT,
  dayPartId INTEGER,
  sync INT
);
    """);

    database.execute("""
      CREATE TABLE IF NOT EXISTS $playlistTable (
  layoutId INTEGER PRIMARY KEY,
  campaignId INTEGER,
  layout TEXT,
  status TEXT,
  duration TEXT,
  owner TEXT,
  playlistId INTEGER,
  regions TEXT,
  createdDt TEXT,
  sync INT
); """);
    database.execute("""
      CREATE TABLE IF NOT EXISTS $layoutTable (

  layoutId INTEGER PRIMARY KEY,
  layout TEXT

); """);
  }

  Future<int> deleteMedia(int id) async {
    final database = await DatabaseService().database;
    return await database.rawDelete('''
    DELETE FROM $mediaTable WHERE mediaId=?''', [id]);
  }

  Future<void> saveMedia(Media media, {String? localImagePath}) async {
  final database = await DatabaseService().database;
  await database.insert(
    mediaTable,
    {
      'mediaId': media.mediaId,
      'name': media.name,
      'mediaType': media.mediaType,
      'storedAs': media.storedAs,
      'localImagePath': localImagePath ?? media.localImagePath,
      'sync': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


  Future<int> createEvent(Map<String, dynamic> event, int sync) async {
    final database = await DatabaseService().database;
    print("event db ${event.toString()}");
    return await database.rawInsert('''
      INSERT OR IGNORE INTO $eventTable (
        eventID,
        eventTypeId,
        CampaignID,
        userID,
        is_priority,
        FromDT,
        ToDT,
        DisplayOrder,
        DisplayGroupID,
        dayPartId,
        sync
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?)
    ''', [
      event['eventID'],
      event['eventTypeId'],
      event['CampaignID'],
      event['userID'],
      event['isPriority'],
      event['FromDT'],
      event['ToDT'],
      event['DisplayOrder'],
      event['DisplayGroupID'],
      event['dayPartId'],
      sync
    ]);
  }

  Future<int> createPlaylist(Playlist playlist, int sync) async {
    final database = await DatabaseService().database;
    return await database.rawInsert('''
     INSERT OR IGNORE INTO $playlistTable (
        campaignId,
        layout,
        status,
        duration,
        owner,
        playlistId,
        createdDt,
        sync
      )
      VALUES (?, ?, ?, ?, ?, ?, ? , ?)
    ''', [
      playlist.campaignId,
      playlist.layout,
      playlist.status,
      playlist.duration,
      playlist.owner,
      playlist.playlistId,
      playlist.createdDt,
      sync
    ]);
  }

  Future<int> createMedia(Media media, int sync) async {
    final database = await DatabaseService().database;
    return await database.rawInsert('''
    INSERT OR IGNORE INTO $mediaTable 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?);
    ''', [
      media.mediaId,
      media.ownerId,
      media.name,
      media.mediaType,
      media.storedAs,
      media.duration,
      media.owner,
      media.retired,
      media.createdDt,
      media.fileSize,
      media.localImagePath,
      sync
    ]);
  }


    Future<List<dynamic>> fetchAllLayouts() async {
    final database = await DatabaseService().database;
    final layouts =
        await database.rawQuery('''SELECT * FROM $layoutTable ; ''');
    return layouts;
  }


Future<int> saveLayout(int id, String image) async {
    final database = await DatabaseService().database;
    return await database.rawInsert('''
     INSERT OR IGNORE INTO $layoutTable 
      VALUES (?, ?)
    ''', [id, image]);
  }


  Future<int> createPlayer(Player player, int sync) async {
    print("insert a player");
    final database = await DatabaseService().database;
    return await database.rawInsert('''INSERT OR IGNORE INTO $afficheurTable 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?); ''', [
      player.displayId,
      player.display,
      player.clientAddress,
      player.lastAccessed,
      player.loggedIn,
      player.licensed,
      player.defaultLayout,
      player.displayGroupId,
      player.defaultLayoutId,
      player.license,
      player.incSchedule,
      player.emailAlert,
      player.wakeOnLanEnabled,
      sync
    ]);
  }

  Future<List<Player>> fetchAllPlayers() async {
    print("fetching the players");
    final database = await DatabaseService().database;
    final players =
        await database.rawQuery('''SELECT * FROM $afficheurTable ; ''');
    return players.map((player) => Player.fromJson(player)).toList();
  }

  Future<List<Player>> SYNCfetchAllPlayers() async {
    final database = await DatabaseService().database;
    final players = await database
        .rawQuery('''SELECT * FROM $afficheurTable  WHERE sync=0; ''');
    return players.map((player) => Player.fromJson(player)).toList();
  }

  Future<List<Playlist>> fetchAllPlaylist() async {
    final database = await DatabaseService().database;
    final playlist =
        await database.rawQuery('''SELECT * FROM $playlistTable ; ''');
    return playlist.map((playlist) => Playlist.fromJson(playlist)).toList();
  }

  Future<List<Playlist>> SYNCfetchAllPlaylist() async {
    final database = await DatabaseService().database;
    final playlist = await database
        .rawQuery('''SELECT * FROM $playlistTable WHERE sync=0 ; ''');
    return playlist.map((playlist) => Playlist.fromJson(playlist)).toList();
  }

  Future<List<Media>> fetchAllMedia() async {
    print("fetching the media");
    final database = await DatabaseService().database;
    final media = await database.rawQuery('''SELECT * FROM $mediaTable ; ''');
    return media.map((media) => Media.fromJson(media)).toList();
  }

  Future<List<Media>> SYNCfetchAllMedia() async {
    final database = await DatabaseService().database;
    final media = await database
        .rawQuery('''SELECT * FROM $mediaTable  WHERE sync=0; ''');
    return media.map((media) => Media.fromJson(media)).toList();
  }

  dynamic fetchScheduleEvent() async {
    print("fetching the media");
    final database = await DatabaseService().database;
    final events = await database.rawQuery('''SELECT * FROM $eventTable ; ''');
    return List<Map<String, dynamic>>.from(events.map((event) {
      return {
        'eventID': event['eventID'],
        'eventTypeId': event['eventTypeId'],
        'CampaignID': event['CampaignID'],
        'userID': event['userID'],
        'is_priority': event['is_priority'],
        'start_time': DateTime.fromMillisecondsSinceEpoch(
            int.parse(event['FromDT'].toString()) * 1000),
        'end_time': DateTime.fromMillisecondsSinceEpoch(
            int.parse(event['ToDT'].toString()) * 1000),
        'DisplayOrder': event['DisplayOrder'],
        'DisplayGroupID': event['DisplayGroupID'],
        'dayPartId': event['dayPartId'],
      };
    }).toList());
  }

  void updateMedia(int mediaId) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''
    UPDATE $mediaTable SET sync = ? WHERE mediaId=?''', [1, mediaId]);
  }
}
