import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:salims_apps_new/core/services/language_service.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/firebase_options.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';

import 'core/utils/colors.dart';

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

  // ✅ Listener untuk pesan di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

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
      
      while (token == null && retryCount < maxRetries) {
        try {
          token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            print("📱 FCM Token: $token");
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
        print("⚠️ FCM Token tidak dapat diperoleh setelah $maxRetries attempts");
      }
    } catch (e, stackTrace) {
      print("❌ Error initializing messaging: $e");
      print("❌ Stack trace: $stackTrace");
      
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

    // Listen for foreground messages
    listenFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
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
