enum ApprovalCategory {
  outgoingLetter,
  disposition,
  archiveLoan,
  documentVersion,
  guestVisit,
  destructionProposal,
}

extension ApprovalCategoryExtension on ApprovalCategory {
  String get label {
    switch (this) {
      case ApprovalCategory.outgoingLetter:
        return 'Surat Keluar';
      case ApprovalCategory.disposition:
        return 'Disposisi Surat';
      case ApprovalCategory.archiveLoan:
        return 'Peminjaman Arsip';
      case ApprovalCategory.documentVersion:
        return 'Versi Dokumen';
      case ApprovalCategory.guestVisit:
        return 'Kunjungan Tamu';
      case ApprovalCategory.destructionProposal:
        return 'Pemusnahan Arsip';
    }
  }

  String get code {
    switch (this) {
      case ApprovalCategory.outgoingLetter:
        return 'outgoing_letter';
      case ApprovalCategory.disposition:
        return 'disposition';
      case ApprovalCategory.archiveLoan:
        return 'archive_loan';
      case ApprovalCategory.documentVersion:
        return 'document_version';
      case ApprovalCategory.guestVisit:
        return 'guest_visit';
      case ApprovalCategory.destructionProposal:
        return 'destruction_proposal';
    }
  }
}

class UnifiedApprovalItem {
  final int id;
  final ApprovalCategory category;
  final String title;
  final String subtitle;
  final String date;
  final String status;
  final String? requesterName;
  final String? notes;
  final Map<String, dynamic> rawData;

  UnifiedApprovalItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    this.requesterName,
    this.notes,
    required this.rawData,
  });

  // Safe Helper Parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Factory per Category:
  factory UnifiedApprovalItem.fromOutgoingLetter(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_surat_keluar']),
      category: ApprovalCategory.outgoingLetter,
      title: json['nomor_surat'] ?? json['perihal'] ?? 'Surat Keluar #${json['id_surat_keluar']}',
      subtitle: 'Perihal: ${json['perihal'] ?? '-'} • Tujuan: ${json['tujuan'] ?? '-'}',
      date: json['created_at'] ?? json['tanggal_surat'] ?? '-',
      status: json['status'] ?? 'menunggu_approval',
      requesterName: json['pembuat'] ?? json['created_by_nama'] ?? 'Staff',
      notes: json['catatan'],
      rawData: json,
    );
  }

  factory UnifiedApprovalItem.fromDisposition(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_disposisi'] ?? json['id']),
      category: ApprovalCategory.disposition,
      title: json['nomor_surat'] ?? 'Disposisi Surat Masuk',
      subtitle: 'Instruksi: ${json['instruksi'] ?? json['pesan_disposisi'] ?? '-'}',
      date: json['created_at'] ?? json['tanggal_disposisi'] ?? '-',
      status: json['status'] ?? 'diproses',
      requesterName: json['pengirim_nama'] ?? 'Pimpinan',
      notes: json['catatan'],
      rawData: json,
    );
  }

  factory UnifiedApprovalItem.fromArchiveLoan(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_peminjaman']),
      category: ApprovalCategory.archiveLoan,
      title: json['kode_dokumen'] ?? json['nama_dokumen'] ?? 'Peminjaman Arsip #${json['id_peminjaman']}',
      subtitle: 'Peminjam: ${json['nama_peminjam'] ?? '-'} • Keperluan: ${json['keperluan'] ?? '-'}',
      date: json['tanggal_pinjam'] ?? json['created_at'] ?? '-',
      status: json['status'] ?? 'pending',
      requesterName: json['nama_peminjam'] ?? '-',
      notes: json['catatan_persetujuan'],
      rawData: json,
    );
  }

  factory UnifiedApprovalItem.fromDocumentVersion(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_versi']),
      category: ApprovalCategory.documentVersion,
      title: 'Versi V${json['nomor_versi']} - ${json['kode_dokumen'] ?? 'Dokumen'}',
      subtitle: 'Keterangan Perubahan: ${json['keterangan_perubahan'] ?? '-'}',
      date: json['created_at'] ?? '-',
      status: json['status_persetujuan'] ?? 'pending',
      requesterName: json['dibuat_oleh'] ?? '-',
      notes: json['catatan_persetujuan'],
      rawData: json,
    );
  }

  factory UnifiedApprovalItem.fromGuestVisit(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_kunjungan']),
      category: ApprovalCategory.guestVisit,
      title: 'Tamu: ${json['nama_tamu'] ?? 'Kunjungan Tamu'}',
      subtitle: 'Instansi: ${json['instansi_tamu'] ?? '-'} • Host: ${json['nama_host'] ?? '-'}',
      date: json['created_at'] ?? json['tanggal_kunjungan'] ?? '-',
      status: json['status_persetujuan'] ?? 'pending',
      requesterName: json['nama_tamu'] ?? '-',
      notes: json['catatan_persetujuan'],
      rawData: json,
    );
  }

  factory UnifiedApprovalItem.fromDestructionProposal(Map<String, dynamic> json) {
    return UnifiedApprovalItem(
      id: _parseInt(json['id_usulan']),
      category: ApprovalCategory.destructionProposal,
      title: 'Usulan Pemusnahan: ${json['kode_dokumen'] ?? json['nomor_usulan'] ?? '#${json['id_usulan']}'}',
      subtitle: 'Alasan: ${json['alasan_pemusnahan'] ?? '-'}',
      date: json['created_at'] ?? '-',
      status: json['status'] ?? 'submitted',
      requesterName: json['diusulkan_oleh'] ?? '-',
      notes: json['catatan_tinjauan'],
      rawData: json,
    );
  }
}
