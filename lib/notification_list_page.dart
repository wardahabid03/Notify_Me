import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'notification_page.dart';
import 'ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notifications = [];
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    AdHelper.initialize(); // Initialize the Mobile Ads SDK
    AdHelper.loadInterstitialAd(); // Load the interstitial ad
  }

  void _loadNotifications() async {
    List<Map<String, dynamic>> notifications = await _databaseHelper.queryAllNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  void _deleteNotification(int id) async {
    await _databaseHelper.deleteNotification(id);
    _loadNotifications();

    setState(() {
      _showAd = true;
    });

    AdHelper.showInterstitialAd(() {
      setState(() {
        _showAd = false;
      });
    });
  }

  void _editNotification(Map<String, dynamic> notification) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(notification: notification),
      ),
    );

    if (result != null) {
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notifications'),
        backgroundColor: Color.fromARGB(255, 6, 91, 83),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 40), // Icon color and size
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/addNotification');
              if (result != null) {
                _loadNotifications();
              }
            },
            splashRadius: 24, // Adjust splash radius for ripple effect
            padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 30), // Adjust padding for spacing around icon
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _notifications.isEmpty
                ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Text(
                        "Press on the '+' icon above to shedule a Notification",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                notification['title'] ?? 'No Title',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${notification['body'] ?? 'No Body'}',
                                      style: TextStyle(color: Colors.black.withOpacity(0.9)),
                                    ),
                                    Text(
                                      'Time: ${notification['datetime'] ?? 'No Date'}',
                                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Color.fromARGB(255, 6, 91, 83)),
                                    onPressed: () => _editNotification(notification),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () => _deleteNotification(notification['id']),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Color.fromARGB(112, 158, 158, 158),
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
