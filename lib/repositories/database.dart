import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('BaggageEvents')
class BaggageEvente extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get baggageId => string()();

  IntColumn get type => integer()
      .withDefault(const Constant(1))
      .check(priority.isBetweenValues(1, 5))();
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
