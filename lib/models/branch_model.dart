class BranchModel {
  final int id;
  final int? idInduk;
  final String namaCabang;
  final String kodeCabang;
  final String status;
  final int level;
  final String? namaInduk;

  BranchModel({
    required this.id,
    this.idInduk,
    required this.namaCabang,
    required this.kodeCabang,
    required this.status,
    this.level = 1,
    this.namaInduk,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? json['id_cabang'] ?? 0,
      idInduk: json['id_induk'],
      namaCabang: json['nama_cabang'] ?? 'Cabang Tidak Diketahui',
      kodeCabang: json['kode_cabang'] ?? '-',
      status: json['status'] ?? 'aktif',
      level: json['level'] ?? 1,
      namaInduk: json['nama_induk'],
    );
  }
}
