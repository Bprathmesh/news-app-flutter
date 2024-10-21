import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../models/notification.dart' as app_notification;
import '../services/push_notification_service.dart';

class AdminPanelPage extends StatefulWidget {
  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final PushNotificationService _notificationService = PushNotificationService();

  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationService.initialize();
    _generateDummyAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _generateDummyAnalyticsData() {
    final random = Random();
    setState(() {
      _analyticsData = {
        'appInstanceId': 'dummy-instance-id-${random.nextInt(1000)}',
        'userEngagement': random.nextInt(1000),
        'activeUsers': random.nextInt(500),
        'screenViews': random.nextInt(2000),
        'totalUsers': random.nextInt(10000),
        'averageSessionDuration': (random.nextDouble() * 10).toStringAsFixed(2),
        'bounceRate': '${random.nextInt(100)}%',
        'topCountries': ['USA', 'India', 'UK', 'Canada', 'Australia'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Users'),
            Tab(text: 'Analytics'),
            Tab(text: 'Send Notification'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(),
          _buildAnalyticsReport(),
          _buildNotificationSender(),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<AppUser> users = snapshot.data!.docs
            .map((doc) => AppUser.fromDocument(doc))
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            AppUser user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Text('Created: ${user.createdAt.toString().split(' ')[0]}'),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsReport() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildAnalyticsTile('App Instance ID', _analyticsData['appInstanceId'].toString()),
        _buildAnalyticsTile('User Engagement', _analyticsData['userEngagement'].toString()),
        _buildAnalyticsTile('Active Users', _analyticsData['activeUsers'].toString()),
        _buildAnalyticsTile('Screen Views', _analyticsData['screenViews'].toString()),
        _buildAnalyticsTile('Total Users', _analyticsData['totalUsers'].toString()),
        _buildAnalyticsTile('Avg. Session Duration', '${_analyticsData['averageSessionDuration']} minutes'),
        _buildAnalyticsTile('Bounce Rate', _analyticsData['bounceRate'].toString()),
        _buildAnalyticsTile('Top Countries', _analyticsData['topCountries'].join(', ')),
        ElevatedButton(
          onPressed: _generateDummyAnalyticsData,
          child: Text('Refresh Analytics'),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildNotificationSender() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Notification Title'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(labelText: 'Notification Body'),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _sendNotification,
            child: Text('Send Notification'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both title and body')),
      );
      return;
    }

    try {
      // Add notification to Firestore
      await _firestore.collection('notifications').add({
        'title': _titleController.text,
        'body': _bodyController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification sent successfully')),
      );

      // Clear the text fields
      _titleController.clear();
      _bodyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification: $e')),
      );
    }
  }
}