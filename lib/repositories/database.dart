import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('BaggageEventRow')
class BaggageEvents extends Table {
  TextColumn get id => text()();

  TextColumn get baggageId => text()();

  TextColumn get type => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [BaggageEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'baggageevents'));

  @override
  int get schemaVersion => 1;
}

final db = AppDatabase(); // aqui esta el appdatabase
