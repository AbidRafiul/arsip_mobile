import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/buku_tamu_model.dart';
import '../../services/buku_tamu_service.dart';
import 'buku_tamu_detail_screen.dart';

class BukuTamuListScreen extends StatefulWidget {
  const BukuTamuListScreen({Key? key}) : super(key: key);

  @override
  State<BukuTamuListScreen> createState() => _BukuTamuListScreenState();
}

class _BukuTamuListScreenState extends State<BukuTamuListScreen> {
  final BukuTamuService _service = BukuTamuService();
  List<BukuTamuItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _service.getVisitData(limit: 50);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'checked_in':
        bgColor = AppTheme.successColor.withValues(alpha: 0.15);
        textColor = AppTheme.successColor;
        break;
      case 'selesai':
      case 'checked_out':
        bgColor = AppTheme.primaryBlue.withValues(alpha: 0.15);
        textColor = AppTheme.primaryBlue;
        break;
      case 'batal':
      case 'ditolak':
        bgColor = AppTheme.dangerColor.withValues(alpha: 0.15);
        textColor = AppTheme.dangerColor;
        break;
      default:
        bgColor = AppTheme.warningColor.withValues(alpha: 0.15);
        textColor = AppTheme.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Daftar Buku Tamu',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gagal memuat data: $_errorMessage', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchData, child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data tamu.',
                          style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BukuTamuDetailScreen(visitationId: item.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.kodeKunjungan,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      _buildStatusBadge(item.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.namaTamu,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.business_rounded, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.asalInstansi,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.tanggalKunjungan ?? '-'} ${item.waktuKunjungan ?? ''}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.person_pin_rounded, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Host: ${item.namaHost ?? '-'}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
