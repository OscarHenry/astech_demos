import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  log(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
    name: 'notificationTapBackground',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    log(
      'notification action tapped with input: ${notificationResponse.input}',
      name: 'notificationTapBackground',
    );
  }
}

class LocalNotificationManager {
  static final LocalNotificationManager _instance =
      LocalNotificationManager._internal();

  factory LocalNotificationManager() {
    return _instance;
  }

  LocalNotificationManager._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  /// A notification action which triggers a url launch event
  static const String urlLaunchActionId = 'id_1';

  /// A notification action which triggers a App navigation event
  static const String navigationActionId = 'id_3';

  /// Defines a iOS/MacOS notification category for text input actions.
  static const String darwinNotificationCategoryText = 'textCategory';

  /// Defines a iOS/MacOS notification category for plain actions.
  static const String darwinNotificationCategoryPlain = 'plainCategory';

  static int id = 0;

  String? selectedNotificationPayload;

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> init() async {
    try {
      await _configureLocalTimeZone();

      // final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      //     !kIsWeb && Platform.isLinux
      //         ? null
      //         : await flutterLocalNotificationsPlugin
      //             .getNotificationAppLaunchDetails();
      // String initialRoute = HomePage.routeName;
      // if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      //   selectedNotificationPayload =
      //       notificationAppLaunchDetails!.notificationResponse?.payload;
      //   initialRoute = SecondPage.routeName;
      // }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final List<DarwinNotificationCategory> darwinNotificationCategories =
          <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text(
              'text_1',
              'Action 1',
              buttonTitle: 'Send',
              placeholder: 'Placeholder',
            ),
          ],
        ),
        DarwinNotificationCategory(
          darwinNotificationCategoryPlain,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2 (destructive)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              navigationActionId,
              'Action 3 (foreground)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'id_4',
              'Action 4 (auth required)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.authenticationRequired,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ];

      /// Note: permissions aren't requested here just to demonstrate that can be
      /// done later
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: darwinNotificationCategories,
      );

      // final LinuxInitializationSettings initializationSettingsLinux =
      //     LinuxInitializationSettings(
      //   defaultActionName: 'Open notification',
      //   defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
      // );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        // macOS: initializationSettingsDarwin,
        // linux: initializationSettingsLinux,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> showNotification({
    String title = 'Title',
    String body = 'Body',
    String channelId = 'channelId',
    String channelName = 'channelName',
    String icon = '@mipmap/ic_launcher',
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool showWhen = false,
    String? payload,
  }) async {
    // show a notification

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      icon: icon,
      importance: importance,
      priority: priority,
      showWhen: showWhen,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      id += 1,
      title,
      body,
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      ),
      payload: payload,
    );
  }

  /// used to handle the tap on the notification
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final message = 'id: ${notificationResponse.id}, '
        'actionId: ${notificationResponse.actionId}, '
        'input ${notificationResponse.input}, '
        'payload: ${notificationResponse.payload}, '
        'type: ${notificationResponse.notificationResponseType}';
    log(message, name: 'onDidReceiveNotificationResponse');
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        selectNotificationStream.add(message);
        break;
      case NotificationResponseType.selectedNotificationAction:
        if (notificationResponse.actionId == navigationActionId) {
          selectNotificationStream.add(message);
        }
        break;
    }
  }
}
