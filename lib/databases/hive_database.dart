import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String boxName = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(boxName);
  }

  static Box get notesBox => Hive.box(boxName);
}
