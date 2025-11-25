import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerController extends GetxController {
  // Reaktif Liste (Değiştiğinde UI otomatik güncellenir)
  var records = <Map<String, dynamic>>[].obs;
  final sugarInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('sugar_records');
    if (data != null) {
      records.value = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  Future<void> addRecord() async {
    if (sugarInputController.text.isEmpty) return;
    final int value = int.tryParse(sugarInputController.text) ?? 0;

    final newRecord = {
      'value': value,
      'date': DateTime.now().toIso8601String(),
    };

    records.add(newRecord);
    // Tarihe göre sırala
    records.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    
    _saveToPrefs();
    sugarInputController.clear();
    Get.focusScope?.unfocus(); // Klavyeyi kapat
  }

  Future<void> clearRecords() async {
    records.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sugar_records');
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sugar_records', json.encode(records));
  }
}