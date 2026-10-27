import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('BaggageEvents')
class BaggageEvente extends Table {
  TextColumn get id => text()();

  TextColumn get baggageId => text()();

  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [BaggageEvente])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'baggageevents'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

final db = AppDatabase(); // aqui esta el appdatabase
