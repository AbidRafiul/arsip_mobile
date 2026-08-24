import 'package:flutter/material.dart';
import '../models/multi_dashboard_model.dart';
import '../services/multi_dashboard_service.dart';

class MultiDashboardProvider with ChangeNotifier {
  final MultiDashboardService _service = MultiDashboardService();

  int _selectedModuleIndex = 0; // 0: Executive, 1: Korespondensi, 2: Arsip, 3: Buku Tamu
  bool _isLoading = false;
  String? _errorMessage;

  ExecutiveDashboardStats _executiveStats = ExecutiveDashboardStats();
  CorrespondenceDashboardStats _correspondenceStats = CorrespondenceDashboardStats();
  ArsipDashboardStats _arsipStats = ArsipDashboardStats();
  BukuTamuDashboardStats _bukuTamuStats = BukuTamuDashboardStats();

  int get selectedModuleIndex => _selectedModuleIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ExecutiveDashboardStats get executiveStats => _executiveStats;
  CorrespondenceDashboardStats get correspondenceStats => _correspondenceStats;
  ArsipDashboardStats get arsipStats => _arsipStats;
  BukuTamuDashboardStats get bukuTamuStats => _bukuTamuStats;

  void setSelectedModuleIndex(int index) {
    _selectedModuleIndex = index;
    notifyListeners();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedModuleIndex == 0) {
        _executiveStats = await _service.getExecutiveStats();
      } else if (_selectedModuleIndex == 1) {
        _correspondenceStats = await _service.getCorrespondenceStats();
      } else if (_selectedModuleIndex == 2) {
        _arsipStats = await _service.getArsipStats();
      } else if (_selectedModuleIndex == 3) {
        _bukuTamuStats = await _service.getBukuTamuStats();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat statistik dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _executiveStats = await _service.getExecutiveStats();
      _correspondenceStats = await _service.getCorrespondenceStats();
      _arsipStats = await _service.getArsipStats();
      _bukuTamuStats = await _service.getBukuTamuStats();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
