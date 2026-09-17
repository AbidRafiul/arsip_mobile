import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/arsip_service.dart';
import '../common/document_preview_screen.dart';

class ArsipDetailScreen extends StatefulWidget {
  final int documentId;
  
  const ArsipDetailScreen({Key? key, required this.documentId}) : super(key: key);

  @override
  State<ArsipDetailScreen> createState() => _ArsipDetailScreenState();
}

class _ArsipDetailScreenState extends State<ArsipDetailScreen> {
  final ArsipService _service = ArsipService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _service.getDocumentDetail(widget.documentId);
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Detail Arsip',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Gagal memuat data: $_errorMessage', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchDetail, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : _detail == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Kode Dokumen', _detail!['document']?['kode_dokumen'] ?? _detail!['kode_dokumen'] ?? '-'),
                                _buildInfoRow('Nama Dokumen', _detail!['document']?['nama_dokumen'] ?? _detail!['nama_dokumen'] ?? '-'),
                                _buildInfoRow('Nomor Dokumen', _detail!['document']?['nomor_dokumen'] ?? _detail!['nomor_dokumen'] ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('Jenis Dokumen', _detail!['document']?['nama_jenis_dokumen'] ?? _detail!['nama_jenis_dokumen'] ?? '-'),
                                _buildInfoRow('Kategori Dokumen', _detail!['document']?['nama_kategori_dokumen'] ?? _detail!['nama_kategori_dokumen'] ?? '-'),
                                _buildInfoRow('Klasifikasi Arsip', _detail!['document']?['nama_klasifikasi'] ?? _detail!['nama_klasifikasi'] ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('Tanggal Transaksi', (_detail!['document']?['tanggal_transaksi'] ?? _detail!['tanggal_transaksi'])?.toString().substring(0, 10) ?? '-'),
                                _buildInfoRow('Jadwal Retensi', _detail!['document']?['nama_retensi'] ?? _detail!['nama_retensi'] ?? '-'),
                                _buildInfoRow('Tanggal Kedaluwarsa', (_detail!['document']?['tanggal_kedaluwarsa'] ?? _detail!['tanggal_kedaluwarsa'])?.toString().substring(0, 10) ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('PIC', _detail!['document']?['nama_pic'] ?? _detail!['nama_pic'] ?? '-'),
                                _buildInfoRow('Cabang', _detail!['document']?['nama_cabang'] ?? _detail!['nama_cabang'] ?? '-'),
                                _buildInfoRow('Lokasi Fisik', _detail!['document']?['lokasi_fisik'] ?? _detail!['lokasi_fisik'] ?? '-'),
                                _buildInfoRow('Status', _detail!['document']?['status'] ?? _detail!['status'] ?? '-'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              String idVersi = '';
                              if (_detail!['versions'] != null && (_detail!['versions'] as List).isNotEmpty) {
                                idVersi = _detail!['versions'][0]['id_versi']?.toString() ?? '';
                              }
                              
                              if (idVersi.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dokumen belum memiliki file versi.')),
                                );
                                return;
                              }

                              final String endpoint = "${ApiConfig.endpointDocumentVersionGet.replaceAll('/get', '')}/download?id_versi=$idVersi";
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocumentPreviewScreen(
                                    title: 'Preview Arsip',
                                    fileName: _detail!['document']?['nama_dokumen'] ?? _detail!['nama_dokumen'] ?? 'Dokumen',
                                    endpoint: endpoint,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                            label: Text(
                              'Lihat Isi Dokumen',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
