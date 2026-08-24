import 'package:flutter/material.dart';
import '../models/approval_model.dart';
import '../services/approval_service.dart';

class ApprovalProvider extends ChangeNotifier {
  final ApprovalService _approvalService = ApprovalService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  List<ApprovalItemModel> _approvalList = [];
  List<ApprovalItemModel> get approvalList => _approvalList;

  String _selectedStatusFilter = 'menunggu_approval';
  String get selectedStatusFilter => _selectedStatusFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Detail State
  ApprovalItemModel? _currentLetter;
  ApprovalItemModel? get currentLetter => _currentLetter;

  List<FileSuratModel> _currentFiles = [];
  List<FileSuratModel> get currentFiles => _currentFiles;

  List<TrackingItemModel> _currentTrackings = [];
  List<TrackingItemModel> get currentTrackings => _currentTrackings;

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    fetchApprovalList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchApprovalList();
  }

  Future<void> fetchApprovalList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _approvalService.getApprovalList(
        status: _selectedStatusFilter.isEmpty ? null : _selectedStatusFilter,
        keyword: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _approvalList = list;
    } catch (e) {
      debugPrint("Fetch approval list error: $e");
      _approvalList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLetterDetail(int idSuratKeluar) async {
    _isLoading = true;
    _currentLetter = null;
    _currentFiles = [];
    _currentTrackings = [];
    notifyListeners();

    try {
      final detail = await _approvalService.getLetterDetail(idSuratKeluar);
      _currentLetter = detail['surat'];
      _currentFiles = detail['files'] ?? [];
      _currentTrackings = detail['trackings'] ?? [];
    } catch (e) {
      debugPrint("Fetch letter detail error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLetter(int idSuratKeluar, {String? catatan}) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final success = await _approvalService.approveLetter(idSuratKeluar, catatan: catatan);
      if (success) {
        await fetchApprovalList();
      }
      return success;
    } catch (e) {
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectLetter(int idSuratKeluar, {required String catatan}) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final success = await _approvalService.rejectLetter(idSuratKeluar, catatan: catatan);
      if (success) {
        await fetchApprovalList();
      }
      return success;
    } catch (e) {
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
