import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:campuseats/core/config/app_config.dart';
import 'package:campuseats/core/storage/secure_token_storage.dart';
import 'package:campuseats/core/utils/app_logger.dart';

/// Service de notifications push FCM + affichage au premier plan.
/// Fonctionne sans crash même si Firebase (`google-services.json`) n'est pas encore configuré.
class PushService {
  PushService({
    required AppConfig config,
    required TokenStorage tokenStorage,
    required Dio dio,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _dio = dio;

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final Dio _dio;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseReady = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;
  void Function(String route)? _onNavigate;

  Future<void> initialize({
    required void Function(String route) onNavigate,
  }) async {
    _onNavigate = onNavigate;
    if (_initialized) return;
    _initialized = true;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit),
        onDidReceiveNotificationResponse: (details) {
          final route = details.payload;
          if (route != null && route.isNotEmpty) {
            _onNavigate?.call(route);
          }
        },
      );
    } catch (e) {
      appLogger.w('Local notifications non disponibles: $e');
    }

    if (_config.useMocks) {
      appLogger.i('PushService en mode mock (Firebase ignoré).');
      return;
    }

    try {
      await Firebase.initializeApp();
      _firebaseReady = true;

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleTap(initialMessage.data);
      }

      _onOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
        (msg) => _handleTap(msg.data),
      );

      _onMessageSub = FirebaseMessaging.onMessage.listen((msg) {
        _showForegroundNotification(msg);
      });
    } catch (e) {
      appLogger.w(
        'Firebase non configuré (google-services.json manquant ?) : $e',
      );
      _firebaseReady = false;
    }
  }

  Future<void> registerDeviceToken() async {
    if (_config.useMocks || !_firebaseReady) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await _tokenStorage.saveFcmToken(token);
      await _dio.post<dynamic>('/devices', data: {'fcmToken': token});
    } catch (e) {
      appLogger.w('Impossible d’enregistrer le token FCM: $e');
    }
  }

  Future<void> unregisterDeviceToken() async {
    if (_config.useMocks) {
      await _tokenStorage.clearFcmToken();
      return;
    }
    try {
      final token = await _tokenStorage.getFcmToken();
      if (token != null && token.isNotEmpty) {
        await _dio.delete<dynamic>('/devices/$token');
        await _tokenStorage.clearFcmToken();
      }
    } catch (e) {
      appLogger.w('Impossible de supprimer le token FCM: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage msg) async {
    final notification = msg.notification;
    if (notification == null) return;
    final route = _routeFromType(msg.data['type']?.toString());
    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'CampusEats',
        notification.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'campuseats_channel',
            'CampusEats Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: route,
      );
    } catch (e) {
      appLogger.w('Erreur affichage notification locale: $e');
    }
  }

  void _handleTap(Map<String, dynamic> data) {
    final route = _routeFromType(data['type']?.toString());
    if (route != null) {
      _onNavigate?.call(route);
    }
  }

  String? _routeFromType(String? type) {
    return switch (type) {
      'order_ready' => '/student/qr',
      'subscription_expiring' => '/student/profile',
      _ => null,
    };
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedAppSub?.cancel();
  }
}
