class ExecutiveDashboardStats {
  final int pendingSuratKeluar;
  final int pendingPeminjamanArsip;
  final int pendingVersiDokumen;
  final int pendingBukuTamu;
  final int pendingPemusnahanArsip;
  final int totalDisposisiAktif;

  ExecutiveDashboardStats({
    this.pendingSuratKeluar = 0,
    this.pendingPeminjamanArsip = 0,
    this.pendingVersiDokumen = 0,
    this.pendingBukuTamu = 0,
    this.pendingPemusnahanArsip = 0,
    this.totalDisposisiAktif = 0,
  });

  int get grandTotalPending =>
      pendingSuratKeluar +
      pendingPeminjamanArsip +
      pendingVersiDokumen +
      pendingBukuTamu +
      pendingPemusnahanArsip;
}

class CorrespondenceDashboardStats {
  final int terkirim;
  final int disetujui;
  final int ditolak;
  final int menungguApproval;
  final int totalSuratKeluar;
  final int totalSuratMasuk;
  final int perluDisposisi;

  CorrespondenceDashboardStats({
    this.terkirim = 0,
    this.disetujui = 0,
    this.ditolak = 0,
    this.menungguApproval = 0,
    this.totalSuratKeluar = 0,
    this.totalSuratMasuk = 0,
    this.perluDisposisi = 0,
  });

  factory CorrespondenceDashboardStats.fromJson(Map<String, dynamic> json) {
    return CorrespondenceDashboardStats(
      terkirim: json['terkirim'] ?? json['terkirim_count'] ?? 0,
      disetujui: json['disetujui'] ?? json['disetujui_count'] ?? 0,
      ditolak: json['ditolak'] ?? json['ditolak_count'] ?? 0,
      menungguApproval: json['menungguApproval'] ?? json['menunggu_approval'] ?? 0,
      totalSuratKeluar: json['total'] ?? 0,
      totalSuratMasuk: json['totalSuratMasuk'] ?? 0,
      perluDisposisi: json['perluDisposisi'] ?? 0,
    );
  }
}

class ArsipDashboardStats {
  final int arsipAktif;
  final int arsipInaktif;
  final int peminjamanAktif;
  final int peminjamanOverdue;
  final int retensiExpired;
  final int usulanPemusnahan;

  ArsipDashboardStats({
    this.arsipAktif = 0,
    this.arsipInaktif = 0,
    this.peminjamanAktif = 0,
    this.peminjamanOverdue = 0,
    this.retensiExpired = 0,
    this.usulanPemusnahan = 0,
  });

  factory ArsipDashboardStats.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] ?? {};
    return ArsipDashboardStats(
      arsipAktif: metrics['pengarsipanDokumen'] ?? json['arsipAktif'] ?? json['totalDokumen'] ?? 0,
      arsipInaktif: json['arsipInaktif'] ?? 0,
      peminjamanAktif: metrics['dokumenDipinjam'] ?? json['peminjamanAktif'] ?? json['totalPeminjaman'] ?? 0,
      peminjamanOverdue: json['peminjamanOverdue'] ?? json['overdue'] ?? 0,
      retensiExpired: metrics['dokumenDariSurat'] ?? json['retensiExpired'] ?? 0,
      usulanPemusnahan: json['usulanPemusnahan'] ?? 0,
    );
  }
}

class BukuTamuDashboardStats {
  final int tamuHariIni;
  final int checkedIn;
  final int checkedOut;
  final int pendingApproval;

  BukuTamuDashboardStats({
    this.tamuHariIni = 0,
    this.checkedIn = 0,
    this.checkedOut = 0,
    this.pendingApproval = 0,
  });

  factory BukuTamuDashboardStats.fromJson(Map<String, dynamic> json) {
    return BukuTamuDashboardStats(
      tamuHariIni: json['tamuHariIni'] ?? json['total_tamu'] ?? json['total'] ?? 0,
      checkedIn: json['checkedIn'] ?? json['checked_in'] ?? json['aktif'] ?? 0,
      checkedOut: json['checkedOut'] ?? json['checked_out'] ?? json['selesai'] ?? 0,
      pendingApproval: json['pendingApproval'] ?? json['pending'] ?? 0,
    );
  }
}
