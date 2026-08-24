class UserModel {
  final int userId;
  final String username;
  final String fullName;
  final String role;
  final String? roleCode;
  final int? roleId;
  final int? branchId;
  final String? branchName;
  final String? status;

  UserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    this.roleCode,
    this.roleId,
    this.branchId,
    this.branchName,
    this.status,
  });

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  static int? _parseNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['IdPengguna'] ?? json['id_pengguna'] ?? json['userId'];
    final rawUsername = json['nama_pengguna'] ?? json['username'] ?? '';
    final rawFullName = json['nama_lengkap'] ?? json['name'] ?? json['fullname'] ?? '';
    final rawRole = json['role'] ?? json['nama_peran'] ?? 'User';
    final rawRoleCode = json['roleCode'] ?? json['kode_peran'];
    final rawRoleId = json['roleId'] ?? json['id_peran'];
    final rawBranchId = json['id_cabang'] ?? json['branchId'];
    final rawBranchName = json['nama_cabang'] ?? json['branchName'];
    final rawStatus = json['status'];

    return UserModel(
      userId: _parseInt(rawUserId, 0),
      username: rawUsername.toString(),
      fullName: rawFullName.toString(),
      role: rawRole.toString(),
      roleCode: rawRoleCode?.toString(),
      roleId: _parseNullableInt(rawRoleId),
      branchId: _parseNullableInt(rawBranchId),
      branchName: rawBranchName?.toString(),
      status: rawStatus?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdPengguna': userId,
      'nama_pengguna': username,
      'nama_lengkap': fullName,
      'role': role,
      'roleCode': roleCode,
      'roleId': roleId,
      'id_cabang': branchId,
      'nama_cabang': branchName,
      'status': status,
    };
  }
}
