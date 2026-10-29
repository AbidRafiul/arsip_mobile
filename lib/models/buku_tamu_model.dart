class BukuTamuItem {
  final int id;
  final String kodeKunjungan;
  final String namaTamu;
  final String asalInstansi;
  final String? tujuanKunjungan;
  final String? namaHost;
  final String? namaCabang;
  final String status;
  final String statusPersetujuan;
  final String? tanggalKunjungan;
  final String? waktuKunjungan;
  final String? keperluan;
  final String? fotoWajahUrl;

  BukuTamuItem({
    required this.id,
    required this.kodeKunjungan,
    required this.namaTamu,
    required this.asalInstansi,
    this.tujuanKunjungan,
    this.namaHost,
    this.namaCabang,
    required this.status,
    required this.statusPersetujuan,
    this.tanggalKunjungan,
    this.waktuKunjungan,
    this.keperluan,
    this.fotoWajahUrl,
  });

  factory BukuTamuItem.fromJson(Map<String, dynamic> json) {
    return BukuTamuItem(
      id: json['id_kunjungan'] ?? 0,
      kodeKunjungan: json['kode_kunjungan'] ?? '',
      namaTamu: json['nama_tamu'] ?? '-',
      asalInstansi: json['asal_instansi'] ?? '-',
      tujuanKunjungan: json['VisitPurposeName'] ?? json['nama_tujuan_kunjungan'],
      namaHost: json['HostFullname'] ?? json['nama_lengkap'],
      namaCabang: json['BranchName'] ?? json['nama_cabang'],
      status: json['status'] ?? 'pending',
      statusPersetujuan: json['status_persetujuan'] ?? 'pending',
      tanggalKunjungan: json['tanggal_kunjungan'],
      waktuKunjungan: json['waktu_kunjungan'],
      keperluan: json['keperluan'],
      fotoWajahUrl: json['foto_wajah_url'] ?? json['foto_wajah'],
    );
  }
}
