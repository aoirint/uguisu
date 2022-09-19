import 'package:drift/drift.dart';

part 'uguisu_models.g.dart';

class NicolivePrograms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get webSocketUrl => text()();
}
