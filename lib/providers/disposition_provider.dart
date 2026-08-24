import 'package:flutter/material.dart';
import '../models/disposition_model.dart';
import '../services/disposition_service.dart';

class DispositionProvider extends ChangeNotifier {
  final DispositionService _dispositionService = DispositionService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  List<DispositionItemModel> _dispositionList = [];
  List<DispositionItemModel> get dispositionList => _dispositionList;

  String _selectedStatusFilter = '';
  String get selectedStatusFilter => _selectedStatusFilter;

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    fetchDispositionList();
  }

  Future<void> fetchDispositionList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _dispositionService.getDispositionList(
        status: _selectedStatusFilter.isEmpty ? null : _selectedStatusFilter,
      );
      _dispositionList = list;
    } catch (e) {
      debugPrint("Fetch disposition list error: $e");
      _dispositionList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processDisposition(int disposisiSuratId, {String? catatan}) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final res = await _dispositionService.processDisposition(disposisiSuratId, catatan: catatan);
      if (res) {
        await fetchDispositionList();
      }
      return res;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeDisposition(int disposisiSuratId, {String? catatan}) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final res = await _dispositionService.completeDisposition(disposisiSuratId, catatan: catatan);
      if (res) {
        await fetchDispositionList();
      }
      return res;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
