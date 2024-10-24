import 'dart:developer';

import 'package:astech_demo/firebase_options.dart';
import 'package:astech_demo/local_notification_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  log("Handling a background message: ${message.messageId}");
}

class PushNotificationManager {
  PushNotificationManager._();

  factory PushNotificationManager() => _instance;

  static final PushNotificationManager _instance = PushNotificationManager._();

  static final FirebaseMessaging fcm = FirebaseMessaging.instance;

  String? _token;
  String? get token => _token;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // await fcm.setAutoInitEnabled(true);

    _token = await fcm.getToken();
    log('$_token', name: 'fcmToken');

    _subscribeToOnTokenRefresh();

    // request permissions if not granted
    await _requestPermissions();

    _subscribeToOnForegroundMessage();

    _subscribeToOnBackgroundMessage();
  }

  void _subscribeToOnBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _subscribeToOnForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_firebaseMessagingOnMessageHandler);
  }

  Future<void> _firebaseMessagingOnMessageHandler(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
      final notification = message.notification!;
      await LocalNotificationManager.showNotification(
        title: '${notification.title}',
        body: '${notification.body}',
        payload: '${notification.toMap()}',
      );
    }
  }

  Future<void> _requestPermissions() async {
    final NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');
  }

  void _subscribeToOnTokenRefresh() {
    fcm.onTokenRefresh.listen((fcmToken) {
      _token = fcmToken;
      log('fcmToken: $fcmToken', name: 'onTokenRefresh');
    }).onError((err) {
      // Error getting token.
      log('Error: $err', name: 'onTokenRefresh');
    });
  }
}
