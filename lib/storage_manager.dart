import 'dart:developer' as Debug;

import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  const StorageManager._();

  static void init(SharedPreferences sharedPref) {
    _preferences = sharedPref;
    _instance = const StorageManager._();
  }

  factory StorageManager() {
    if (_instance == null) {
      throw Exception(
        "StorageManager not initialized. Call StorageManager.init() first.",
      );
    }
    return _instance!;
  }

  static StorageManager? _instance;
  static StorageManager? get instance => _instance;
  static SharedPreferences? _preferences;
  static const String user = 'user';

  static const String xToken = 'access_token';
  static const String email = 'email';
  static const String productSlug = 'product_slug';
  static const String productName = 'product_name';

  Future<bool> saveStringValue(String key, String value) async {
    try {
      _preferences = await SharedPreferences.getInstance();
      final isSaved = await _preferences!.setString(key, value);
      isSaved ? Debug.log('Saved $key') : Debug.log('Error while saving $key');

      return isSaved;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveIntValue(String key, int value) async {
    _preferences = await SharedPreferences.getInstance();
    final isSaved = await _preferences!.setInt(key, value);
    isSaved ? Debug.log('Saved $key') : Debug.log('Error while saving $key');
    return isSaved;
  }

  Future<bool> saveList(String key, List<String> list) async {
    _preferences = await SharedPreferences.getInstance();
    final isSaved = await _preferences!.setStringList(key, list);
    isSaved ? Debug.log('Saved $key') : Debug.log('Error while saving $key');
    return isSaved;
  }

  Future<bool> saveBoolValue(String key, bool value) async {
    _preferences = await SharedPreferences.getInstance();
    final isSaved = await _preferences!.setBool(key, value);
    isSaved ? Debug.log('Saved $key') : Debug.log('Error while saving $key');
    return isSaved;
  }

  bool? getBoolValue(String key) {
    if (_preferences != null) {
      bool? boolVal = _preferences!.getBool(key);
      if (boolVal == null) {
        return null;
      } else {
        return boolVal;
      }
    } else {
      Debug.log('empty preferneces var');
    }
    return null;
  }

  String? getStringValue(String key) {
    if (_preferences != null) {
      String? stringVal = _preferences!.getString(key);
      if (stringVal == null || stringVal == "") {
        return null;
      } else {
        return stringVal;
      }
    } else {
      Debug.log('empty preferneces var');
    }
    return null;
  }

  int? getIntValue(String key) {
    if (_preferences != null) {
      int? stringVal = _preferences!.getInt(key);
      if (stringVal == null) {
        return null;
      } else {
        return stringVal;
      }
    } else {
      Debug.log('empty preferneces var');
    }
    return null;
  }

  List<String>? getList(String key) {
    if (_preferences != null) {
      List<String>? listVal = _preferences!.getStringList(key);
      if (listVal == null || listVal == []) {
        return null;
      } else {
        return listVal;
      }
    } else {
      Debug.log('empty preferneces var');
    }
    return null;
  }

  Future<bool> clearAllPreferences() async {
    final sharedPreference = await SharedPreferences.getInstance();
    return await sharedPreference.clear();
  }

  Future<bool> clearValueFromPrefs(String key) async {
    if (_preferences != null) {
      return await _preferences!.remove(key);
    }
    return false;
  }
}
