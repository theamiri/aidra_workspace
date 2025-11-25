import 'package:hive/hive.dart';

class HiveClient<T> {
  final String boxName;
  Box<T>? _box;

  HiveClient(this.boxName);

  /// Initialize and open the hive box if not already open.
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<T>(boxName);
    } else {
      _box = Hive.box<T>(boxName);
    }
  }

  /// Get the box if it's open, otherwise initialize and open it.
  Future<Box<T>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  /// Put a value into the box with a specific key.
  Future<void> put(String key, T value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  /// Add a list of values to the box.
  Future<void> addAll(List<T> values) async {
    final box = await _getBox();
    for (var value in values) {
      await box.add(value);
    }
  }

  /// Get a value from the box by key.
  Future<T?> get(String key) async {
    final box = await _getBox();
    return box.get(key);
  }

  /// Get all values from the box.
  Future<List<T>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// Delete a value from the box by key.
  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  /// Clear all values in the box.
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Check if a key exists in the box.
  Future<bool> containsKey(String key) async {
    final box = await _getBox();
    return box.containsKey(key);
  }

  /// Close the box if it's open.
  Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
