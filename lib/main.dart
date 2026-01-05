import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:salims_apps_new/core/services/language_service.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/firebase_options.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';

import 'core/utils/colors.dart';

// Global navigator key untuk navigation dari service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications plugin
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initSettingsIOS =
  DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await localNotifications.initialize(initSettings);

  // Create notification channel for Android
  await localNotifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Show notification
  final RemoteNotification? notification = message.notification;
  if (notification != null) {
    await localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['screen'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    // If date formatting initialization fails, continue anyway
    // Date formatting error handled silently
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Handler pesan background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Inisialisasi notifikasi lokal
  await initNotifications();

  // Setup selesai, lanjut ke aplikasi

  // Setup token expired callback untuk auto logout
  ApiService.setTokenExpiredCallback(() {
    // Navigate ke splash screen (yang akan redirect ke login jika tidak ada user data)
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SplashScreenView()),
          (route) => false,
    );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalLoadingState()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
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
      // Notification response handled
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

  // ✅ Request permission untuk Android 13+
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // ✅ Listener untuk pesan di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['screen'],
      );
    } else {
      // Jika tidak ada notification payload, tapi ada data, tetap tampilkan
      if (message.data.isNotEmpty) {
        final title = message.data['title'] ?? 'Notification';
        final body = message.data['body'] ?? message.data['message'] ?? 'New notification';

        await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              showWhen: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['screen'],
        );
      }
    }
  });

  // ✅ Handle notification tap (app sudah terbuka)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle navigation jika diperlukan
    if (message.data['screen'] != null) {
      debugPrint("🔗 Navigate to: ${message.data['screen']}");
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _initializeMessaging() async {
    try {
      // Request permission first (hanya untuk iOS, Android tidak perlu)
      if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.ios) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        // For iOS, wait for APNS token first
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken == null) {
          print("═══════════════════════════════════════════════════════════");
          print("APNS TOKEN: NULL (mungkin di simulator atau belum dikonfigurasi)");
          print("═══════════════════════════════════════════════════════════");
          return;
        }
        
        print("═══════════════════════════════════════════════════════════");
        print("APNS TOKEN (LENGKAP) - MAIN.DART:");
        print(apnsToken);
        print("═══════════════════════════════════════════════════════════");
      }

      // Get FCM token dengan retry untuk Android
      String? token;
      int retryCount = 0;
      const maxRetries = 3;

      while (token == null && retryCount < maxRetries) {
        try {
          token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            print("═══════════════════════════════════════════════════════════");
            print("FCM TOKEN (LENGKAP) - MAIN.DART:");
            print(token);
            print("═══════════════════════════════════════════════════════════");
            break;
          }
        } catch (e) {
          retryCount++;
          // Error getting FCM token handled silently

          // Jika error SERVICE_NOT_AVAILABLE, mungkin Google Play Services tidak tersedia
          if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
            // Google Play Services error handled silently

            // Tidak retry lagi untuk SERVICE_NOT_AVAILABLE
            break;
          }

          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }

    } catch (e) {
      // Error initializing messaging handled silently
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize messaging
    _initializeMessaging();

    // Check initial message (jika app dibuka dari notification saat app terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // Handle navigation jika diperlukan
        if (message.data['screen'] != null) {
          debugPrint("🔗 Navigate to: ${message.data['screen']}");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: languageService.currentLocale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id'), // Indonesian
            Locale('en'), // English
          ],
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.skyBlue,
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.skyBlue,
              primary: AppColors.skyBlue,
              secondary: AppColors.lime,
              background: AppColors.background,
            ),
          ),
          home: SplashScreenView(),
        );
      },
    );
  }
}
