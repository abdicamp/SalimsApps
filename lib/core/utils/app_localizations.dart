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
  
  // Notification History
  String get notificationHistory => _localizedValues[locale.languageCode]?['notificationHistory'] ?? 'Notification History';
  String get searchNotification => _localizedValues[locale.languageCode]?['searchNotification'] ?? 'Search notification...';
  String get noNotificationsFound => _localizedValues[locale.languageCode]?['noNotificationsFound'] ?? 'No notifications found';
  String get noTitle => _localizedValues[locale.languageCode]?['noTitle'] ?? 'No Title';
  String get noDescription => _localizedValues[locale.languageCode]?['noDescription'] ?? 'No description';
  String get unknown => _localizedValues[locale.languageCode]?['unknown'] ?? 'UNKNOWN';
  String get users => _localizedValues[locale.languageCode]?['users'] ?? 'users';
  
  // Dialog
  String get confirmDialog => _localizedValues[locale.languageCode]?['confirmDialog'] ?? 'Confirm';
  String get confirmChangeLocation => _localizedValues[locale.languageCode]?['confirmChangeLocation'] ?? 'Are you sure you want to change the location?';
  
  // Form Labels
  String get attachment => _localizedValues[locale.languageCode]?['attachment'] ?? 'Attachment';
  String get conUOM => _localizedValues[locale.languageCode]?['conUOM'] ?? 'Con UOM';
  String get volUOM => _localizedValues[locale.languageCode]?['volUOM'] ?? 'Vol UOM';
  String get isCalibration => _localizedValues[locale.languageCode]?['isCalibration'] ?? 'Is Calibration';
  String get formCannotBeEmpty => _localizedValues[locale.languageCode]?['formCannotBeEmpty'] ?? 'Form cannot be empty';
  String get pleaseEnterSomeText => _localizedValues[locale.languageCode]?['pleaseEnterSomeText'] ?? 'Please enter some text';
  
  // Form Field Labels
  String get searchParameter => _localizedValues[locale.languageCode]?['searchParameter'] ?? 'Search Parameter';
  String get searchEquipment => _localizedValues[locale.languageCode]?['searchEquipment'] ?? 'Search Equipment';
  String get unitQTY => _localizedValues[locale.languageCode]?['unitQTY'] ?? 'Unit QTY';
  String get volumeQTY => _localizedValues[locale.languageCode]?['volumeQTY'] ?? 'Volume QTY';
  String get volumeUOM => _localizedValues[locale.languageCode]?['volumeUOM'] ?? 'Volume UOM';
  String get instituResult => _localizedValues[locale.languageCode]?['instituResult'] ?? 'Institu Result';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  String get geotag => _localizedValues[locale.languageCode]?['geotag'] ?? 'Geotag';
  String get address => _localizedValues[locale.languageCode]?['address'] ?? 'Address';
  String get weather => _localizedValues[locale.languageCode]?['weather'] ?? 'Weather';
  String get windDirection => _localizedValues[locale.languageCode]?['windDirection'] ?? 'Wind Direction';
  String get temperatur => _localizedValues[locale.languageCode]?['temperatur'] ?? 'Temperatur';
  
  // Hint Text
  String get searchParameterHint => _localizedValues[locale.languageCode]?['searchParameterHint'] ?? 'Search Parameter';
  String get searchEquipmentHint => _localizedValues[locale.languageCode]?['searchEquipmentHint'] ?? 'Search Equipment';

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
      'notificationHistory': 'Riwayat Notifikasi',
      'searchNotification': 'Cari notifikasi...',
      'noNotificationsFound': 'Tidak ada notifikasi ditemukan',
      'noTitle': 'Tidak Ada Judul',
      'noDescription': 'Tidak ada deskripsi',
      'unknown': 'TIDAK DIKETAHUI',
      'users': 'pengguna',
      'confirmDialog': 'Konfirmasi',
      'confirmChangeLocation': 'Apakah kamu yakin ingin mengubah lokasi nya ?',
      'attachment': 'Lampiran',
      'conUOM': 'Con UOM',
      'volUOM': 'Vol UOM',
      'isCalibration': 'Apakah Kalibrasi',
      'formCannotBeEmpty': 'Form tidak boleh Kosong',
      'pleaseEnterSomeText': 'Harap masukkan beberapa teks',
      'searchParameter': 'Cari Parameter',
      'searchEquipment': 'Cari Peralatan',
      'unitQTY': 'Unit QTY',
      'volumeQTY': 'Volume QTY',
      'volumeUOM': 'Volume UOM',
      'instituResult': 'Hasil Institu',
      'description': 'Deskripsi',
      'geotag': 'Geotag',
      'address': 'Alamat',
      'weather': 'Cuaca',
      'windDirection': 'Arah Angin',
      'temperatur': 'Suhu',
      'searchParameterHint': 'Cari Parameter',
      'searchEquipmentHint': 'Cari Peralatan',
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
      'notificationHistory': 'Notification History',
      'searchNotification': 'Search notification...',
      'noNotificationsFound': 'No notifications found',
      'noTitle': 'No Title',
      'noDescription': 'No description',
      'unknown': 'UNKNOWN',
      'users': 'users',
      'confirmDialog': 'Confirm',
      'confirmChangeLocation': 'Are you sure you want to change the location?',
      'attachment': 'Attachment',
      'conUOM': 'Con UOM',
      'volUOM': 'Vol UOM',
      'isCalibration': 'Is Calibration',
      'formCannotBeEmpty': 'Form cannot be empty',
      'pleaseEnterSomeText': 'Please enter some text',
      'searchParameter': 'Search Parameter',
      'searchEquipment': 'Search Equipment',
      'unitQTY': 'Unit QTY',
      'volumeQTY': 'Volume QTY',
      'volumeUOM': 'Volume UOM',
      'instituResult': 'Institu Result',
      'description': 'Description',
      'geotag': 'Geotag',
      'address': 'Address',
      'weather': 'Weather',
      'windDirection': 'Wind Direction',
      'temperatur': 'Temperatur',
      'searchParameterHint': 'Search Parameter',
      'searchEquipmentHint': 'Search Equipment',
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

