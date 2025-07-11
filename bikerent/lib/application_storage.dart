import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ApplicationStorage {
  static final ApplicationStorage _instance = ApplicationStorage._internal();
  factory ApplicationStorage() => _instance;
  ApplicationStorage._internal();

  File? _applicationFile;

  Future<File> get _file async {
    if (_applicationFile != null) return _applicationFile!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/applications.json');
    if (!await file.exists()) {
      try {
        final data = await rootBundle.loadString('assets/applications.json');
        await file.writeAsString(data);
      } catch (e) {
        await file.writeAsString('[]');
      }
    }
    _applicationFile = file;
    return file;
  }

  Future<List<Map<String, dynamic>>> getApplications() async {
    final file = await _file;
    final data = await file.readAsString();
    final List<dynamic> applications = jsonDecode(data);
    return applications.cast<Map<String, dynamic>>();
  }

  Future<void> saveApplications(List<Map<String, dynamic>> applications) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(applications));
  }

  Future<String> insertApplication(Map<String, dynamic> application) async {
    final applications = await getApplications();
    final newId = 'APP-${(applications.length + 1).toString().padLeft(3, '0')}';
    final newApplication = {
      'id': newId,
      'user_email': application['userEmail'],
      'bike_id': application['bikeId'],
      'status': 'pending',
      'application_date': DateTime.now().toIso8601String(),
      'form_data': application['formData'] != null ? jsonDecode(application['formData']) : {},
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String()
    };
    applications.add(newApplication);
    await saveApplications(applications);
    return newId;
  }
} 