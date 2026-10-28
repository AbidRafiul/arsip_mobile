import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

class BranchProvider with ChangeNotifier {
  final BranchService _service = BranchService();

  List<BranchModel> _branches = [];
  List<BranchModel> get branches => _branches;

  BranchModel? _selectedBranch;
  BranchModel? get selectedBranch => _selectedBranch;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Returns only root-level branches (level 1, no parent)
  List<BranchModel> get rootBranches =>
      _branches.where((b) => b.idInduk == null).toList();

  /// Returns children of a given branch ID
  List<BranchModel> childrenOf(int parentId) =>
      _branches.where((b) => b.idInduk == parentId).toList();

  /// Check if a branch has any children
  bool hasChildren(int branchId) =>
      _branches.any((b) => b.idInduk == branchId);

  /// Find a branch by its ID
  BranchModel? findBranchById(int? id) {
    if (id == null) return null;
    try {
      return _branches.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get the list of branches from root ancestor down to [branch]
  List<BranchModel> getBranchPath(BranchModel? branch) {
    if (branch == null) return [];
    final List<BranchModel> path = [];
    BranchModel? curr = branch;
    final Set<int> visited = {};
    while (curr != null && !visited.contains(curr.id)) {
      path.insert(0, curr);
      visited.add(curr.id);
      if (curr.idInduk == null) break;
      curr = findBranchById(curr.idInduk);
    }
    return path;
  }

  /// Path for the currently selected branch
  List<BranchModel> get selectedBranchPath => getBranchPath(_selectedBranch);

  /// Breadcrumb text for the selected branch (e.g. "Pusat Surabaya > Cabang Madiun")
  String get selectedBranchPathText {
    if (_selectedBranch == null) return '';
    final path = selectedBranchPath;
    if (path.isEmpty) return _selectedBranch!.namaCabang;
    return path.map((b) => b.namaCabang).join(' > ');
  }

  /// Returns true if this branchId contains the currently selected branch in its descendants
  bool containsSelected(int branchId) {
    if (_selectedBranch == null) return false;
    if (_selectedBranch!.id == branchId) return true;
    final path = selectedBranchPath;
    return path.any((b) => b.id == branchId);
  }

  Future<void> fetchBranches() async {
    _isLoading = true;
    notifyListeners();

    _branches = await _service.getBranches();

    _isLoading = false;
    notifyListeners();
  }

  void selectBranch(BranchModel? branch) {
    _selectedBranch = branch;
    ApiConfig.selectedBranchId = branch?.id;
    notifyListeners();
  }
}
