import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/disposition_model.dart';
import '../../providers/disposition_provider.dart';
import '../common/document_preview_screen.dart';

class DispositionDetailScreen extends StatefulWidget {
  final DispositionItemModel item;
  const DispositionDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<DispositionDetailScreen> createState() => _DispositionDetailScreenState();
}

class _DispositionDetailScreenState extends State<DispositionDetailScreen> {
  void _openDocumentPreview() async {
    final raw = widget.item.rawData;
    String? filePath = raw['path_file'] ?? raw['file_path'];
    int? fileSuratMasukId = raw['file_surat_masuk_id'] != null ? int.tryParse(raw['file_surat_masuk_id'].toString()) : null;
    int? suratMasukId = widget.item.suratMasukId;

    if ((fileSuratMasukId == null || fileSuratMasukId == 0) && suratMasukId != null && suratMasukId != 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final apiClient = ApiClient();
        final detailRes = await apiClient.post('/correspondence/incoming-letter-detail', data: {'surat_masuk_id': suratMasukId});
        if (!mounted) return;
        Navigator.pop(context); // close loading
        if (detailRes.statusCode == 200 && detailRes.data != null) {
          final files = detailRes.data['data']?['files'] as List?;
          if (files != null && files.isNotEmpty) {
            fileSuratMasukId = files.first['file_surat_masuk_id'] != null ? int.tryParse(files.first['file_surat_masuk_id'].toString()) : null;
            filePath = files.first['path_file']?.toString() ?? filePath;
          }
        }
      } catch (_) {
        if (mounted) Navigator.pop(context); // close loading on error
      }
    }

    // fallback if still null
    fileSuratMasukId ??= suratMasukId;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          fileName: 'Lampiran_${widget.item.nomorAgenda ?? "Disposisi"}.pdf',
          title: widget.item.perihal,
          endpoint: '/correspondence/incoming-file-download',
          method: 'POST',
          filePath: filePath?.toString(),
          queryParameters: {
            if (fileSuratMasukId != null && fileSuratMasukId != 0) 'file_surat_masuk_id': fileSuratMasukId,
            if (filePath != null) 'path_file': filePath,
          },
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    DispositionProvider provider,
    String targetStatus,
  ) async {
    final isProcess = targetStatus == 'diproses';
    final notesController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isProcess ? 'Mulai Proses Disposisi' : 'Selesaikan Disposisi',
          style: TextStyle(
            color: isProcess ? AppTheme.primaryBlue : AppTheme.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isProcess
                  ? 'Apakah Anda yakin ingin memproses disposisi ini sekarang?'
                  : 'Apakah Anda yakin ingin menandai disposisi ini selesai?',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isProcess ? AppTheme.primaryBlue : AppTheme.successColor,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Lanjutkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final notes = notesController.text.trim();
    bool ok = false;
    String successMsg = '';
    String failMsg = '';

    if (isProcess) {
      ok = await provider.processDisposition(widget.item.disposisiSuratId, catatan: notes.isNotEmpty ? notes : null);
      successMsg = 'Status diperbarui ke Diproses';
      failMsg = 'Gagal memproses disposisi';
    } else {
      ok = await provider.completeDisposition(widget.item.disposisiSuratId, catatan: notes.isNotEmpty ? notes : null);
      successMsg = 'Status diperbarui ke Selesai';
      failMsg = 'Gagal menyelesaikan disposisi';
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(ok ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(ok ? successMsg : failMsg),
          ],
        ),
        backgroundColor: ok ? AppTheme.successColor : AppTheme.dangerColor,
      ),
    );

    if (ok) {
      Navigator.pop(context); // Kembali ke list
    }
  }

  Widget _buildQuickActions(BuildContext context, DispositionProvider provider) {
    final statuses = [
      ('baru', 'Dibaca'),
      ('diproses', 'Diproses'),
      ('selesai', 'Selesaikan'),
    ];

    return Row(
      children: statuses.map((entry) {
        final value = entry.$1;
        final label = entry.$2;
        final currentStatus = widget.item.status.toLowerCase();
        
        // Cek logic berurutan (sequence)
        bool isClickable = false;
        // Hanya bisa klik Diproses jika status saat ini baru atau dibaca
        if (value == 'diproses' && (currentStatus == 'baru' || currentStatus == 'dibaca')) isClickable = true;
        // Hanya bisa klik Selesai jika status saat ini diproses
        if (value == 'selesai' && currentStatus == 'diproses') isClickable = true;
        
        // Active indicator
        bool isActive = currentStatus == value;
        // Jika status dibaca, maka badge 'Dibaca' (yang value-nya 'baru') menyala
        if (value == 'baru' && (currentStatus == 'baru' || currentStatus == 'dibaca')) isActive = true;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: statuses.last.$1 != value ? 8 : 0),
            child: GestureDetector(
              onTap: isClickable && !provider.isActionLoading
                  ? () => _handleAction(context, provider, value)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryBlue : (isClickable ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.surfaceWhite),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppTheme.primaryBlue : (isClickable ? AppTheme.primaryBlue : AppTheme.borderSubtle),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : (isClickable ? AppTheme.primaryBlue : AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: isBadge
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final provider = context.watch<DispositionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Disposisi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.description, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disposisi Surat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          item.perihal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Status Persetujuan', item.status.toUpperCase(), isBadge: true),
                    const Divider(),
                    _buildDetailRow('Tanggal Pengajuan', DateFormatter.formatIndonesianDateTime(item.createdAt)),
                    const Divider(),
                    _buildDetailRow('Diusulkan Oleh', item.fromUserName ?? 'Pengirim'),
                    const Divider(),
                    _buildDetailRow('Instruksi', item.namaInstruksi ?? item.instruksi ?? '-'),
                    if (item.catatanDisposisi != null && item.catatanDisposisi!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Catatan', item.catatanDisposisi!),
                    ],
                    const Divider(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                        label: const Text('PRINJAU BERKAS DOKUMEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: _openDocumentPreview,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons from Disposition
            _buildQuickActions(context, provider),
          ],
        ),
      ),
    );
  }
}
