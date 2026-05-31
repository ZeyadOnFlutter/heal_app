import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background handler — must be top-level for FCM isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification == null) {
    await NotificationService.showNotification(message);
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Attach to MaterialApp so we can navigate without a BuildContext.
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const _channelId = 'heal_app_channel';
  static const _channelName = 'Heal App Notifications';

  // Registered from main.dart to avoid circular imports.
  Widget Function({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  })? _chatBuilder;

  Widget Function()? _feedbackBuilder;

  void registerChatScreenBuilder(
    Widget Function({
      required String currentUserId,
      required String currentUserName,
      required String otherUserId,
      required String otherUserName,
    }) builder,
  ) =>
      _chatBuilder = builder;

  void registerFeedbackScreenBuilder(Widget Function() builder) =>
      _feedbackBuilder = builder;

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermissions();
    await _setupLocalNotifications();

    // Token is saved after login via saveFcmToken(role:) called from main.dart.
    _messaging.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _saveToken(token);
    });
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _onTap(initial),
      );
    }
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── Local notifications ──────────────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _navigate(jsonDecode(details.payload!) as Map<String, dynamic>);
        }
      },
    );
  }

  // ── Token ────────────────────────────────────────────────────────────────────

  Future<void> saveFcmToken({required String role}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'fcm_token': token}, SetOptions(merge: true));
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  Future<void> _onForeground(RemoteMessage message) async {
    // Don't show notification to the sender — only the receiver should see it.
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final senderId = message.data['sender_id'] as String?;
    if (currentUid != null && senderId == currentUid) return;
    if (message.notification != null) return;
    await showNotification(message);
  }

  void _onTap(RemoteMessage message) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final senderId = message.data['sender_id'] as String?;
    if (currentUid != null && senderId == currentUid) return;
    _navigate(message.data);
  }

  // ── Show notification (static so background isolate can call it) ─────────────

  static Future<void> showNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? _title(message.data);
    final body = message.notification?.body ?? _body(message.data);

    await FlutterLocalNotificationsPlugin().show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _navigate(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final type = data['type'] as String?;

    if (type == 'chat') {
      final senderId = data['sender_id'] as String? ?? '';
      final senderName = data['sender_name'] as String? ?? 'User';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      final screen = _chatBuilder?.call(
        currentUserId: uid,
        currentUserName: 'Me',
        otherUserId: senderId,
        otherUserName: senderName,
      );
      if (screen != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      }
    } else if (type == 'feedback') {
      final screen = _feedbackBuilder?.call();
      if (screen != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static String _title(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'chat':
        return 'New Message';
      case 'feedback':
        return 'Doctor Feedback';
      default:
        return 'Heal App';
    }
  }

  static String _body(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'chat':
        return 'You have a new message';
      case 'feedback':
        return 'Your doctor added feedback to your screening';
      default:
        return '';
    }
  }
}
