class AppConstants {
  // App Info
  static const String appName = 'Kantin App';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String siswaCollection = 'siswa';
  static const String stanCollection = 'stans';
  static const String menuCollection = 'menu';
  static const String transaksiCollection = 'transaksi';
  static const String detailTransaksiCollection = 'detail_transaksi';
  static const String diskonCollection = 'diskon';
  static const String menuDiskonCollection = 'menu_diskon';
  static const String customerCollection = 'customer';
  static const String dashboardCollection = 'dashboard';
  static const String categoriesCollection = 'categories';

  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String menuImagesPath = 'menu_images';

  // Hive Boxes
  static const String menuCacheBox = 'menu_cache';
  static const String offlineOrdersBox = 'offline_orders';
  static const String userCacheBox = 'user_cache';

  // User Roles
  static const String roleSiswa = 'siswa';
  static const String roleAdminStan = 'admin_stan';
  static const String roleSuperAdmin = 'super_admin';

  // Transaksi Status
  static const String statusBelumDikonfirm = 'belum_dikonfirm';
  static const String statusDimasak = 'dimasak';
  static const String statusDiantar = 'diantar';
  static const String statusSampai = 'sampai';
  static const String statusDibatalkan = 'dibatalkan';

  // Menu Jenis
  static const String jenisMakanan = 'makanan';
  static const String jenisMinuman = 'minuman';

  // Kategori Kantin/Stan
  static const List<String> kategoriKantin = [
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman',
    'Camilan',
    'Dessert',
    'Makanan Tradisional',
    'Makanan Modern',
    'Bakery',
    'Street Food',
    'Healthy Food',
  ];

  // Business Rules
  static const int dailyOrderLimit = 100;
  static const int maxImageSizeMB = 5;
  static const int maxImageWidthPx = 800;
  static const int menuCacheHours = 24;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String dateKeyFormat = 'yyyy-MM-dd'; // For daily limit tracking
}

class ErrorMessages {
  // Auth Errors
  static const String invalidEmail = 'Format email tidak valid';
  static const String weakPassword = 'Password minimal 8 karakter';
  static const String emailAlreadyInUse = 'Email sudah terdaftar';
  static const String userNotFound = 'User tidak ditemukan';
  static const String wrongPassword = 'Password salah';
  static const String userDisabled = 'Akun dinonaktifkan';

  // Network Errors
  static const String noInternetConnection = 'Tidak ada koneksi internet';
  static const String serverError = 'Terjadi kesalahan server';
  static const String timeoutError = 'Koneksi timeout';

  // Order Errors
  static const String dailyLimitReached = 'Batas order harian tercapai (100)';
  static const String menuUnavailable = 'Menu tidak tersedia';
  static const String emptyCart = 'Keranjang kosong';
  static const String stanClosed = 'Stan tutup';

  // Validation Errors
  static const String fieldRequired = 'wajib diisi';
  static const String invalidPhoneNumber = 'Nomor telepon tidak valid';
  static const String invalidPrice = 'Harga harus lebih dari 0';
  static const String imageRequired = 'Gambar wajib diunggah';
  static const String imageTooLarge = 'Ukuran gambar maksimal 5MB';

  // General
  static const String unknownError = 'Terjadi kesalahan tidak diketahui';
  static const String operationFailed = 'Operasi gagal';
}

class SuccessMessages {
  static const String loginSuccess = 'Login berhasil';
  static const String registerSuccess = 'Registrasi berhasil';
  static const String updateSuccess = 'Update berhasil';
  static const String deleteSuccess = 'Hapus berhasil';
  static const String orderPlaced = 'Order berhasil dibuat';
  static const String orderUpdated = 'Status order diupdate';
  static const String menuAdded = 'Menu berhasil ditambahkan';
  static const String stanCreated = 'Stan berhasil dibuat';
}
