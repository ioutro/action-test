import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/collaborator.dart';

abstract interface class INotificationService {
  Future<void> init();
  Future<void> showNotificationWithColaborator(Collaborator colaborator);
}

class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  final details = const NotificationDetails(
    android: AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      icon: '@mipmap/ic_launcher',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      showWhen: true,
    ),
  );

  @override
  Future<void> init() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == 'sdf') {}
            break;
        }
      },
    );
  }

  @override
  Future<void> showNotificationWithColaborator(
      Collaborator collaborator) async {
    await flutterLocalNotificationsPlugin.show(
      collaborator.personalId, // Unique id for the notification
      'Colaborator Info',
      'Name: ${collaborator.name}, ID: ${collaborator.personalId}',
      details,
      payload: 'payload test',
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
