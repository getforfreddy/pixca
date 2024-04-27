import 'package:flutter/material.dart';

class NotificationSample extends StatefulWidget {
  const NotificationSample({super.key});

  @override
  State<NotificationSample> createState() => _NotificationSampleState();
}

class _NotificationSampleState extends State<NotificationSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
    );
  }
}
