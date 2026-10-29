import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final data = await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notif) async {
    if (notif.isRead) return;
    
    // Update UI immediately (optimistic update)
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notif.id);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          type: notif.type,
          isRead: true,
          createdAt: notif.createdAt,
          link: notif.link,
        );
      }
    });

    await _notificationService.markAsRead(notificationId: notif.id);
  }

  Future<void> _markAllAsRead() async {
    setState(() => _isLoading = true);
    await _notificationService.markAsRead(); // null ID means all
    await _fetchNotifications();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'surat_masuk':
      case 'surat_keluar':
        return Icons.mark_email_unread_outlined;
      case 'disposisi':
        return Icons.assignment_outlined;
      case 'kunjungan':
      case 'tamu':
        return Icons.people_alt_outlined;
      case 'sistem':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Baru saja';
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoft,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: AppTheme.primaryBlue,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderSubtle),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return _buildNotificationTile(notif);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Notifikasi Baru',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Setiap permohonan persetujuan surat keluar, disposisi, atau aktivitas tamu baru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notif) {
    final isUnread = !notif.isRead;

    return InkWell(
      onTap: () => _markAsRead(notif),
      child: Container(
        color: isUnread ? AppTheme.primaryBlue.withValues(alpha: 0.05) : AppTheme.surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notif.type),
                size: 22,
                color: isUnread ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: isUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.dangerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isUnread ? AppTheme.textPrimary.withValues(alpha: 0.85) : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notif.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
