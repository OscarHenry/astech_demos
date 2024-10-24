import 'package:astech_demo/local_notification_manager.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM with Local Notifications'),
      ),
      body: StreamBuilder(
        stream: LocalNotificationManager.selectNotificationStream.stream,
        builder: (context, notification) => SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AnimatedSwitcher(
                duration: kThemeAnimationDuration,
                child: (notification.data != null)
                    ? Text(
                        'Notification Data:\n${notification.data}',
                        style: textStyle,
                      )
                    : Text(
                        'No notification tapped',
                        style: textStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          LocalNotificationManager.showNotification();
        },
        tooltip: 'Show Local notification',
        label: const Text('Local'),
        icon: const Icon(Icons.notifications),
      ),
    );
  }
}
