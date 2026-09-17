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
