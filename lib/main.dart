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
  
  print("═══════════════════════════════════════════════════════");
  print("📩 PUSH NOTIFICATION RECEIVED (BACKGROUND)");
  print("═══════════════════════════════════════════════════════");
  print("📱 Message ID: ${message.messageId}");
  print("📅 Sent Time: ${message.sentTime}");
  print("📧 From: ${message.from}");
  print("🔔 Notification Title: ${message.notification?.title ?? 'N/A'}");
  print("📝 Notification Body: ${message.notification?.body ?? 'N/A'}");
  print("🖼️  Image URL: ${message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl ?? 'N/A'}");
  print("📊 Data: ${message.data}");
  print("🔗 Screen: ${message.data['screen'] ?? 'N/A'}");
  print("═══════════════════════════════════════════════════════");
  
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
    print("📤 Displaying background notification...");
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
    print("✅ Background notification displayed successfully");
    print("   - Notification ID: ${notification.hashCode}");
    print("   - Channel: ${channel.id}");
    print("═══════════════════════════════════════════════════════");
  } else {
    print("⚠️ WARNING: Notification payload is null in background handler");
    print("📊 Available data: ${message.data}");
    print("═══════════════════════════════════════════════════════");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    // If date formatting initialization fails, continue anyway
    print('Warning: Could not initialize date formatting: $e');
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

  // ✅ Request permission untuk Android 13+
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // ✅ Listener untuk pesan di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("═══════════════════════════════════════════════════════");
    print("📩 PUSH NOTIFICATION RECEIVED (FOREGROUND)");
    print("═══════════════════════════════════════════════════════");
    print("📱 Message ID: ${message.messageId}");
    print("📅 Sent Time: ${message.sentTime}");
    print("📧 From: ${message.from}");
    print("🔔 Notification Title: ${message.notification?.title ?? 'N/A'}");
    print("📝 Notification Body: ${message.notification?.body ?? 'N/A'}");
    print("🖼️  Image URL: ${message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl ?? 'N/A'}");
    print("📊 Data: ${message.data}");
    print("🔗 Screen: ${message.data['screen'] ?? 'N/A'}");
    print("📦 Collapse Key: ${message.collapseKey ?? 'N/A'}");
    print("🔑 Message Type: ${message.messageType ?? 'N/A'}");
    print("═══════════════════════════════════════════════════════");
    
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
      print("✅ Notification displayed successfully");
      print("   - Notification ID: ${notification.hashCode}");
      print("   - Channel: ${channel.id}");
      print("═══════════════════════════════════════════════════════");
    } else {
      print("⚠️ WARNING: Notification payload is null");
      print("📊 Available data: ${message.data}");
      // Jika tidak ada notification payload, tapi ada data, tetap tampilkan
      if (message.data.isNotEmpty) {
        final title = message.data['title'] ?? 'Notification';
        final body = message.data['body'] ?? message.data['message'] ?? 'New notification';
        print("📤 Displaying notification from data payload:");
        print("   - Title: $title");
        print("   - Body: $body");
        
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
        print("✅ Notification displayed from data successfully");
        print("   - Notification ID: ${message.hashCode}");
        print("═══════════════════════════════════════════════════════");
      } else {
        print("❌ ERROR: No notification payload and no data available");
        print("═══════════════════════════════════════════════════════");
      }
    }
  });
  
  // ✅ Handle notification tap (app sudah terbuka)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("═══════════════════════════════════════════════════════");
    print("👆 NOTIFICATION TAPPED (App Already Open)");
    print("═══════════════════════════════════════════════════════");
    print("📱 Message ID: ${message.messageId}");
    print("🔔 Notification Title: ${message.notification?.title ?? 'N/A'}");
    print("📝 Notification Body: ${message.notification?.body ?? 'N/A'}");
    print("📊 Data: ${message.data}");
    print("🔗 Screen: ${message.data['screen'] ?? 'N/A'}");
    // Handle navigation jika diperlukan
    if (message.data['screen'] != null) {
      print("🧭 Navigating to: ${message.data['screen']}");
      debugPrint("🔗 Navigate to: ${message.data['screen']}");
    } else {
      print("⚠️ No screen specified in notification data");
    }
    print("═══════════════════════════════════════════════════════");
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
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        print("🔔 Notification permission status: ${settings.authorizationStatus}");

        // For iOS, wait for APNS token first
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("📱 APNS Token: $apnsToken");
        
        if (apnsToken == null) {
          print("⚠️ APNS token is null. Make sure Push Notifications capability is enabled in Xcode.");
          return;
        }
      }

      // Get FCM token dengan retry untuk Android
      String? token;
      int retryCount = 0;
      const maxRetries = 3;
      
      print("═══════════════════════════════════════════════════════");
      print("🔑 GETTING FCM TOKEN");
      print("═══════════════════════════════════════════════════════");
      
      while (token == null && retryCount < maxRetries) {
        try {
          token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            print("✅ FCM Token obtained successfully");
            print("📱 FCM Token: $token");
            print("═══════════════════════════════════════════════════════");
            // Token bisa digunakan untuk dikirim ke server jika diperlukan
            // Contoh: await sendTokenToServer(token);
            break;
          }
        } catch (e) {
          retryCount++;
          print("⚠️ Error getting FCM token (attempt $retryCount/$maxRetries): $e");
          
          // Jika error SERVICE_NOT_AVAILABLE, mungkin Google Play Services tidak tersedia
          if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
            print("⚠️ Google Play Services mungkin tidak tersedia atau tidak ter-update.");
            print("⚠️ Pastikan device memiliki Google Play Services yang ter-update.");
            
            // Tidak retry lagi untuk SERVICE_NOT_AVAILABLE
            break;
          }
          
          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
      
      if (token == null) {
        print("❌ FCM Token tidak dapat diperoleh setelah $maxRetries attempts");
        print("═══════════════════════════════════════════════════════");
      }
    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════");
      print("❌ ERROR INITIALIZING MESSAGING");
      print("═══════════════════════════════════════════════════════");
      print("❌ Error: $e");
      print("📚 Stack trace: $stackTrace");
      
      // Log lebih detail untuk debugging
      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        print("⚠️ SERVICE_NOT_AVAILABLE error biasanya terjadi karena:");
        print("   1. Google Play Services tidak tersedia atau tidak ter-update");
        print("   2. Network connectivity issues");
        print("   3. Firebase project configuration issues");
      }
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
        print("═══════════════════════════════════════════════════════");
        print("🚀 APP OPENED FROM NOTIFICATION (App Was Terminated)");
        print("═══════════════════════════════════════════════════════");
        print("📱 Message ID: ${message.messageId}");
        print("📅 Sent Time: ${message.sentTime}");
        print("📧 From: ${message.from}");
        print("🔔 Notification Title: ${message.notification?.title ?? 'N/A'}");
        print("📝 Notification Body: ${message.notification?.body ?? 'N/A'}");
        print("📊 Data: ${message.data}");
        print("🔗 Screen: ${message.data['screen'] ?? 'N/A'}");
        // Handle navigation jika diperlukan
        if (message.data['screen'] != null) {
          print("🧭 Navigating to: ${message.data['screen']}");
          debugPrint("🔗 Navigate to: ${message.data['screen']}");
        } else {
          print("⚠️ No screen specified in notification data");
        }
        print("═══════════════════════════════════════════════════════");
      } else {
        print("ℹ️  App opened normally (not from notification)");
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
