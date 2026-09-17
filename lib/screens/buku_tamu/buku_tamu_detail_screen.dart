import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/buku_tamu_service.dart';

class BukuTamuDetailScreen extends StatefulWidget {
  final int visitationId;
  
  const BukuTamuDetailScreen({Key? key, required this.visitationId}) : super(key: key);

  @override
  State<BukuTamuDetailScreen> createState() => _BukuTamuDetailScreenState();
}

class _BukuTamuDetailScreenState extends State<BukuTamuDetailScreen> {
  final BukuTamuService _service = BukuTamuService();
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
      final detail = await _service.getVisitDetail(widget.visitationId);
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
          'Detail Kunjungan',
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
                          if (_detail!['PhotoFaceUrl'] != null)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(_detail!['PhotoFaceUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: AppTheme.borderSubtle, width: 3),
                                ),
                              ),
                            ),
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
                                _buildInfoRow('Kode Kunjungan', _detail!['kode_kunjungan'] ?? '-'),
                                _buildInfoRow('Nama Tamu', _detail!['nama_tamu'] ?? '-'),
                                _buildInfoRow('Asal Instansi', _detail!['asal_instansi'] ?? '-'),
                                _buildInfoRow('Nomor Telepon', _detail!['nomor_telepon'] ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('Tujuan Kunjungan', _detail!['VisitPurposeName'] ?? '-'),
                                _buildInfoRow('Keperluan', _detail!['keperluan'] ?? '-'),
                                _buildInfoRow('Host Tujuan', _detail!['HostFullname'] ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('Tanggal Kunjungan', _detail!['tanggal_kunjungan']?.toString().substring(0, 10) ?? '-'),
                                _buildInfoRow('Waktu Check In', _detail!['waktu_check_in'] ?? '-'),
                                _buildInfoRow('Waktu Check Out', _detail!['waktu_check_out'] ?? '-'),
                                const Divider(height: 24),
                                _buildInfoRow('Status Kehadiran', _detail!['status'] ?? '-'),
                                _buildInfoRow('Status Persetujuan', _detail!['status_persetujuan'] ?? '-'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
