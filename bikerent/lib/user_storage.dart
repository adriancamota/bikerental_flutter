import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UserStorage {
  static final UserStorage _instance = UserStorage._internal();
  factory UserStorage() => _instance;
  UserStorage._internal();

  File? _userFile;

  Future<File> get _file async {
    if (_userFile != null) return _userFile!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/users.json');
    if (!await file.exists()) {
      // Copy from assets on first run
      final data = await rootBundle.loadString('assets/users.json');
      await file.writeAsString(data);
    }
    _userFile = file;
    return file;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final file = await _file;
    final data = await file.readAsString();
    final List<dynamic> users = jsonDecode(data);
    return users.cast<Map<String, dynamic>>();
  }

  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(users));
  }

  Future<Map<String, dynamic>?> authenticate(String email, String password) async {
    final users = await getUsers();
    final user = users.firstWhere(
      (u) => u['email'] == email,
      orElse: () => <String, dynamic>{},
    );
    if (user.isNotEmpty && user['password'] == password) {
      return user;
    }
    return null;
  }

  Future<bool> emailExists(String email) async {
    final users = await getUsers();
    return users.any((u) => u['email'] == email);
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }
} 