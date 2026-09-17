class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? link;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.link,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id_notifikasi'] ?? 0,
      title: json['judul'] ?? 'Tanpa Judul',
      message: json['pesan'] ?? '',
      type: json['tipe'] ?? 'sistem',
      isRead: (json['status_baca'] == 1 || json['status_baca'] == true),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      link: json['tautan'],
    );
  }
}
