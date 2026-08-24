class ApprovalItemModel {
  final int idSuratKeluar;
  final String nomorSurat;
  final String nomorAgenda;
  final String tanggalSurat;
  final String? tanggalKirim;
  final int? idJenisSurat;
  final String? namaJenisSurat;
  final String perihal;
  final String tujuan;
  final String? instansiTujuan;
  final String? mediaPengiriman;
  final String status;
  final int? createdBy;
  final String? createdAt;
  final String? namaFile;
  final String? pathFile;

  ApprovalItemModel({
    required this.idSuratKeluar,
    required this.nomorSurat,
    required this.nomorAgenda,
    required this.tanggalSurat,
    this.tanggalKirim,
    this.idJenisSurat,
    this.namaJenisSurat,
    required this.perihal,
    required this.tujuan,
    this.instansiTujuan,
    this.mediaPengiriman,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.namaFile,
    this.pathFile,
  });

  factory ApprovalItemModel.fromJson(Map<String, dynamic> json) {
    return ApprovalItemModel(
      idSuratKeluar: json['id_surat_keluar'] ?? 0,
      nomorSurat: json['nomor_surat'] ?? '-',
      nomorAgenda: json['nomor_agenda'] ?? '-',
      tanggalSurat: json['tanggal_surat'] ?? '',
      tanggalKirim: json['tanggal_kirim'],
      idJenisSurat: json['id_jenis_surat'],
      namaJenisSurat: json['nama_jenis_surat'],
      perihal: json['perihal'] ?? 'Tanpa Perihal',
      tujuan: json['tujuan'] ?? '-',
      instansiTujuan: json['instansi_tujuan'],
      mediaPengiriman: json['media_pengiriman'],
      status: json['status'] ?? 'draft',
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      namaFile: json['nama_file'],
      pathFile: json['path_file'],
    );
  }
}

class TrackingItemModel {
  final int idTracking;
  final int idSuratKeluar;
  final String status;
  final String aktivitas;
  final String? catatan;
  final String tanggal;
  final String? namaPembuat;

  TrackingItemModel({
    required this.idTracking,
    required this.idSuratKeluar,
    required this.status,
    required this.aktivitas,
    this.catatan,
    required this.tanggal,
    this.namaPembuat,
  });

  factory TrackingItemModel.fromJson(Map<String, dynamic> json) {
    return TrackingItemModel(
      idTracking: json['id_tracking'] ?? 0,
      idSuratKeluar: json['id_surat_keluar'] ?? 0,
      status: json['status'] ?? '',
      aktivitas: json['aktivitas'] ?? '',
      catatan: json['catatan'],
      tanggal: json['tanggal'] ?? json['created_at'] ?? '',
      namaPembuat: json['nama_pembuat'],
    );
  }
}

class FileSuratModel {
  final int idFileSuratKeluar;
  final int idSuratKeluar;
  final String namaFile;
  final String pathFile;
  final String? mimeType;
  final int? ukuranFile;

  FileSuratModel({
    required this.idFileSuratKeluar,
    required this.idSuratKeluar,
    required this.namaFile,
    required this.pathFile,
    this.mimeType,
    this.ukuranFile,
  });

  factory FileSuratModel.fromJson(Map<String, dynamic> json) {
    return FileSuratModel(
      idFileSuratKeluar: json['id_file_surat_keluar'] ?? 0,
      idSuratKeluar: json['id_surat_keluar'] ?? 0,
      namaFile: json['nama_file'] ?? '',
      pathFile: json['path_file'] ?? '',
      mimeType: json['mime_type'],
      ukuranFile: json['ukuran_file'],
    );
  }
}
