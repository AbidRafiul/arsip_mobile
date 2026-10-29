import 'package:flutter/material.dart';
import '../models/unified_approval_model.dart';
import '../services/approval_unified_service.dart';

class UnifiedApprovalProvider with ChangeNotifier {
  final ApprovalUnifiedService _service = ApprovalUnifiedService();

  ApprovalCategory? _selectedCategory;
  List<UnifiedApprovalItem> _approvalItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';

  ApprovalCategory? get selectedCategory => _selectedCategory;
  List<UnifiedApprovalItem> get approvalItems => _approvalItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchKeyword => _searchKeyword;

  void setSelectedCategory(ApprovalCategory? category) {
    _selectedCategory = category;
    fetchApprovals();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    fetchApprovals();
  }

  Future<void> fetchApprovals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _approvalItems = await _service.getApprovalList(
        category: _selectedCategory,
        keyword: _searchKeyword,
      );
    } catch (e) {
      _errorMessage = 'Gagal mengambil data persetujuan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveItem(UnifiedApprovalItem item, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.approveItem(item, notes: notes);
      if (success) {
        await fetchApprovals();
        return true;
      }
    } catch (e) {
      if (e.runtimeType.toString() == 'DioException') {
        final dynamic responseData = (e as dynamic).response?.data;
        if (responseData != null && responseData['message'] != null) {
          _errorMessage = responseData['message'].toString();
        } else {
          _errorMessage = e.toString();
        }
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> rejectItem(UnifiedApprovalItem item, {required String notes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.rejectItem(item, notes: notes);
      if (success) {
        await fetchApprovals();
        return true;
      }
    } catch (e) {
      if (e.runtimeType.toString() == 'DioException') {
        final dynamic responseData = (e as dynamic).response?.data;
        if (responseData != null && responseData['message'] != null) {
          _errorMessage = responseData['message'].toString();
        } else {
          _errorMessage = e.toString();
        }
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
