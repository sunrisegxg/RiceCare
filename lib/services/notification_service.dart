import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 🔥 INIT
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: settings);

    // 🔥 xin quyền exact alarm (Android 12+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  // 🔔 CHECK ENABLED
  static Future<bool> isEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.areNotificationsEnabled() ?? false;
  }

  // 🔐 REQUEST PERMISSION (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.requestNotificationsPermission() ?? false;
  }

  // ⚙️ OPEN SETTINGS
  static void openSettings() {
    AppSettings.openAppSettings();
  }

  // 🔥 SCHEDULE NOTIFICATION
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime notifyTime,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(notifyTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'planner_channel',
          'Planner Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // 🗑 CANCEL NOTIFICATION
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}
