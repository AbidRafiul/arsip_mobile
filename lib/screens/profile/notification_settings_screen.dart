import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../core/storage/secure_storage.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _approvalReminders = true;
  bool _guestArrivals = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final push = await SecureStorageService.getSetting('notif_push') ?? 'true';
    final email = await SecureStorageService.getSetting('notif_email') ?? 'false';
    final approval = await SecureStorageService.getSetting('notif_approval') ?? 'true';
    final guest = await SecureStorageService.getSetting('notif_guest') ?? 'true';

    if (mounted) {
      setState(() {
        _pushNotifications = push == 'true';
        _emailNotifications = email == 'true';
        _approvalReminders = approval == 'true';
        _guestArrivals = guest == 'true';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    await SecureStorageService.saveSetting(key, value.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.surfaceSoft,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola preferensi notifikasi Anda. Pengaturan ini hanya berlaku pada perangkat ini.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'Notifikasi Utama',
              children: [
                _buildSwitchTile(
                  title: 'Push Notifications (Sistem)',
                  subtitle: 'Terima notifikasi langsung di layar HP Anda',
                  icon: Icons.notifications_active_outlined,
                  value: _pushNotifications,
                  onChanged: (val) {
                    setState(() => _pushNotifications = val);
                    _saveSetting('notif_push', val);
                  },
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Notifikasi Email',
                  subtitle: 'Kirim rekap aktivitas penting ke email Anda',
                  icon: Icons.email_outlined,
                  value: _emailNotifications,
                  onChanged: (val) {
                    setState(() => _emailNotifications = val);
                    _saveSetting('notif_email', val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'Notifikasi Modul',
              children: [
                _buildSwitchTile(
                  title: 'Pengingat Approval',
                  subtitle: 'Pemberitahuan bila ada dokumen yang menunggu persetujuan',
                  icon: Icons.assignment_turned_in_outlined,
                  value: _approvalReminders,
                  onChanged: _pushNotifications ? (val) {
                    setState(() => _approvalReminders = val);
                    _saveSetting('notif_approval', val);
                  } : null,
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Kedatangan Tamu',
                  subtitle: 'Pemberitahuan saat tamu melakukan check-in di lobi',
                  icon: Icons.people_alt_outlined,
                  value: _guestArrivals,
                  onChanged: _pushNotifications ? (val) {
                    setState(() => _guestArrivals = val);
                    _saveSetting('notif_guest', val);
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: onChanged == null ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.primaryBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onChanged == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(onChanged == null ? 0.5 : 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.only(left: 56),
        child: Divider(height: 1, color: AppTheme.borderSubtle),
      );
}
