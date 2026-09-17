class ArsipItem {
  final int id;
  final String kodeDokumen;
  final String namaDokumen;
  final String nomorDokumen;
  final String? tanggal;
  final String namaCabang;
  final String? deskripsi;

  ArsipItem({
    required this.id,
    required this.kodeDokumen,
    required this.namaDokumen,
    required this.nomorDokumen,
    this.tanggal,
    required this.namaCabang,
    this.deskripsi,
  });

  factory ArsipItem.fromJson(Map<String, dynamic> json) {
    return ArsipItem(
      id: json['id_dokumen'] ?? 0,
      kodeDokumen: json['kode_dokumen'] ?? '-',
      namaDokumen: json['nama_dokumen'] ?? '-',
      nomorDokumen: json['nomor_dokumen'] ?? '-',
      tanggal: json['tanggal'] ?? json['tanggal_transaksi'],
      namaCabang: json['nama_cabang'] ?? '-',
      deskripsi: json['deskripsi'],
    );
  }
}
