import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Callback được gọi khi người dùng tap vào notification
typedef NotificationTapCallback = void Function(int id, String? payload);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Callback tùy chỉnh khi tap notification
  static NotificationTapCallback? onNotificationTap;

  static Future<void> init() async {
    tz.initializeTimeZones();

    // Đặt timezone theo múi giờ Việt Nam
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // giữ UTC nếu không tìm thấy
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.id ?? 0, response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );

    // Xin quyền thông báo trên Android 13+
    await _requestPermissions();
  }

  /// Xin quyền gửi thông báo (Android 13+, iOS)
  static Future<void> _requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Hiển thị notification ngay lập tức
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(id, title, body, _buildDetails(), payload: payload);
  }

  /// Đặt lịch thông báo theo giờ cụ thể
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Hủy thông báo theo id
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Hủy tất cả thông báo
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Lấy danh sách notification đã lên lịch
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static NotificationDetails _buildDetails() {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'todo_reminders',
      'Nhắc nhở công việc',
      channelDescription: 'Thông báo nhắc nhở khi đến giờ công việc',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }
}

/// Background handler – phải là top-level function
@pragma('vm:entry-point')
void _onBackgroundNotification(NotificationResponse response) {
  // Không làm gì – notification đã hiển thị
}

/// Helper widget: hiển thị in-app banner khi nhận notification
class InAppNotificationOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotificationOverlay({super.key, required this.child});

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<InAppNotificationOverlay>
    with TickerProviderStateMixin {
  OverlayEntry? _entry;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Lắng nghe notification tap để mở task (tùy mở rộng sau)
    NotificationService.onNotificationTap = (id, payload) {
      _showBanner('Nhắc nhở', payload ?? 'Đến lúc làm công việc rồi!');
    };
  }

  void _showBanner(String title, String body) {
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        title: title,
        body: body,
        onDismiss: () {
          _entry?.remove();
          _entry = null;
        },
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Banner nổi hiển thị ở đầu màn hình
class _NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Tự ẩn sau 4 giây
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slide,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              if (d.primaryVelocity! < 0) _dismiss();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
