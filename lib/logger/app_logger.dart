// core/services/logger_service.dart
import 'package:logger/logger.dart';

class AppLogger {
  // Singleton supaya hanya ada satu instance logger
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,       // jumlah method stack trace yang ditampilkan
      errorMethodCount: 5,  // method stack trace saat error
      lineLength: 80,       // panjang line
      colors: true,         // aktifkan warna
      printEmojis: true,    // aktifkan emoji untuk tiap level
      printTime: true,      // tampilkan timestamp
    ),
  );
}
