
import 'package:sqflite/sqflite.dart';
import 'package:uguisu/api/niconico/nicolive/nicolive.dart';
import 'package:uguisu/api/uguisu_database/nicolive_database.dart';

class UguisuSqliteDatabase
  with
    UguisuNicoliveProgramRespository,
    UguisuNicoliveScheduleRespository,
    UguisuNicoliveStatisticsRespository,
    UguisuNicoliveProgramChatMessageRespository
{
  late final Database db;

  static Future<UguisuSqliteDatabase> openUguisuDatabase({required String databasePath}) async {
    final migrations = <int, List<String>>{
      1: [
        '''
          CREATE TABLE nicolive_programs (
            id INTEGER PRIMARY KEY,
            service_id TEXT NOT NULL,
            program_id TEXT NOT NULL,
            title TEXT NOT NULL,
            web_socket_url TEXT,
            fetched_at TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc')),
            updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc')),
            UNIQUE(service_id, program_id)
          )
        ''',
        '''
          CREATE TRIGGER trigger_nicolive_programs_updated_at AFTER UPDATE ON nicolive_programs
          BEGIN
            UPDATE nicolive_programs SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc') WHERE rowid == NEW.rowid;
          END
        ''',
        '''
          CREATE TABLE nicolive_rooms (
            id INTEGER PRIMARY KEY,
            service_id TEXT NOT NULL,
            program_id TEXT NOT NULL,
            thread TEXT NOT NULL,
            name TEXT NOT NULL,
            fetched_at TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            updated_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            UNIQUE(service_id, program_id, thread),
            FOREIGN KEY (program_id) REFERENCES nicolive_programs (program_id) ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''',
        '''
          CREATE TRIGGER trigger_nicolive_rooms_updated_at AFTER UPDATE ON nicolive_rooms
          BEGIN
            UPDATE nicolive_rooms SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc') WHERE rowid == NEW.rowid;
          END
        ''',
        '''
          CREATE TABLE nicolive_statistics (
            id INTEGER PRIMARY KEY,
            service_id TEXT NOT NULL,
            program_id TEXT NOT NULL,
            thread TEXT NOT NULL,
            name TEXT NOT NULL,
            fetched_at TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            updated_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            FOREIGN KEY (program_id) REFERENCES nicolive_programs (program_id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (program_id, thread) REFERENCES nicolive_rooms (program_id, thread) ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''',
        '''
          CREATE INDEX nicolive_statistics_service_id_program_id_index ON nicolive_statistics(service_id, program_id)
        ''',
        '''
          CREATE INDEX nicolive_statistics_service_id_program_id_thread_index ON nicolive_statistics(service_id, program_id, thread)
        ''',
        '''
          CREATE TRIGGER trigger_nicolive_statistics_updated_at AFTER UPDATE ON nicolive_statistics
          BEGIN
            UPDATE nicolive_statistics SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc') WHERE rowid == NEW.rowid;
          END
        ''',
        '''
          CREATE TABLE nicolive_schedules (
            id INTEGER PRIMARY KEY,
            service_id TEXT NOT NULL,
            program_id TEXT NOT NULL,
            thread TEXT NOT NULL,
            name TEXT NOT NULL,
            fetched_at TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            updated_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            UNIQUE(service_id, program_id, thread),
            FOREIGN KEY (program_id) REFERENCES nicolive_programs (program_id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (program_id, thread) REFERENCES nicolive_rooms (program_id, thread) ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''',
        '''
          CREATE TRIGGER trigger_nicolive_schedules_updated_at AFTER UPDATE ON nicolive_schedules
          BEGIN
            UPDATE nicolive_schedules SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc') WHERE rowid == NEW.rowid;
          END
        ''',
        '''
          CREATE TABLE nicolive_chat_messages (
            id INTEGER PRIMARY KEY,
            service_id TEXT NOT NULL,
            program_id TEXT NOT NULL,
            thread TEXT NOT NULL,
            no INTEGER NOT NULL,
            content TEXT NOT NULL,
            user_id TEXT NOT NULL,
            mail TEXT,
            anonymity INTEGER,
            premium INTEGER,
            date INTEGER NOT NULL,
            date_usec INTEGER NOT NULL,
            vpos INTEGER NOT NULL,
            fetched_at TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            updated_at TEXT NOT NULL DEFAULT (DATETIME('now', 'utc')),
            UNIQUE(service_id, program_id, thread, no),
            FOREIGN KEY (program_id) REFERENCES nicolive_programs (program_id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (program_id, thread) REFERENCES nicolive_rooms (program_id, thread) ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''',
        '''
          CREATE TRIGGER trigger_nicolive_chat_messages_updated_at AFTER UPDATE ON nicolive_chat_messages
          BEGIN
            UPDATE nicolive_chat_messages SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now', 'utc') WHERE rowid == NEW.rowid;
          END
        ''',
      ],
    };

    final db = await openDatabase(
      databasePath,
      version: 1,
      onConfigure: (db) async {
        // Enable foreign key support
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        for (var nextVersion=1; nextVersion<=version; nextVersion++) {
          for (final migration in migrations[nextVersion] ?? <String>[]) {
            await db.execute(migration);
          }
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var nextVersion=oldVersion+1; nextVersion<=newVersion; nextVersion++) {
          for (final migration in migrations[nextVersion] ?? <String>[]) {
            await db.execute(migration);
          }
        }
      },
    );

    return UguisuSqliteDatabase(db: db);
  }

  UguisuSqliteDatabase({required this.db});

  // Program
  @override
  Future<List<UguisuNicoliveProgram>> loadAllNicolivePrograms({required serviceId}) async {
    List<UguisuNicoliveProgram> ret = [];

    for (final row in await db.query(
      'nicolive_programs',
      columns: [
        'program_id',
        'title',
        'web_socket_url',
        'fetched_at',
      ],
      where: 'service_id=?',
      whereArgs: [serviceId],
    )) {
      ret.add(UguisuNicoliveProgram(
        serviceId: serviceId,
        programId: row['program_id'] as String,
        title: row['title'] as String,
        webSocketUrl: row['web_socket_url'] as String,
        fetchedAt: DateTime.parse(row['fetched_at'] as String),
      ));
    }

    return ret;
  }

  @override
  Future<UguisuNicoliveProgram?> loadNicoliveProgramById({required serviceId, required programId}) async {
    for (final row in await db.query(
      'nicolive_programs',
      columns: [
        'title',
        'web_socket_url',
        'fetched_at',
      ],
      where: 'service_id=? AND program_id=?',
      whereArgs: [serviceId, programId],
      limit: 1,
    )) {
      return UguisuNicoliveProgram(
        serviceId: serviceId,
        programId: programId,
        title: row['title'] as String,
        webSocketUrl: row['web_socket_url'] as String,
        fetchedAt: DateTime.parse(row['fetched_at'] as String),
      );
    }

    return null;
  }

  @override
  Future<void> upsertNicoliveProgram({required UguisuNicoliveProgram nicoliveProgram}) async {
    await db.insert(
      'table', 
      {
        'service_id': nicoliveProgram.serviceId,
        'program_id': nicoliveProgram.programId,
        'title': nicoliveProgram.title,
        'web_socket_url': nicoliveProgram.webSocketUrl,
        'fetched_at': nicoliveProgram.fetchedAt.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  // Statistics
  @override
  Future<List<UguisuNicoliveStatistics>> loadAllNicoliveStatisticsById({required String serviceId, required String programId}) async {
    // TODO: implement loadAllNicoliveStatisticsById
    throw UnimplementedError();
  }
  
  @override
  Future<UguisuNicoliveStatistics?> loadLatestNicoliveStatisticsById({required String serviceId, required String programId}) async {
    // TODO: implement loadLatestNicoliveStatisticsById
    throw UnimplementedError();
  }


  // Schedule
  @override
  Future<UguisuNicoliveSchedule?> loadNicoliveScheduleById({required String serviceId, required String programId}) async {
    // TODO: implement loadNicoliveScheduleById
    throw UnimplementedError();
  }
  
  @override
  Future<void> upsertNicoliveSchedule({required UguisuNicoliveSchedule nicoliveSchedule}) async {
    // TODO: implement upsertNicoliveSchedule
    throw UnimplementedError();
  }
  
  @override
  Future<void> upsertNicoliveStatistics({required UguisuNicoliveStatistics nicoliveStatistics}) async {
    // TODO: implement upsertNicoliveStatistics
    throw UnimplementedError();
  }


  // Chat messages
  @override
  Future<List<UguisuNicoliveChatMessage>> loadAllNicoliveChatMessages({required String serviceId, required String programId, required String threadId}) async {
    List<UguisuNicoliveChatMessage> ret = [];

    for (final row in await db.query(
      'nicolive_chat_messages',
      columns: [
        'no',
        'content',
        'user_id',
        'mail',
        'anonymity',
        'premium',
        'date',
        'date_usec',
        'vpos',
        'fetched_at',
      ],
      where: 'service_id=? AND program_id=? AND thread=?',
      whereArgs: [serviceId, programId, threadId],
    )) {
      ret.add(UguisuNicoliveChatMessage(
        serviceId: serviceId,
        programId: programId,
        threadId: threadId,
        no: row['no'] as int,
        userId: row['user_id'] as String,
        content: row['content'] as String,
        date: row['date'] as int,
        dateUsec: row['date_usec'] as int,
        vpos: row['vpos'] as int,
        fetchedAt: DateTime.parse(row['fetched_at'] as String),
      ));
    }

    return ret;
  }

  @override
  Future<UguisuNicoliveChatMessage> loadNicoliveChatMessageByNo({required String serviceId, required String programId, required String threadId, required String no}) async {
    // TODO: implement loadNicoliveChatMessageByNo
    throw UnimplementedError();
  }

  @override
  Future<void> upsertAllNicoliveChatMessages({required String serviceId, required String programId, required List<UguisuNicoliveChatMessage> nicoliveChatMessages}) async {
    // TODO: implement upsertAllNicoliveChatMessages
    throw UnimplementedError();
  }

  @override
  Future<void> upsertNicoliveChatMessage({required String serviceId, required String programId, required UguisuNicoliveChatMessage nicoliveChatMessage}) async {
    // TODO: implement upsertNicoliveChatMessage
    throw UnimplementedError();
  }
}
