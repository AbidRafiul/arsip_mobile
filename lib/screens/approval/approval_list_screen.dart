import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_widgets.dart';
import '../../models/unified_approval_model.dart';
import '../../models/disposition_model.dart';
import '../../providers/unified_approval_provider.dart';
import 'approval_unified_detail_screen.dart';
import '../disposition/disposition_detail_screen.dart';
import '../../providers/branch_provider.dart';

class ApprovalListScreen extends StatefulWidget {
  const ApprovalListScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalListScreen> createState() => _ApprovalListScreenState();
}

class _ApprovalListScreenState extends State<ApprovalListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnifiedApprovalProvider>(context, listen: false).fetchApprovals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approvalProvider = Provider.of<UnifiedApprovalProvider>(context);

    // Filter items by search text
    final query = _searchController.text.toLowerCase();
    final items = approvalProvider.approvalItems.where((item) {
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) || item.subtitle.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(
        title: Consumer<BranchProvider>(
          builder: (context, branchProv, _) {
            final sel = branchProv.selectedBranch;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pusat Approval', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(
                  sel != null ? 'Kantor: ${sel.namaCabang}' : 'Semua Kantor Cabang',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => approvalProvider.fetchApprovals(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────
          Container(
            color: AppTheme.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari nomor atau perihal surat...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: AppTheme.surfaceSoft,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Filter Chips ─────────────────────────────────────────────
          Container(
            color: AppTheme.surfaceWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  _buildFilterChip(context, approvalProvider, label: 'Semua', category: null),
                  const SizedBox(width: 8),
                  ...ApprovalCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(context, approvalProvider, label: cat.label, category: cat),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 1), // shadow separator

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => approvalProvider.fetchApprovals(),
              color: AppTheme.primaryBlue,
              child: approvalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.task_alt_rounded,
                          title: 'Tidak ada permohonan',
                          subtitle: query.isNotEmpty
                              ? 'Tidak ada hasil untuk "$query"'
                              : 'Semua tugas persetujuan Anda telah selesai.',
                          onRefresh: () => approvalProvider.fetchApprovals(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _buildApprovalCard(context, item);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    UnifiedApprovalProvider provider, {
    required String label,
    required ApprovalCategory? category,
  }) {
    final isSelected = provider.selectedCategory == category;
    return GestureDetector(
      onTap: () => provider.setSelectedCategory(isSelected ? null : category),
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

  Widget _buildApprovalCard(BuildContext context, UnifiedApprovalItem item) {
    final categoryColor = _getCategoryColor(item.category);

    return GestureDetector(
      onTap: () {
        if (item.category == ApprovalCategory.disposition) {
          final dispositionItem = DispositionItemModel.fromJson(item.rawData);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DispositionDetailScreen(item: dispositionItem)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ApprovalUnifiedDetailScreen(item: item)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F0F172A),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status border
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip + status badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category.label,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: categoryColor),
                            ),
                          ),
                          // Badge Cabang
                          Builder(
                            builder: (context) {
                              String? branch = item.branchName;
                              if (branch == null && item.branchId != null) {
                                final bp = Provider.of<BranchProvider>(context, listen: false);
                                branch = bp.findBranchById(item.branchId)?.namaCabang;
                              }
                              if (branch == null) {
                                final bp = Provider.of<BranchProvider>(context, listen: false);
                                if (bp.selectedBranch != null) {
                                  branch = bp.selectedBranch!.namaCabang;
                                }
                              }
                              if (branch == null || branch.isEmpty) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 0.6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_city_rounded, size: 10, color: AppTheme.primaryBlue),
                                      const SizedBox(width: 3),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 110),
                                        child: Text(
                                          branch,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryBlue,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          StatusBadge.fromString(item.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Judul / nomor
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Perihal / subtitle
                      Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Metadata baris bawah
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(item.date, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ApprovalCategory category) {
    switch (category) {
      case ApprovalCategory.outgoingLetter:
        return AppTheme.primaryBlue;
      case ApprovalCategory.disposition:
        return const Color(0xFF7C3AED);
      case ApprovalCategory.archiveLoan:
        return AppTheme.warningColor;
      case ApprovalCategory.documentVersion:
        return AppTheme.successColor;
      case ApprovalCategory.guestVisit:
        return const Color(0xFF3B82F6);
      case ApprovalCategory.destructionProposal:
        return AppTheme.dangerColor;
    }
  }
}
