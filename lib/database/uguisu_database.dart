import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'uguisu_database.g.dart';

class UguisuNicolivePrograms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceId => text()();
  TextColumn get programId => text()();
  TextColumn get title => text()();
  TextColumn get webSocketUrl => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
}

@DriftDatabase(
  tables: [
    UguisuNicolivePrograms,
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
