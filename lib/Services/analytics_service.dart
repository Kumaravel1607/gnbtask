import 'dart:convert'; // For JSON encoding
import 'package:flutter/foundation.dart';

class AnalyticsService {
  // Singleton
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Local Storage (Simulation of a database/cache)
  final List<Map<String, dynamic>> _eventBuffer = [];

  // Active Page Timers
  final Map<String, DateTime> _pageEntryTimes = {};

  // --- 1. TRACK INTERACTIONS (Clicks) ---
  void logInteraction({
    required String elementId,
    required String action, // e.g., 'tap', 'scroll', 'filter'
    Map<String, dynamic>? metadata,
  }) {
    final event = {
      'type': 'interaction',
      'element': elementId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    };

    _addToLog(event);
  }

  // --- 2. TRACK PAGE VIEW (Most Viewed) ---
  void logPageView({required String pageName, required String propertyId}) {
    final event = {
      'type': 'page_view',
      'page': pageName,
      'property_id': propertyId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addToLog(event);
  }

  // --- 3. TRACK TIME SPENT (Start) ---
  void startPageTimer(String propertyId) {
    _pageEntryTimes[propertyId] = DateTime.now();
    debugPrint("⏱️ Timer started for Property: $propertyId");
  }

  // --- 3. TRACK TIME SPENT (End) ---
  void endPageTimer(String propertyId) {
    if (_pageEntryTimes.containsKey(propertyId)) {
      final startTime = _pageEntryTimes[propertyId]!;
      final duration = DateTime.now().difference(startTime);
      _pageEntryTimes.remove(propertyId);

      final event = {
        'type': 'time_spent',
        'property_id': propertyId,
        'duration_seconds': duration.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _addToLog(event);
    }
  }

  // --- INTERNAL: Store & Simulate Backend Send ---
  void _addToLog(Map<String, dynamic> event) {
    _eventBuffer.add(event);

    // Console Log Simulation
    if (kDebugMode) {
      print("📊 ANALYTICS LOG: ${json.encode(event)}");
    }

    // In a real app, you would flush this buffer to an API every 60 seconds
    // or when the list reaches 10 items.
    if (_eventBuffer.length >= 5) {
      _simulateBatchUpload();
    }
  }

  void _simulateBatchUpload() {
    print("🚀 [Backend Simulation] Uploading ${_eventBuffer.length} events...");
    // clear buffer after 'upload'
    _eventBuffer.clear();
  }

  // Helper to see all data (call this from UI to debug)
  void printFullReport() {
    print("=== FULL ANALYTICS REPORT ===");
    print(const JsonEncoder.withIndent('  ').convert(_eventBuffer));
  }
}
