import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common translations
  String get appName => _localizedValues[locale.languageCode]?['appName'] ?? 'Salims Apps';
  
  // Profile
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get changePassword => _localizedValues[locale.languageCode]?['changePassword'] ?? 'Change Password';
  String get oldPassword => _localizedValues[locale.languageCode]?['oldPassword'] ?? 'Old Password';
  String get newPassword => _localizedValues[locale.languageCode]?['newPassword'] ?? 'New Password';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get accountInformation => _localizedValues[locale.languageCode]?['accountInformation'] ?? 'Account Information';
  String get employeeId => _localizedValues[locale.languageCode]?['employeeId'] ?? 'Employee ID';
  String get division => _localizedValues[locale.languageCode]?['division'] ?? 'Division';
  String get joinDate => _localizedValues[locale.languageCode]?['joinDate'] ?? 'Join Date';
  
  // Language
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get selectLanguage => _localizedValues[locale.languageCode]?['selectLanguage'] ?? 'Select Language';
  String get indonesian => _localizedValues[locale.languageCode]?['indonesian'] ?? 'Indonesian';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  
  // Common
  String get pleaseEnterValue => _localizedValues[locale.languageCode]?['pleaseEnterValue'] ?? 'Please enter value';
  
  // Home
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  
  // Task
  String get task => _localizedValues[locale.languageCode]?['task'] ?? 'Task';
  String get taskList => _localizedValues[locale.languageCode]?['taskList'] ?? 'Task List';
  
  // History
  String get history => _localizedValues[locale.languageCode]?['history'] ?? 'History';
  String get historyTask => _localizedValues[locale.languageCode]?['historyTask'] ?? 'History Task';
  
  // Login
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get username => _localizedValues[locale.languageCode]?['username'] ?? 'Username';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get welcomeBack => _localizedValues[locale.languageCode]?['welcomeBack'] ?? 'Welcome Back!';
  String get loginToYourAccount => _localizedValues[locale.languageCode]?['loginToYourAccount'] ?? 'Login to your account';
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgotPassword'] ?? 'Forgot Password?';
  String get loginButton => _localizedValues[locale.languageCode]?['loginButton'] ?? 'LOGIN';
  
  // Home
  String get hello => _localizedValues[locale.languageCode]?['hello'] ?? 'Hello!';
  String get nearestAssignmentLocation => _localizedValues[locale.languageCode]?['nearestAssignmentLocation'] ?? 'Nearest Assigment Location';
  String get checkLocation => _localizedValues[locale.languageCode]?['checkLocation'] ?? 'Check Location';
  String get toDoTask => _localizedValues[locale.languageCode]?['toDoTask'] ?? 'To do task';
  String get outstanding => _localizedValues[locale.languageCode]?['outstanding'] ?? 'Outstanding';
  String get finish => _localizedValues[locale.languageCode]?['finish'] ?? 'Finish';
  String get performa => _localizedValues[locale.languageCode]?['performa'] ?? 'Performa';
  String get percentCompleted => _localizedValues[locale.languageCode]?['percentCompleted'] ?? '% Completed';
  
  // Task List
  String get listTask => _localizedValues[locale.languageCode]?['listTask'] ?? 'List Task';
  String get takingSample => _localizedValues[locale.languageCode]?['takingSample'] ?? 'Taking Sample';
  String get date => _localizedValues[locale.languageCode]?['date'] ?? 'Date';
  String get searchTask => _localizedValues[locale.languageCode]?['searchTask'] ?? 'Search task...';
  
  // Detail Task
  String get detailTask => _localizedValues[locale.languageCode]?['detailTask'] ?? 'Detail Task';
  String get taskInfo => _localizedValues[locale.languageCode]?['taskInfo'] ?? 'Task Info';
  String get containerInfo => _localizedValues[locale.languageCode]?['containerInfo'] ?? 'Container Info';
  String get parameter => _localizedValues[locale.languageCode]?['parameter'] ?? 'Parameter';
  
  // Common Actions
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get back => _localizedValues[locale.languageCode]?['back'] ?? 'Back';
  String get submit => _localizedValues[locale.languageCode]?['submit'] ?? 'Submit';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get yes => _localizedValues[locale.languageCode]?['yes'] ?? 'Yes';
  String get no => _localizedValues[locale.languageCode]?['no'] ?? 'No';
  
  // Messages
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get noData => _localizedValues[locale.languageCode]?['noData'] ?? 'No Data';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';
  
  // Error Messages
  String get loginError => _localizedValues[locale.languageCode]?['loginError'] ?? 'An error occurred during login. Please try again.';
  String get locationPermissionRequired => _localizedValues[locale.languageCode]?['locationPermissionRequired'] ?? 'Location Permission Required';
  String get locationPermissionDeniedPermanently => _localizedValues[locale.languageCode]?['locationPermissionDeniedPermanently'] ?? 'You have permanently denied location permission. Please enable location permission in app settings.';
  String get openSettings => _localizedValues[locale.languageCode]?['openSettings'] ?? 'Open Settings';
  String get pleaseLoginAgain => _localizedValues[locale.languageCode]?['pleaseLoginAgain'] ?? 'Please login again';
  String get errorChangePassword => _localizedValues[locale.languageCode]?['errorChangePassword'] ?? 'Error changing password';
  String get outOfLocationRange => _localizedValues[locale.languageCode]?['outOfLocationRange'] ?? 'You are out of location range';
  String get failedConfirm => _localizedValues[locale.languageCode]?['failedConfirm'] ?? 'Failed to confirm';
  String get failedPostData => _localizedValues[locale.languageCode]?['failedPostData'] ?? 'Failed to post data';
  
  // Form Validation
  String get formParameterEmpty => _localizedValues[locale.languageCode]?['formParameterEmpty'] ?? 'Form Parameter is Empty';
  String get formTaskInfoEmpty => _localizedValues[locale.languageCode]?['formTaskInfoEmpty'] ?? 'Form Task Info is Empty';
  String get formContainerInfoEmpty => _localizedValues[locale.languageCode]?['formContainerInfoEmpty'] ?? 'Form Container Info is Empty';
  String get imageCannotBeEmpty => _localizedValues[locale.languageCode]?['imageCannotBeEmpty'] ?? 'Image cannot be empty';
  
  // History
  String get searchTaskHistory => _localizedValues[locale.languageCode]?['searchTaskHistory'] ?? 'Search task history...';

  static final Map<String, Map<String, String>> _localizedValues = {
    'id': {
      'appName': 'Salims Apps',
      'profile': 'Profil',
      'changePassword': 'Ubah Kata Sandi',
      'oldPassword': 'Kata Sandi Lama',
      'newPassword': 'Kata Sandi Baru',
      'save': 'Simpan',
      'cancel': 'Batal',
      'accountInformation': 'Informasi Akun',
      'employeeId': 'ID Karyawan',
      'division': 'Divisi',
      'joinDate': 'Tanggal Bergabung',
      'language': 'Bahasa',
      'selectLanguage': 'Pilih Bahasa',
      'indonesian': 'Indonesia',
      'english': 'Inggris',
      'pleaseEnterValue': 'Harap masukkan nilai',
      'home': 'Beranda',
      'task': 'Tugas',
      'taskList': 'Daftar Tugas',
      'history': 'Riwayat',
      'historyTask': 'Riwayat Tugas',
      'login': 'Masuk',
      'username': 'Nama Pengguna',
      'password': 'Kata Sandi',
      'welcomeBack': 'Selamat Datang Kembali!',
      'loginToYourAccount': 'Masuk ke akun Anda',
      'forgotPassword': 'Lupa Kata Sandi?',
      'loginButton': 'MASUK',
      'hello': 'Halo!',
      'nearestAssignmentLocation': 'Lokasi Tugas Terdekat',
      'checkLocation': 'Periksa Lokasi',
      'toDoTask': 'Kerjakan Tugas',
      'outstanding': 'Belum Selesai',
      'finish': 'Selesai',
      'performa': 'Performa',
      'percentCompleted': '% Selesai',
      'listTask': 'Daftar Tugas',
      'takingSample': 'Ambil Sampel',
      'date': 'Tanggal',
      'searchTask': 'Cari tugas...',
      'detailTask': 'Detail Tugas',
      'taskInfo': 'Info Tugas',
      'containerInfo': 'Info Kontainer',
      'parameter': 'Parameter',
      'logout': 'Keluar',
      'back': 'Kembali',
      'submit': 'Kirim',
      'delete': 'Hapus',
      'edit': 'Ubah',
      'close': 'Tutup',
      'confirm': 'Konfirmasi',
      'yes': 'Ya',
      'no': 'Tidak',
      'loading': 'Memuat...',
      'error': 'Kesalahan',
      'success': 'Berhasil',
      'noData': 'Tidak Ada Data',
      'retry': 'Coba Lagi',
      'loginError': 'Terjadi kesalahan saat login. Silakan coba lagi.',
      'locationPermissionRequired': 'Izin Lokasi Diperlukan',
      'locationPermissionDeniedPermanently': 'Anda menolak izin lokasi secara permanen. Silakan aktifkan izin lokasi di pengaturan aplikasi.',
      'openSettings': 'Buka Pengaturan',
      'pleaseLoginAgain': 'Silakan login lagi',
      'errorChangePassword': 'Kesalahan mengubah kata sandi',
      'outOfLocationRange': 'Anda berada di luar jangkauan lokasi',
      'failedConfirm': 'Gagal mengonfirmasi',
      'failedPostData': 'Gagal mengirim data',
      'formParameterEmpty': 'Form Parameter Kosong',
      'formTaskInfoEmpty': 'Form Task Info Kosong',
      'formContainerInfoEmpty': 'Form Container Info Kosong',
      'imageCannotBeEmpty': 'Gambar tidak boleh kosong',
      'searchTaskHistory': 'Cari riwayat tugas...',
    },
    'en': {
      'appName': 'Salims Apps',
      'profile': 'Profile',
      'changePassword': 'Change Password',
      'oldPassword': 'Old Password',
      'newPassword': 'New Password',
      'save': 'Save',
      'cancel': 'Cancel',
      'accountInformation': 'Account Information',
      'employeeId': 'Employee ID',
      'division': 'Division',
      'joinDate': 'Join Date',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'indonesian': 'Indonesian',
      'english': 'English',
      'pleaseEnterValue': 'Please enter value',
      'home': 'Home',
      'task': 'Task',
      'taskList': 'Task List',
      'history': 'History',
      'historyTask': 'History Task',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'welcomeBack': 'Welcome Back!',
      'loginToYourAccount': 'Login to your account',
      'forgotPassword': 'Forgot Password?',
      'loginButton': 'LOGIN',
      'hello': 'Hello!',
      'nearestAssignmentLocation': 'Nearest Assigment Location',
      'checkLocation': 'Check Location',
      'toDoTask': 'To do task',
      'outstanding': 'Outstanding',
      'finish': 'Finish',
      'performa': 'Performa',
      'percentCompleted': '% Completed',
      'listTask': 'List Task',
      'takingSample': 'Taking Sample',
      'date': 'Date',
      'searchTask': 'Search task...',
      'detailTask': 'Detail Task',
      'taskInfo': 'Task Info',
      'containerInfo': 'Container Info',
      'parameter': 'Parameter',
      'logout': 'Logout',
      'back': 'Back',
      'submit': 'Submit',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'noData': 'No Data',
      'retry': 'Retry',
      'loginError': 'An error occurred during login. Please try again.',
      'locationPermissionRequired': 'Location Permission Required',
      'locationPermissionDeniedPermanently': 'You have permanently denied location permission. Please enable location permission in app settings.',
      'openSettings': 'Open Settings',
      'pleaseLoginAgain': 'Please login again',
      'errorChangePassword': 'Error changing password',
      'outOfLocationRange': 'You are out of location range',
      'failedConfirm': 'Failed to confirm',
      'failedPostData': 'Failed to post data',
      'formParameterEmpty': 'Form Parameter is Empty',
      'formTaskInfoEmpty': 'Form Task Info is Empty',
      'formContainerInfoEmpty': 'Form Container Info is Empty',
      'imageCannotBeEmpty': 'Image cannot be empty',
      'searchTaskHistory': 'Search task history...',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Ensure we always return a valid AppLocalizations instance
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

