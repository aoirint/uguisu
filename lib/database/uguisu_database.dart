import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'uguisu_database.g.dart';

class UguisuNicoliveUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceId => text()(); // to distinguish nicolive compatible services (e.g. mock server)
  IntColumn get userId => integer()();
  BoolColumn get anonymity => boolean()();

  TextColumn get nickname => text().nullable()();
  TextColumn get iconUrl => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{serviceId, userId}];
}

class UguisuNicoliveUserIconCaches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get user => integer().references(UguisuNicoliveUsers, #id)();

  TextColumn get contentType => text()();
  TextColumn get path => text()();

  DateTimeColumn get uploadedAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{user}];
}

class UguisuNicoliveCommunities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceId => text()(); // to distinguish nicolive compatible services (e.g. mock server)
  TextColumn get communityId => text()();

  TextColumn get name => text()();
  TextColumn get iconUrl => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{serviceId, communityId}];
}

class UguisuNicoliveCommunityIconCaches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get community => integer().references(UguisuNicoliveCommunities, #id)();

  TextColumn get contentType => text()();
  TextColumn get path => text()();

  DateTimeColumn get uploadedAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{community}];
}

class UguisuNicolivePrograms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceId => text()(); // to distinguish nicolive compatible services (e.g. mock server)
  TextColumn get programId => text()();

  TextColumn get title => text()();
  TextColumn get providerType => text()();
  TextColumn get visualProviderType => text()();
  DateTimeColumn get beginTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get user => integer().references(UguisuNicoliveUsers, #id)();
  IntColumn get community => integer().references(UguisuNicoliveCommunities, #id)();
  TextColumn get webSocketUrl => text()(); // maybe empty string
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{serviceId, programId}];
}

class UguisuNicoliveRooms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get program => integer().references(UguisuNicolivePrograms, #id)();

  TextColumn get thread => text()();
  TextColumn get name => text()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{program, thread}];
}

class UguisuNicoliveComments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get room => integer().references(UguisuNicoliveRooms, #id)();
  IntColumn get user => integer().references(UguisuNicoliveUsers, #id)();
  IntColumn get no => integer()();

  TextColumn get content => text()();
  IntColumn get anonymity => integer().nullable()();
  IntColumn get premium => integer().nullable()();
  TextColumn get mail => text().nullable()();
  DateTimeColumn get postedAt => dateTime()();
  IntColumn get vpos => integer()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{room, no}];
}

@DriftDatabase(
  tables: [
    UguisuNicoliveUsers,
    UguisuNicoliveUserIconCaches,
    UguisuNicoliveCommunities,
    UguisuNicoliveCommunityIconCaches,
    UguisuNicolivePrograms,
    UguisuNicoliveRooms,
    UguisuNicoliveComments,
  ],
)
class UguisuDatabase extends _$UguisuDatabase {
  UguisuDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final file = File(path.join(appSupportDir.path, 'db.sqlite3'));
    return NativeDatabase(file);
  });
}
