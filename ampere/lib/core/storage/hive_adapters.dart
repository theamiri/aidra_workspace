import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class HiveAdapters {
  static Future<void> init() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDirectory.path);
    // ..registerAdapter();
  }
}
