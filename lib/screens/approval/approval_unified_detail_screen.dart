import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/unified_approval_model.dart';
import '../../providers/unified_approval_provider.dart';
import '../common/document_preview_screen.dart';

class ApprovalUnifiedDetailScreen extends StatefulWidget {
  final UnifiedApprovalItem item;

  const ApprovalUnifiedDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ApprovalUnifiedDetailScreen> createState() => _ApprovalUnifiedDetailScreenState();
}

class _ApprovalUnifiedDetailScreenState extends State<ApprovalUnifiedDetailScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _openDocumentPreview(UnifiedApprovalItem item) {
    final raw = item.rawData;
    final filePath = raw['path_file'] ?? raw['file_path'] ?? raw['path_file_versi'] ?? raw['path'];
    final fileName = raw['nama_file'] ?? raw['nama_dokumen'] ?? raw['kode_dokumen'] ?? '${item.category.code}_${item.id}.pdf';

    String endpoint = '/correspondence/outgoing-file-download';
    Map<String, dynamic> params = {};

    if (item.category == ApprovalCategory.outgoingLetter) {
      endpoint = '/correspondence/outgoing-file-download';
      params['id_surat_keluar'] = item.id;
    } else if (item.category == ApprovalCategory.disposition) {
      endpoint = '/correspondence/incoming-file-download';
      params['file_surat_masuk_id'] = raw['file_surat_masuk_id'] ?? raw['id_surat_masuk'] ?? item.id;
      if (filePath != null) params['path_file'] = filePath;
    } else if (item.category == ApprovalCategory.documentVersion) {
      endpoint = '/arsip-dokumen/version/download';
      params['id_versi'] = item.id;
      if (filePath != null) params['path_file'] = filePath;
    } else if (item.category == ApprovalCategory.archiveLoan) {
      endpoint = '/correspondence/outgoing-file-download';
      params['id_peminjaman'] = item.id;
      if (raw['kode_dokumen'] != null) params['kode_dokumen'] = raw['kode_dokumen'];
      if (filePath != null) params['path_file'] = filePath;
    } else {
      endpoint = '/correspondence/outgoing-file-download';
      if (filePath != null && filePath.toString().isNotEmpty) {
        params['path_file'] = filePath;
      } else {
        params['id_surat_keluar'] = item.id;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          title: 'Prinjau ${item.category.label}',
          fileName: fileName.toString(),
          filePath: filePath?.toString(),
          endpoint: endpoint,
          queryParameters: params,
        ),
      ),
    );
  }

  void _showConfirmDialog({required bool isApprove}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isApprove ? 'Setujui Permohonan' : 'Tolak Permohonan',
            style: TextStyle(
              color: isApprove ? AppTheme.successColor : AppTheme.dangerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isApprove
                    ? 'Apakah Anda yakin ingin menyetujui ${widget.item.category.label} ini?'
                    : 'Apakah Anda yakin ingin menolak permohonan ini?',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isApprove ? 'Catatan (Opsional)' : 'Alasan Penolakan (Wajib)',
                  hintText: isApprove ? 'Disetujui' : 'Tuliskan alasan penolakan...',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? AppTheme.successColor : AppTheme.dangerColor,
              ),
              onPressed: () async {
                final notes = _notesController.text.trim();
                if (!isApprove && notes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan penolakan wajib diisi')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final provider = Provider.of<UnifiedApprovalProvider>(context, listen: false);
                bool success = false;

                if (isApprove) {
                  success = await provider.approveItem(widget.item, notes: notes);
                } else {
                  success = await provider.rejectItem(widget.item, notes: notes);
                }

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isApprove
                              ? '${widget.item.category.label} berhasil disetujui!'
                              : '${widget.item.category.label} telah ditolak.',
                        ),
                        backgroundColor: isApprove ? AppTheme.successColor : AppTheme.dangerColor,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Gagal memproses permohonan'),
                        backgroundColor: AppTheme.dangerColor,
                      ),
                    );
                  }
                }
              },
              child: Text(isApprove ? 'Setujui' : 'Tolak', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${item.category.label}'),
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
                          item.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          item.title,
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
                    _buildDetailRow('Tanggal Pengajuan', item.date),
                    const Divider(),
                    _buildDetailRow('Diusulkan / Dibuat Oleh', item.requesterName ?? '-'),
                    const Divider(),
                    _buildDetailRow('Keterangan / Subtitle', item.subtitle),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Catatan Tambahan', item.notes!),
                    ],
                    const Divider(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                        label: const Text('PRINJAU BERKAS DOKUMEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => _openDocumentPreview(item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerColor,
                      side: BorderSide(color: AppTheme.dangerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showConfirmDialog(isApprove: false),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('TOLAK'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showConfirmDialog(isApprove: true),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('SETUJUI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}
