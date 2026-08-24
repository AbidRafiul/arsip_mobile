import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multi_dashboard_provider.dart';
import '../approval/approval_list_screen.dart';
import '../disposition/disposition_list_screen.dart';
import '../profile/profile_screen.dart';

import '../../providers/dashboard_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Provider.of<MultiDashboardProvider>(context, listen: false)
            .setSelectedModuleIndex(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MultiDashboardProvider>(context, listen: false)
          .fetchDashboardData();
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    await Future.wait([
      Provider.of<MultiDashboardProvider>(context, listen: false).refreshAll(),
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboardData(),
    ]);
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
            Text(
              user?.role ?? 'Approver',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {},
              ),
              // Badge notifikasi
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
          // Banner Total Pending — gradient biru
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pusat Persetujuan Eksekutif',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Text(
                  '${stats.grandTotalPending}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800),
                ),
                const Text('Permohonan Menunggu Tindakan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text(
                  'Daftar permohonan dari seluruh modul yang memerlukan persetujuan Anda.',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
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
                  color: AppTheme.primaryBlue),
              StatCard(
                  title: 'Tamu Hari Ini',
                  value: '${sysSummary?.tamuHariIni ?? 0}',
                  icon: Icons.badge_outlined,
                  color: AppTheme.successColor),
              StatCard(
                  title: 'Surat Disposisi',
                  value: '${sysSummary?.menungguDisposisi ?? 0}',
                  icon: Icons.inbox_rounded,
                  color: AppTheme.warningColor),
              StatCard(
                  title: 'Retensi Expired',
                  value: '${sysSummary?.retensiExpired ?? 0}',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.dangerColor),
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
                  color: AppTheme.primaryBlue),
              StatCard(
                  title: 'Peminjaman Arsip',
                  value: '${stats.pendingPeminjamanArsip}',
                  icon: Icons.folder_shared_rounded,
                  color: AppTheme.warningColor),
              StatCard(
                  title: 'Versi Dokumen',
                  value: '${stats.pendingVersiDokumen}',
                  icon: Icons.history_edu_rounded,
                  color: AppTheme.successColor),
              StatCard(
                  title: 'Kunjungan Tamu',
                  value: '${stats.pendingBukuTamu}',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF3B82F6)),
              StatCard(
                  title: 'Pemusnahan JRA',
                  value: '${stats.pendingPemusnahanArsip}',
                  icon: Icons.delete_sweep_rounded,
                  color: AppTheme.dangerColor),
              StatCard(
                  title: 'Disposisi Aktif',
                  value: '${stats.totalDisposisiAktif}',
                  icon: Icons.move_to_inbox_rounded,
                  color: const Color(0xFF7C3AED)),
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
                  title: 'Kunjungan Hari Ini',
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
}
