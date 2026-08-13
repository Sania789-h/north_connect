import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  String? _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Emergency Alert',
    'Weather',
    'Road Alert',
    'Network',
    'SOS',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await _service.initialize();
    final results = await Future.wait([
      _service.getNotifications(category: _selectedCategory),
      _service.getUnreadCount(),
    ]);
    if (mounted) {
      setState(() {
        _notifications = results[0] as List<NotificationModel>;
        _unreadCount = results[1] as int;
        _isLoading = false;
      });
    }
  }

  Future<void> _onMarkAsRead(NotificationModel n) async {
    if (n.isRead) return;
    await _service.markAsRead(n.id!);
    if (!mounted) return;
    Helpers.showSnackBar(context, 'Marked as read');
    _loadAll();
  }

  Future<void> _onMarkAllRead() async {
    if (_unreadCount == 0) {
      Helpers.showSnackBar(context, 'No unread notifications');
      return;
    }
    await _service.markAllAsRead();
    if (!mounted) return;
    Helpers.showSnackBar(context, 'All notifications marked as read');
    _loadAll();
  }

  Future<void> _onDelete(NotificationModel n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Notification?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This notification will be permanently deleted.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteNotification(n.id!);
      if (!mounted) return;
      Helpers.showSnackBar(context, 'Notification deleted');
      _loadAll();
    }
  }

  void _onTapNotification(NotificationModel n) {
    if (!n.isRead) {
      _onMarkAsRead(n);
    }
    _showDetailsBottomSheet(n);
  }

  void _showDetailsBottomSheet(NotificationModel n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final handleColor = isDark ? const Color(0xFF475569) : Colors.grey[300];

    final catInfo = _categoryConfig(n.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: catInfo.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(catInfo.icon, color: catInfo.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.category,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: catInfo.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(n.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        Navigator.pop(ctx);
                        if (val == 'read') _onMarkAsRead(n);
                        if (val == 'delete') _onDelete(n);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              Icon(Icons.done_all_rounded,
                                  size: 18,
                                  color: n.isRead
                                      ? AppColors.textSecondary
                                      : AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                n.isRead ? 'Already Read' : 'Mark as Read',
                                style: GoogleFonts.outfit(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          n.description,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.category_rounded, 'Category', n.category, isDark, sheetBg),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        'Received',
                        _formatDateTimeFull(n.createdAt),
                        isDark,
                        sheetBg,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        n.isRead
                            ? Icons.mark_email_read_rounded
                            : Icons.mark_email_unread_rounded,
                        'Status',
                        n.isRead ? 'Read' : 'Unread',
                        isDark,
                        sheetBg,
                        statusColor: n.isRead ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark, Color sheetBg, {Color? statusColor}) {
    final rowBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);
    final innerIconBg = isDark ? const Color(0xFF111827) : AppColors.background;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rowBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: innerIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F2C59);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final iconBtnBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final btnBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);
    final chipUnselectedBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final chipUnselectedText = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final tertiaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    final timeTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400];
    final unreadCardBg = isDark ? const Color(0xFF052E1C) : const Color(0xFFF0FDF4);
    final unreadCardBorder = isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.08);
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);
    final cardShadow = isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.03);
    final moreIconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, cardBg, textPrimary, textSecondary, iconBtnBg, btnBorderColor, tertiaryText),
            _buildCategoryChips(isDark, cardBg, chipUnselectedBorder, chipUnselectedText),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingWidget())
                  : _notifications.isEmpty
                      ? _buildEmptyState(isDark, textPrimary, textSecondary)
                      : RefreshIndicator(
                          onRefresh: _loadAll,
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) =>
                                _buildNotificationCard(_notifications[i], isDark, cardBg, unreadCardBg, unreadCardBorder, cardBorderColor, cardShadow, moreIconColor, timeTextColor),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color cardBg, Color textPrimary, Color textSecondary, Color iconBtnBg, Color btnBorderColor, Color tertiaryText) {
    final iconColor = isDark ? Colors.white : const Color(0xFF0F2C59);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Helpers.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: iconBtnBg,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: btnBorderColor),
              ),
            ),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                Text(
                  _unreadCount > 0
                      ? '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}'
                      : 'No new notifications',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Mark all as read',
            child: IconButton(
              onPressed: _onMarkAllRead,
              style: IconButton.styleFrom(
                backgroundColor: _unreadCount > 0
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : iconBtnBg,
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: btnBorderColor),
                ),
              ),
              icon: Icon(
                Icons.done_all_rounded,
                size: 22,
                color: _unreadCount > 0
                    ? AppColors.primary
                    : tertiaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark, Color cardBg, Color unselectedBorder, Color unselectedText) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          final count = cat == 'All'
              ? _notifications.length
              : _notifications.where((n) => n.category == cat).length;
          final catIcon = cat == 'All' ? Icons.filter_list_rounded : _categoryConfig(cat).icon;
          final catColor = cat == 'All' ? AppColors.primary : _categoryConfig(cat).color;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _loadAll();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? catColor : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? catColor : unselectedBorder,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: catColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    catIcon,
                    size: 14,
                    color: isSelected ? Colors.white : catColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : unselectedText,
                    ),
                  ),
                  if (isSelected || count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : catColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n, bool isDark, Color cardBg, Color unreadBg, Color unreadBorder, Color cardBorder, Color cardShadow, Color moreIcon, Color? timeColor) {
    final catConfig = _categoryConfig(n.category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTapNotification(n),
        borderRadius: BorderRadius.circular(18),
        splashColor: catConfig.color.withValues(alpha: 0.08),
        child: Dismissible(
          key: Key('notif-${n.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 26),
          ),
          onDismissed: (_) => _service.deleteNotification(n.id!).then((_) {
            if (!mounted) return;
            _loadAll();
            Helpers.showSnackBar(context, 'Notification deleted');
          }),
          confirmDismiss: (_) async {
            _onDelete(n);
            return false;
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.isRead ? cardBg : unreadBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: n.isRead
                    ? cardBorder
                    : unreadBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: catConfig.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(catConfig.icon, color: catConfig.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color:
                                        catConfig.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    n.category,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: catConfig.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (!n.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 160, maxWidth: 200),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              if (val == 'read') _onMarkAsRead(n);
                              if (val == 'delete') _onDelete(n);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'read',
                                enabled: !n.isRead,
                                child: Row(
                                  children: [
                                    Icon(Icons.done_rounded,
                                        size: 17,
                                        color: n.isRead
                                            ? AppColors.textSecondary
                                            : AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      n.isRead ? 'Already Read' : 'Mark as Read',
                                      style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 17, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: moreIcon,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: timeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(n.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: timeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _selectedCategory == 'All'
                  ? 'No notifications yet'
                  : 'No $_selectedCategory notifications',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! New updates will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCategory != 'All')
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _selectedCategory = 'All');
                    _loadAll();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'View All Notifications',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _CatConfig _categoryConfig(String category) {
    switch (category) {
      case 'Emergency Alert':
        return _CatConfig(
          Icons.local_police_rounded,
          const Color(0xFFDC2626),
        );
      case 'Weather':
        return _CatConfig(
          Icons.wb_cloudy_rounded,
          const Color(0xFF0284C7),
        );
      case 'Road Alert':
        return _CatConfig(
          Icons.alt_route_rounded,
          const Color(0xFFD97706),
        );
      case 'Network':
        return _CatConfig(
          Icons.cell_tower_rounded,
          const Color(0xFF059669),
        );
      case 'SOS':
        return _CatConfig(
          Icons.sos_rounded,
          const Color(0xFF7C3AED),
        );
      default:
        return _CatConfig(
          Icons.notifications_rounded,
          AppColors.primary,
        );
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDateTimeFull(DateTime? dt) {
    if (dt == null) return '';
    final months = const [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $h:$m';
  }
}

class _CatConfig {
  final IconData icon;
  final Color color;
  _CatConfig(this.icon, this.color);
}
