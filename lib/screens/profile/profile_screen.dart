import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Ambil inisial nama
    final initials = (user?.fullName ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Gradient Biru ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                children: [
                  // Avatar lingkaran dengan inisial
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.50), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Pejabat Approver',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.role ?? 'Approver',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.branchName ?? 'Kantor Pusat',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Akun ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildSection(
                children: [
                  _infoTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Username',
                    value: user?.username ?? '-',
                  ),
                  _divider(),
                  _infoTile(
                    icon: Icons.location_city_outlined,
                    label: 'Cabang / Unit Kerja',
                    value: user?.branchName ?? 'Kantor Pusat / Semua Cabang',
                  ),
                  _divider(),
                  _infoTile(
                    icon: Icons.dns_outlined,
                    label: 'API Server',
                    value: ApiConfig.baseUrl,
                  ),
                  _divider(),
                  _infoTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Versi Aplikasi',
                    value: 'v1.0.0 (Build 1)',
                  ),
                ],
              ),
            ),

            // ── Menu List ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildSection(
                children: [
                  _menuTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Ubah Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.notifications_outlined,
                    label: 'Pengaturan Notifikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                      );
                    },
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Bantuan & Dukungan',
                    onTap: () {},
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Tentang Aplikasi',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ── Tombol Keluar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerColor,
                    side: const BorderSide(color: AppTheme.dangerColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Keluar dari Aplikasi'),
                  onPressed: () => _showLogoutDialog(context, authProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.only(left: 50),
        child: Divider(height: 1, color: AppTheme.borderSubtle),
      );

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Aplikasi'),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        content: Text(
          'Yakin ingin keluar dari aplikasi? Anda harus masuk kembali untuk mengakses data.',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // Batal — outline
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(height: 8),
          // Ya, Keluar — solid merah
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(44),
                textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Ya, Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}
