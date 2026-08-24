import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/approval_provider.dart';
import '../common/document_preview_screen.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final int idSuratKeluar;

  const ApprovalDetailScreen({Key? key, required this.idSuratKeluar}) : super(key: key);

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  final _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApprovalProvider>(context, listen: false).fetchLetterDetail(widget.idSuratKeluar);
    });
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _showApproveDialog() {
    _catatanController.text = 'Surat disetujui';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('Setujui Surat Keluar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anda akan menyetujui surat keluar ini. Tanda Tangan Elektronik (TTE) akan otomatis tertempel pada dokumen.'),
            const SizedBox(height: 16),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan Persetujuan (Opsional)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = Provider.of<ApprovalProvider>(context, listen: false);
              try {
                final success = await provider.approveLetter(
                  widget.idSuratKeluar,
                  catatan: _catatanController.text.trim(),
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surat berhasil disetujui & TTE berhasil diproses!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.dangerColor),
                  );
                }
              }
            },
            child: const Text('SETUJUI & TTE'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    _catatanController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppTheme.dangerColor),
            SizedBox(width: 8),
            Text('Tolak Surat Keluar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harap berikan alasan atau catatan penolakan untuk pembuat surat.'),
            const SizedBox(height: 16),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan Alasan Penolakan *',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            onPressed: () async {
              if (_catatanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan penolakan wajib diisi!'), backgroundColor: AppTheme.dangerColor),
                );
                return;
              }
              Navigator.of(ctx).pop();
              final provider = Provider.of<ApprovalProvider>(context, listen: false);
              try {
                final success = await provider.rejectLetter(
                  widget.idSuratKeluar,
                  catatan: _catatanController.text.trim(),
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surat telah ditolak.'),
                      backgroundColor: AppTheme.warningColor,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.dangerColor),
                  );
                }
              }
            },
            child: const Text('TOLAK SURAT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalProvider>(context);
    final letter = provider.currentLetter;
    final files = provider.currentFiles;
    final trackings = provider.currentTrackings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Approval Surat'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : letter == null
              ? const Center(child: Text('Data surat tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Letter Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.description, color: AppTheme.primaryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          letter.nomorSurat,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          'Agenda: ${letter.nomorAgenda}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow('Perihal', letter.perihal),
                              _buildInfoRow('Tujuan Surat', '${letter.tujuan} ${letter.instansiTujuan != null ? "(${letter.instansiTujuan})" : ""}'),
                              _buildInfoRow('Jenis Surat', letter.namaJenisSurat ?? '-'),
                              _buildInfoRow('Tanggal Surat', DateFormatter.formatIndonesianDate(letter.tanggalSurat)),
                              _buildInfoRow('Status Saat Ini', letter.status.toUpperCase()),
                              if (files.isNotEmpty || letter.pathFile != null) ...[
                                const Divider(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.visibility, color: Colors.white),
                                    label: const Text('PRINJAU DOKUMEN UTAMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      final firstFile = files.isNotEmpty ? files.first : null;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DocumentPreviewScreen(
                                            title: 'Prinjau Surat Keluar',
                                            fileName: firstFile?.namaFile ?? letter.namaFile ?? 'surat_${letter.idSuratKeluar}.pdf',
                                            filePath: firstFile?.pathFile ?? letter.pathFile,
                                            mimeType: firstFile?.mimeType ?? 'application/pdf',
                                            queryParameters: {'id_surat_keluar': letter.idSuratKeluar},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attachments Section
                      Text(
                        'Lampiran Berkas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      if (files.isEmpty && letter.pathFile == null)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Tidak ada berkas yang diunggah'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: files.isEmpty ? 1 : files.length,
                          itemBuilder: (context, index) {
                            final fileName = files.isNotEmpty ? files[index].namaFile : (letter.namaFile ?? 'Berkas Surat Keluar.pdf');
                            final filePath = files.isNotEmpty ? files[index].pathFile : letter.pathFile;
                            final mimeType = files.isNotEmpty ? files[index].mimeType : 'application/pdf';

                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.picture_as_pdf, color: AppTheme.dangerColor),
                                title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(mimeType ?? 'Dokumen PDF'),
                                trailing: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryLight,
                                    foregroundColor: AppTheme.primaryColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DocumentPreviewScreen(
                                          title: 'Prinjau Lampiran',
                                          fileName: fileName,
                                          filePath: filePath,
                                          mimeType: mimeType,
                                          queryParameters: {'id_surat_keluar': letter.idSuratKeluar},
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocumentPreviewScreen(
                                        title: 'Prinjau Lampiran',
                                        fileName: fileName,
                                        filePath: filePath,
                                        mimeType: mimeType,
                                        queryParameters: {'id_surat_keluar': letter.idSuratKeluar},
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      // Tracking History Section
                      Text(
                        'Riwayat Tracking Surat',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trackings.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final track = trackings[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryLight,
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              ),
                              title: Text(track.aktivitas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${track.catatan ?? "Tidak ada catatan"}\n${DateFormatter.formatIndonesianDateTime(track.tanggal)}'),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 100), // Spacing for bottom action buttons
                    ],
                  ),
                ),
      bottomSheet: (letter != null && letter.status == 'menunggu_approval')
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dangerColor,
                        side: const BorderSide(color: AppTheme.dangerColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('TOLAK'),
                      onPressed: provider.isActionLoading ? null : _showRejectDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('SETUJUI & TTE'),
                      onPressed: provider.isActionLoading ? null : _showApproveDialog,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
