class DispositionItemModel {
  final int disposisiSuratId;
  final int suratMasukId;
  final String? nomorAgenda;
  final String? nomorSurat;
  final String perihal;
  final String? namaPengirim;
  final String? fromUserName;
  final String? toUserName;
  final String? namaInstruksi;
  final String? instruksi;
  final String? catatanDisposisi;
  final String? batasWaktu;
  final String status;
  final String createdAt;

  DispositionItemModel({
    required this.disposisiSuratId,
    required this.suratMasukId,
    this.nomorAgenda,
    this.nomorSurat,
    required this.perihal,
    this.namaPengirim,
    this.fromUserName,
    this.toUserName,
    this.namaInstruksi,
    this.instruksi,
    this.catatanDisposisi,
    this.batasWaktu,
    required this.status,
    required this.createdAt,
  });

  factory DispositionItemModel.fromJson(Map<String, dynamic> json) {
    return DispositionItemModel(
      disposisiSuratId: json['disposisi_surat_id'] ?? 0,
      suratMasukId: json['surat_masuk_id'] ?? 0,
      nomorAgenda: json['nomor_agenda'],
      nomorSurat: json['nomor_surat'],
      perihal: json['perihal'] ?? 'Disposisi Surat',
      namaPengirim: json['nama_pengirim'],
      fromUserName: json['from_user_name'],
      toUserName: json['to_user_name'],
      namaInstruksi: json['nama_instruksi'],
      instruksi: json['instruksi'],
      catatanDisposisi: json['catatan_disposisi'],
      batasWaktu: json['batas_waktu'],
      status: json['status'] ?? 'baru',
      createdAt: json['created_at'] ?? '',
    );
  }
}
