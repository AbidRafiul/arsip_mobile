class DashboardSummaryModel {
  final int arsipAktif;
  final int tamuHariIni;
  final int menungguDisposisi;
  final int retensiExpired;
  final int total;

  DashboardSummaryModel({
    required this.arsipAktif,
    required this.tamuHariIni,
    required this.menungguDisposisi,
    required this.retensiExpired,
    required this.total,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final active = json['arsipAktif'] ?? 0;
    final guest = json['tamuHariIni'] ?? 0;
    final disp = json['menungguDisposisi'] ?? 0;
    final ret = json['retensiExpired'] ?? 0;

    return DashboardSummaryModel(
      arsipAktif: active,
      tamuHariIni: guest,
      menungguDisposisi: disp,
      retensiExpired: ret,
      total: active + guest + disp + ret,
    );
  }
}

class AuditLogItem {
  final dynamic id;
  final String user;
  final String action;
  final String time;

  AuditLogItem({
    required this.id,
    required this.user,
    required this.action,
    required this.time,
  });

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      id: json['id'],
      user: json['user'] ?? json['nama_pengguna'] ?? 'System',
      action: json['action'] ?? json['aksi'] ?? '',
      time: json['time'] ?? json['created_at'] ?? '',
    );
  }
}
