import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:salims_apps_new/firebase_options.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';

// 🔔 Global instance untuk notifikasi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 🔔 Channel Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

// Handler pesan background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 Pesan diterima di background: ${message.messageId}");
}

void listenFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("📩 Foreground message: ${message.notification?.title}");
    // navigatorKey.currentContext?.read<GlobalLoadingState>().getData;
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // harus sama dengan channel.id
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['screen'],
    );
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Handler pesan background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Inisialisasi notifikasi lokal
  await initNotifications();

  // Setup selesai, lanjut ke aplikasi

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalLoadingState()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        debugPrint("🔗 Payload notifikasi: ${response.payload}");
      }
    },
  );

  // ✅ Minta izin notifikasi untuk iOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ✅ Buat channel Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // ✅ Listener untuk pesan di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: android != null
              ? AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                )
              : null,
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  Future<void> _initializeMessaging() async {
    try {
      // Request permission first
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print("🔔 Notification permission status: ${settings.authorizationStatus}");

      if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.ios) {
        // For iOS, wait for APNS token first
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("📱 APNS Token: $apnsToken");
        
        if (apnsToken == null) {
          print("⚠️ APNS token is null. Make sure Push Notifications capability is enabled in Xcode.");
          return;
        }
      }

      // Get FCM token
      final token = await FirebaseMessaging.instance.getToken();
      print("📱 FCM Token: $token");
      if (mounted) {
        setState(() {
          _token = token;
        });
      }
    } catch (e) {
      print("❌ Error initializing messaging: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize messaging
    _initializeMessaging();

    // Listen for foreground messages
    listenFCM();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenView(),
    );
  }
}
