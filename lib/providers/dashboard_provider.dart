import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardSummaryModel? _summary;
  DashboardSummaryModel? get summary => _summary;

  List<AuditLogItem> _recentActivities = [];
  List<AuditLogItem> get recentActivities => _recentActivities;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final summaryRes = await _dashboardService.getSummaryStats();
      final activitiesRes = await _dashboardService.getRecentActivities();

      _summary = summaryRes;
      _recentActivities = activitiesRes;
    } catch (e) {
      debugPrint("Dashboard fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
