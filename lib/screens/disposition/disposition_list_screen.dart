import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_widgets.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/disposition_model.dart';
import '../../providers/disposition_provider.dart';

class DispositionListScreen extends StatefulWidget {
  const DispositionListScreen({Key? key}) : super(key: key);

  @override
  State<DispositionListScreen> createState() => _DispositionListScreenState();
}

class _DispositionListScreenState extends State<DispositionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DispositionProvider>(context, listen: false).fetchDispositionList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dispositionProvider = Provider.of<DispositionProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(title: const Text('Disposisi Surat Masuk')),
      body: Column(
        children: [
          // ── Filter Chips ──────────────────────────────────────────────
          Container(
            color: AppTheme.surfaceWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip(context, '', 'Semua Status'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'baru', 'Baru'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'diproses', 'Diproses'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'selesai', 'Selesai'),
                ],
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => dispositionProvider.fetchDispositionList(),
              color: AppTheme.primaryBlue,
              child: dispositionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dispositionProvider.dispositionList.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.inbox_rounded,
                          title: 'Tidak ada disposisi',
                          subtitle: 'Semua disposisi sudah ditangani.',
                          onRefresh: () => dispositionProvider.fetchDispositionList(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: dispositionProvider.dispositionList.length,
                          itemBuilder: (context, index) {
                            final item = dispositionProvider.dispositionList[index];
                            return _buildDispositionCard(context, item);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final provider = Provider.of<DispositionProvider>(context);
    final isSelected = provider.selectedStatusFilter == value;

    return GestureDetector(
      onTap: () => provider.setStatusFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDispositionCard(BuildContext context, DispositionItemModel item) {
    final provider = Provider.of<DispositionProvider>(context, listen: false);
    final isNew = item.status == 'baru';

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: nomor agenda + status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Agenda: ${item.nomorAgenda ?? "-"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.fromString(item.status),
                  ],
                ),
                const SizedBox(height: 10),

                // Perihal
                Text(
                  item.perihal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Meta: dari & instruksi
                _metaRow(Icons.person_outline_rounded, 'Dari: ${item.fromUserName ?? "Pengirim"}'),
                const SizedBox(height: 3),
                _metaRow(Icons.assignment_outlined, 'Instruksi: ${item.namaInstruksi ?? item.instruksi ?? "-"}'),
                if (item.catatanDisposisi != null && item.catatanDisposisi!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  _metaRow(Icons.notes_rounded, 'Catatan: ${item.catatanDisposisi}'),
                ],
                const SizedBox(height: 8),

                // Tanggal
                Text(
                  'Diterima: ${DateFormatter.formatIndonesianDateTime(item.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 12),

                // ── 3 Tombol Aksi Cepat ──
                _buildQuickActions(context, provider, item),
              ],
            ),
          ),
        ),

        // Badge "Baru" di pojok kanan atas
        if (isNew)
          Positioned(
            top: 0,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'BARU',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    DispositionProvider provider,
    DispositionItemModel item,
  ) {
    final statuses = [
      ('baru', 'Dibaca'),
      ('diproses', 'Diproses'),
      ('selesai', 'Selesaikan'),
    ];

    return Row(
      children: statuses.map((entry) {
        final (value, label) = entry;
        final isActive = item.status == value ||
            (value == 'baru' && (item.status == 'diproses' || item.status == 'selesai')) ||
            (value == 'diproses' && item.status == 'selesai');

        // Determine if this button triggers an action
        bool isClickable = false;
        if (value == 'diproses' && item.status == 'baru') isClickable = true;
        if (value == 'selesai' && item.status == 'diproses') isClickable = true;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: statuses.last.$1 != value ? 6 : 0),
            child: GestureDetector(
              onTap: isClickable && !provider.isActionLoading
                  ? () => _handleAction(context, provider, item, value)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryBlue : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    DispositionProvider provider,
    DispositionItemModel item,
    String targetStatus,
  ) async {
    bool ok = false;
    String successMsg = '';
    String failMsg = '';

    if (targetStatus == 'diproses') {
      ok = await provider.processDisposition(item.disposisiSuratId);
      successMsg = 'Status diperbarui ke Diproses';
      failMsg = 'Gagal memproses disposisi';
    } else if (targetStatus == 'selesai') {
      ok = await provider.completeDisposition(item.disposisiSuratId);
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      ),
    );
  }
}
