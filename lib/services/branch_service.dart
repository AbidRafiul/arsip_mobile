import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/branch_model.dart';

class BranchService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _apiClient.post(ApiConfig.endpointBranchGet, data: {});
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        List rows = [];
        if (data is List) {
          rows = data;
        } else if (data is Map) {
          rows = data['rows'] ?? data['data'] ?? [];
        }
        
        return rows.map((e) => BranchModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching branches: $e');
    }
    return [];
  }
}
