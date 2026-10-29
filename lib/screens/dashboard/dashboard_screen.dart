import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multi_dashboard_provider.dart';
import '../approval/approval_list_screen.dart';
import '../disposition/disposition_list_screen.dart';
import '../profile/profile_screen.dart';
import '../notification/notification_screen.dart';
import '../arsip/arsip_list_screen.dart';
import '../buku_tamu/buku_tamu_list_screen.dart';
import '../../services/notification_service.dart';

import '../../providers/dashboard_provider.dart';
import '../../models/unified_approval_model.dart';
import '../../providers/unified_approval_provider.dart';
import '../../providers/branch_provider.dart';
import '../../models/branch_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _MultiDashboardHomeView(),
      const ApprovalListScreen(),
      const DispositionListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          border:
              Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task_rounded),
              label: 'Approval',
            ),
            NavigationDestination(
              icon: Icon(Icons.move_to_inbox_outlined),
              selectedIcon: Icon(Icons.move_to_inbox_rounded),
              label: 'Disposisi',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiDashboardHomeView extends StatefulWidget {
  const _MultiDashboardHomeView({Key? key}) : super(key: key);

  @override
  State<_MultiDashboardHomeView> createState() =>
      _MultiDashboardHomeViewState();
}

class _MultiDashboardHomeViewState extends State<_MultiDashboardHomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedPeriodLabel = 'Semua Waktu';
  String? _startDate = '2000-01-01';
  String? _endDate = '2100-12-31';

  int _unreadNotifCount = 0;
  final NotificationService _notificationService = NotificationService();

  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final notifs = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _unreadNotifCount = notifs.where((n) => !n.isRead).length;
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationCount();

    // Fetch branches if superadmin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser?.role?.toUpperCase() == 'SUPERADMIN') {
        Provider.of<BranchProvider>(context, listen: false).fetchBranches();
      }
    });

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Provider.of<MultiDashboardProvider>(context, listen: false)
            .setSelectedModuleIndex(_tabController.index,
                startDate: _startDate, endDate: _endDate);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MultiDashboardProvider>(context, listen: false)
          .fetchDashboardData(startDate: _startDate, endDate: _endDate);
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboardData(startDate: _startDate, endDate: _endDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    _fetchUnreadNotificationCount();
    await Future.wait([
      Provider.of<MultiDashboardProvider>(context, listen: false)
          .refreshAll(startDate: _startDate, endDate: _endDate),
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboardData(startDate: _startDate, endDate: _endDate),
    ]);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Pilih Periode',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _buildFilterOption('Hari Ini', _getToday(), _getToday()),
              _buildFilterOption('Kemarin', _getYesterday(), _getYesterday()),
              _buildFilterOption('Minggu Ini', _getStartOfWeek(), _getToday()),
              _buildFilterOption('Bulan Ini', _getStartOfMonth(), _getToday()),
              _buildFilterOption('Semua Waktu', '2000-01-01', '2100-12-31'),
            ],
          ),
        );
      },
    );
  }

  String _getToday() => DateTime.now().toIso8601String().substring(0, 10);
  String _getYesterday() => DateTime.now()
      .subtract(const Duration(days: 1))
      .toIso8601String()
      .substring(0, 10);
  String _getStartOfWeek() {
    final now = DateTime.now();
    return now
        .subtract(Duration(days: now.weekday - 1))
        .toIso8601String()
        .substring(0, 10);
  }

  String _getStartOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
  }

  Widget _buildFilterOption(String label, String? start, String? end) {
    return ListTile(
      title: Text(label),
      trailing: _selectedPeriodLabel == label
          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedPeriodLabel = label;
          _startDate = start;
          _endDate = end;
        });
        _refreshAllData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final multiDashboard = Provider.of<MultiDashboardProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.fullName.split(' ').first ?? 'Pejabat'}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 17),
            ),
            Row(
              children: [
                Text(
                  user?.role ?? 'Approver',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedPeriodLabel,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          if (user?.role?.toUpperCase() == 'SUPERADMIN')
            Consumer<BranchProvider>(
              builder: (context, branchProv, _) {
                final isFiltered = branchProv.selectedBranch != null;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.location_city_rounded,
                        color: isFiltered ? AppTheme.primaryBlue : null,
                      ),
                      onPressed: () => _showBranchSwitcherBottomSheet(context),
                      tooltip: 'Pilih Kantor',
                    ),
                    if (isFiltered)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                  _fetchUnreadNotificationCount();
                },
              ),
              // Badge notifikasi (hanya muncul jika ada notifikasi belum dibaca)
              if (_unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.dangerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshAllData,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppTheme.borderSubtle, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryBlue,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Eksekutif'),
                Tab(text: 'Korespondensi'),
                Tab(text: 'Arsip'),
                Tab(text: 'Buku Tamu'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: AppTheme.primaryBlue,
        child: Column(
          children: [
            _buildActiveBranchBanner(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExecutiveTab(context, multiDashboard),
                  _buildCorrespondenceTab(context, multiDashboard),
                  _buildArsipTab(context, multiDashboard),
                  _buildBukuTamuTab(context, multiDashboard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBranchBanner(BuildContext context) {
    return Consumer<BranchProvider>(
      builder: (context, branchProv, _) {
        final sel = branchProv.selectedBranch;
        if (sel == null) return const SizedBox.shrink();

        final pathText = branchProv.selectedBranchPathText;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  size: 18,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Kantor Aktif: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            sel.namaCabang,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (pathText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          pathText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade900.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showBranchSwitcherBottomSheet(context),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Ganti',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  branchProv.selectBranch(null);
                  _refreshAllData();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Tab Eksekutif
  Widget _buildExecutiveTab(
      BuildContext context, MultiDashboardProvider provider) {
    final stats = provider.executiveStats;
    final sysSummary = Provider.of<DashboardProvider>(context).summary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Total Pending — gradient biru (Bisa diklik untuk membuka detail approval)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ApprovalListScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Pusat Persetujuan Eksekutif',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stats.grandTotalPending}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Permohonan Menunggu Tindakan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Daftar permohonan dari seluruh modul yang memerlukan persetujuan Anda.',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    // Tombol Aksi Buka Detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Buka Detail Permohonan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppTheme.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ringkasan Utama Sistem
          const SectionHeader(title: 'Ringkasan Sistem'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                  title: 'Arsip Aktif',
                  value: '${sysSummary?.arsipAktif ?? 0}',
                  icon: Icons.folder_open_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArsipListScreen(filter: 'aktif'),
                      ),
                    );
                  }),
              StatCard(
                  title: _selectedPeriodLabel == 'Hari Ini'
                      ? 'Tamu Hari Ini'
                      : 'Total Tamu',
                  value: '${sysSummary?.tamuHariIni ?? 0}',
                  icon: Icons.badge_outlined,
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BukuTamuListScreen(),
                      ),
                    );
                  }),
              StatCard(
                  title: 'Surat Disposisi',
                  value: '${sysSummary?.menungguDisposisi ?? 0}',
                  icon: Icons.inbox_rounded,
                  color: AppTheme.warningColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DispositionListScreen(),
                      ),
                    );
                  }),
              StatCard(
                  title: 'Retensi Expired',
                  value: '${sysSummary?.retensiExpired ?? 0}',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.dangerColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ArsipListScreen(filter: 'expired'),
                      ),
                    );
                  }),
            ],
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Antrean Approval per Modul'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                  title: 'Surat Keluar',
                  value: '${stats.pendingSuratKeluar}',
                  icon: Icons.send_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(ApprovalCategory.outgoingLetter);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
              StatCard(
                  title: 'Peminjaman Arsip',
                  value: '${stats.pendingPeminjamanArsip}',
                  icon: Icons.folder_shared_rounded,
                  color: AppTheme.warningColor,
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(ApprovalCategory.archiveLoan);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
              StatCard(
                  title: 'Versi Dokumen',
                  value: '${stats.pendingVersiDokumen}',
                  icon: Icons.history_edu_rounded,
                  color: AppTheme.successColor,
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(ApprovalCategory.documentVersion);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
              StatCard(
                  title: 'Kunjungan Tamu',
                  value: '${stats.pendingBukuTamu}',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(ApprovalCategory.guestVisit);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
              StatCard(
                  title: 'Pemusnahan JRA',
                  value: '${stats.pendingPemusnahanArsip}',
                  icon: Icons.delete_sweep_rounded,
                  color: AppTheme.dangerColor,
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(
                            ApprovalCategory.destructionProposal);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
              StatCard(
                  title: 'Disposisi Aktif',
                  value: '${stats.totalDisposisiAktif}',
                  icon: Icons.move_to_inbox_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Provider.of<UnifiedApprovalProvider>(context, listen: false)
                        .setSelectedCategory(ApprovalCategory.disposition);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApprovalListScreen()));
                  }),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Tab Korespondensi
  Widget _buildCorrespondenceTab(
      BuildContext context, MultiDashboardProvider provider) {
    final stats = provider.correspondenceStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Dashboard Korespondensi'),
          const SizedBox(height: 4),
          Text('Statistik Surat Masuk, Surat Keluar & TTE',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                  title: 'Menunggu Approval',
                  value: '${stats.menungguApproval}',
                  icon: Icons.hourglass_top_rounded,
                  color: AppTheme.warningColor),
              StatCard(
                  title: 'Surat Disetujui',
                  value: '${stats.disetujui}',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.successColor),
              StatCard(
                  title: 'Surat Terkirim',
                  value: '${stats.terkirim}',
                  icon: Icons.mark_email_read_outlined,
                  color: AppTheme.primaryBlue),
              StatCard(
                  title: 'Surat Ditolak',
                  value: '${stats.ditolak}',
                  icon: Icons.cancel_outlined,
                  color: AppTheme.dangerColor),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Tab Arsip Dokumen
  Widget _buildArsipTab(BuildContext context, MultiDashboardProvider provider) {
    final stats = provider.arsipStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Dashboard Arsip Dokumen'),
          const SizedBox(height: 4),
          Text('Statistik Dokumen, Peminjaman & Retensi JRA',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                  title: 'Arsip Aktif',
                  value: '${stats.arsipAktif}',
                  icon: Icons.folder_rounded,
                  color: AppTheme.primaryBlue),
              StatCard(
                  title: 'Peminjaman Aktif',
                  value: '${stats.peminjamanAktif}',
                  icon: Icons.folder_open_rounded,
                  color: AppTheme.warningColor),
              StatCard(
                  title: 'Terlambat (Overdue)',
                  value: '${stats.peminjamanOverdue}',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.dangerColor),
              StatCard(
                  title: 'Usulan Pemusnahan',
                  value: '${stats.usulanPemusnahan}',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Tab Buku Tamu
  Widget _buildBukuTamuTab(
      BuildContext context, MultiDashboardProvider provider) {
    final stats = provider.bukuTamuStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Dashboard Buku Tamu'),
          const SizedBox(height: 4),
          Text('Statistik Kunjungan & Booking Tamu',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                  title: _selectedPeriodLabel == 'Hari Ini'
                      ? 'Kunjungan Hari Ini'
                      : 'Total Kunjungan',
                  value: '${stats.tamuHariIni}',
                  icon: Icons.people_rounded,
                  color: AppTheme.primaryBlue),
              StatCard(
                  title: 'Checked-in (Di Lokasi)',
                  value: '${stats.checkedIn}',
                  icon: Icons.login_rounded,
                  color: AppTheme.successColor),
              StatCard(
                  title: 'Checked-out',
                  value: '${stats.checkedOut}',
                  icon: Icons.logout_rounded,
                  color: AppTheme.textSecondary),
              StatCard(
                  title: 'Pending Approval',
                  value: '${stats.pendingApproval}',
                  icon: Icons.hourglass_empty_rounded,
                  color: AppTheme.warningColor),
            ],
          ),
        ],
      ),
    );
  }

  void _showBranchSwitcherBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Consumer<BranchProvider>(
          builder: (context, branchProv, _) {
            if (branchProv.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _HierarchicalBranchSheet(
              branchProv: branchProv,
              onBranchSelected: (branch) {
                branchProv.selectBranch(branch);
                Navigator.pop(context);
                _refreshAllData();
              },
            );
          },
        );
      },
    );
  }
}

// ─── Hierarchical Branch Sheet Widget ────────────────────────────────────────

class _HierarchicalBranchSheet extends StatefulWidget {
  final BranchProvider branchProv;
  final void Function(BranchModel?) onBranchSelected;

  const _HierarchicalBranchSheet({
    required this.branchProv,
    required this.onBranchSelected,
  });

  @override
  State<_HierarchicalBranchSheet> createState() =>
      _HierarchicalBranchSheetState();
}

class _HierarchicalBranchSheetState extends State<_HierarchicalBranchSheet> {
  // Navigation stack: null = root level
  final List<BranchModel?> _navStack = [null];

  BranchModel? get _currentParent => _navStack.last;

  List<BranchModel> get _currentChildren {
    if (_currentParent == null) {
      return widget.branchProv.rootBranches;
    }
    return widget.branchProv.childrenOf(_currentParent!.id);
  }

  bool get _isAtRoot => _navStack.length == 1;

  void _drillInto(BranchModel branch) {
    setState(() => _navStack.add(branch));
  }

  void _goBack() {
    if (!_isAtRoot) setState(() => _navStack.removeLast());
  }

  void _jumpToActiveBranchLocation() {
    final activeBranch = widget.branchProv.selectedBranch;
    if (activeBranch == null) return;
    final path = widget.branchProv.getBranchPath(activeBranch);
    if (path.length > 1) {
      setState(() {
        _navStack.clear();
        _navStack.add(null);
        for (int i = 0; i < path.length - 1; i++) {
          _navStack.add(path[i]);
        }
      });
    }
  }

  Widget _buildActiveOfficeBanner() {
    final activeBranch = widget.branchProv.selectedBranch;
    final activePath = widget.branchProv.selectedBranchPathText;
    final pathList = widget.branchProv.selectedBranchPath;

    if (activeBranch == null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.apartment_rounded,
                color: AppTheme.textSecondary, size: 16),
            SizedBox(width: 8),
            Text(
              'Kantor Aktif: Semua Cabang (Global)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryBlue,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Kantor Aktif: ',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    Flexible(
                      child: Text(
                        activeBranch.namaCabang,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (activePath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      'Jalur: $activePath',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade900.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (_isAtRoot && pathList.length > 1)
            InkWell(
              onTap: _jumpToActiveBranchLocation,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka Posisi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 9, color: AppTheme.primaryBlue),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.75;
    final selectedId = widget.branchProv.selectedBranch?.id;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: Row(
              children: [
                if (!_isAtRoot)
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: _goBack,
                    tooltip: 'Kembali',
                  )
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pindah Kantor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (!_isAtRoot && _currentParent != null)
                        Text(
                          _currentParent!.namaCabang,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Current Active Office Info Banner ────────────────────────
          _buildActiveOfficeBanner(),

          // ── Breadcrumb Trail ─────────────────────────────────────────
          if (_navStack.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _navStack.clear();
                        _navStack.add(null);
                      }),
                      child: const Text(
                        'Semua Cabang',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.primaryBlue),
                      ),
                    ),
                    ..._navStack.skip(1).map((b) {
                      final isLast = b == _navStack.last;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_right_rounded,
                              size: 14, color: AppTheme.textSecondary),
                          Text(
                            b?.namaCabang ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: isLast
                                  ? AppTheme.textPrimary
                                  : AppTheme.primaryBlue,
                              fontWeight:
                                  isLast ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),

          // ── "Semua Cabang" option (root only) ────────────────────────
          if (_isAtRoot)
            ListTile(
              leading: const Icon(Icons.business_rounded,
                  color: AppTheme.primaryBlue),
              title: const Text('Semua Cabang',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                'Tampilkan seluruh data tanpa filter kantor',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              trailing: selectedId == null
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                  : null,
              onTap: () => widget.onBranchSelected(null),
            ),

          // ── "Pilih kantor ini" option when drilling down ─────────────
          if (!_isAtRoot && _currentParent != null)
            _SelectCurrentTile(
              branch: _currentParent!,
              isSelected: selectedId == _currentParent!.id,
              onSelect: () => widget.onBranchSelected(_currentParent),
            ),

          if (!_isAtRoot) const Divider(height: 1),

          // ── List of children ─────────────────────────────────────────
          Flexible(
            child: _currentChildren.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Tidak ada sub-cabang',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _currentChildren.length,
                    itemBuilder: (context, index) {
                      final b = _currentChildren[index];
                      final isSelected = selectedId == b.id;
                      final hasKids = widget.branchProv.hasChildren(b.id);
                      final containsActive =
                          widget.branchProv.containsSelected(b.id);

                      // If this branch holds the active branch in its subtree (and is not selected itself)
                      final isParentOfActive = containsActive && !isSelected;

                      return Container(
                        margin: isParentOfActive
                            ? const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3)
                            : EdgeInsets.zero,
                        decoration: isParentOfActive
                            ? BoxDecoration(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.primaryBlue
                                      .withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              )
                            : null,
                        child: ListTile(
                          leading: Icon(
                            hasKids
                                ? (isParentOfActive
                                    ? Icons.account_tree_rounded
                                    : Icons.account_tree_outlined)
                                : Icons.location_on_outlined,
                            color: (isSelected || isParentOfActive)
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  b.namaCabang,
                                  style: TextStyle(
                                    fontWeight: (isSelected || isParentOfActive)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: (isSelected || isParentOfActive)
                                        ? AppTheme.primaryBlue
                                        : AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isParentOfActive)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Ada Kantor Aktif',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.green.shade300,
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    'Aktif',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: isParentOfActive
                              ? Text(
                                  'Cabang aktif: ${widget.branchProv.selectedBranch!.namaCabang}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : (hasKids
                                  ? const Text(
                                      'Ketuk untuk melihat sub-cabang',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary),
                                    )
                                  : null),
                          trailing: hasKids
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isParentOfActive)
                                      Container(
                                        width: 7,
                                        height: 7,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: (isSelected || isParentOfActive)
                                          ? AppTheme.primaryBlue
                                          : AppTheme.textSecondary,
                                    ),
                                  ],
                                )
                              : isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: AppTheme.primaryBlue)
                                  : null,
                          onTap: () {
                            if (hasKids) {
                              _drillInto(b);
                            } else {
                              widget.onBranchSelected(b);
                            }
                          },
                          onLongPress:
                              hasKids ? () => widget.onBranchSelected(b) : null,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Helper: "Pilih kantor ini" tile ─────────────────────────────────────────

class _SelectCurrentTile extends StatelessWidget {
  final BranchModel branch;
  final bool isSelected;
  final VoidCallback onSelect;

  const _SelectCurrentTile({
    required this.branch,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withValues(alpha: 0.08)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.4)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.business_rounded,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
        title: Text(
          'Pilih: ${branch.namaCabang}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
            fontSize: 13,
          ),
        ),
        subtitle: const Text(
          'Filter semua data dari kantor ini',
          style: TextStyle(fontSize: 11),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
            : const Icon(Icons.radio_button_unchecked_rounded,
                color: AppTheme.textSecondary, size: 20),
        onTap: onSelect,
      ),
    );
  }
}
