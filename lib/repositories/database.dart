import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('BaggageEvents')
class BaggageEvente extends Table {
  TextColumn get id => text()();

  TextColumn get baggageId => text()();

  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [BaggageEvente])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'baggageevents'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // v2: se agregó la clave primaria (id). La tabla es solo caché de
        // Firestore, así que se recrea sin perder datos reales.
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.drop(baggageEvente);
            await m.createTable(baggageEvente);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

final db = AppDatabase(); // aqui esta el appdatabase
