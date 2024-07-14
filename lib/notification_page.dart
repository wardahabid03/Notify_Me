import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notify_me/main.dart';
import 'database_helper.dart';

class NotificationPage extends StatefulWidget {
  final Map<String, dynamic>? notification;

  NotificationPage({this.notification});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late DateTime _scheduledDate;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notification?['title'] ?? '');
    _bodyController = TextEditingController(text: widget.notification?['body'] ?? '');
    _scheduledDate = widget.notification != null
        ? DateFormat('dd-MM-yyyy hh:mm a').parse(widget.notification!['datetime'])
        : DateTime.now();
  }

  Future<void> _scheduleNotification(String title, String body, DateTime scheduledDate) async {
    // Formatting the scheduled date in 12-hour format with AM/PM
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(scheduledDate);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    int notificationId = widget.notification?['id'] ??
        await _databaseHelper.insertNotification({
          'title': title,
          'body': body,
          'datetime': formattedDateTime, // Store formatted date in the database
        });

    await flutterLocalNotificationsPlugin.schedule(
      notificationId,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
    );

    if (widget.notification != null) {
      await _databaseHelper.updateNotification({
        'id': notificationId,
        'title': title,
        'body': body,
        'datetime': formattedDateTime, // Update formatted date in the database
      });
    }
  }

  void _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
      );
      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notification != null ? 'Edit Notification' : 'Add Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Color.fromARGB(255, 6, 91, 83)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Body',
                labelStyle: TextStyle(color: Color.fromARGB(255, 6, 91, 83)),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notification Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(_scheduledDate)}',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Color.fromARGB(255, 6, 91, 83)),
                  onPressed: () => _selectDateTime(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _scheduleNotification(
                  _titleController.text,
                  _bodyController.text,
                  _scheduledDate,
                ).then((_) {
                  Navigator.pop(context, true);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 6, 91, 83),
              ),
              child: Text(widget.notification != null ? 'Update Notification' : 'Add Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
 