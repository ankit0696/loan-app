import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/notification.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('app_logo');

  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  // get notification permission
  Future<void> getNotificationPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool permissionAsked =
        prefs.getBool('notification_permission_asked') ?? false;
    // ask only once for permission
    if (permissionAsked == false) {
      // use permission handler to get permission
      try {
        PermissionStatus status = await Permission.notification.status;
        if (status.isGranted) {
          print('Notification permission granted');
        } else {
          print('Notification permission denied');
          Permission.notification.request();
        }
      } catch (e) {
        print(e);
      }

      // save permission asked
      prefs.setBool('notification_permission_asked', true);
    }
  }

  // initialize notification
  void initializeNotification() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  // send notification
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    // get notification id from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationId = prefs.getInt('notification_id') ?? -1;

    if (notificationId == -1) {
      // get count from firebase and set notification id
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      await notificationDetails(),
    );
  }

  // schedule notification
  Future scheduleNotification(
    int id, {
    String? title,
    String? body,
    required DateTime scheduledDate,
  }) async {
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    return flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future predocallySetNotification(
    int id, {
    String? title,
    String? body,
    String? payLoad,
  }) async {
    print("yess");
    return flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      await notificationDetails(),
    );
  }

  Future<void> scheduleMonthlyRepeatingNotification({
    String? title,
    String? body,
    required DateTime initialScheduledDate,
    required NotificationModel notificationModel,
    required LoanModel data,
  }) async {
    // Calculate the initial time for the first notification on the first day of the month at 10 AM
    var initialTime = DateTime(
      initialScheduledDate.year,
      initialScheduledDate.month,
      initialScheduledDate.day, // Set the day to 1 (first day of the month)
      10, // Set the hour to 10 (10 AM)
      0, // Set the minute to 0 (on the hour)
    );

    int notificationCount = await FirestoreService().countNotification();

    for (int i = 0; i < 12; i++) {
      print("yes $initialTime");

      notificationModel.notificationId = notificationCount + 1;
      await FirestoreService().addNotification(
        notificationModel,
        data,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationCount++,
        title! + initialTime.toString(),
        body,
        tz.TZDateTime.from(initialTime, tz.local),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Calculate the time for the next month (1 month later), considering year change
      int nextMonth = initialTime.month + 1;
      int nextYear = initialTime.year;

      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      initialTime = DateTime(
        nextYear,
        nextMonth,
        initialScheduledDate.day, // Set the day to 1 (first day of the month)
        10, // Set the hour to 10 (10 AM)
        0, // Set the minute to 0 (on the hour)
      );

      print("yes");
    }
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
