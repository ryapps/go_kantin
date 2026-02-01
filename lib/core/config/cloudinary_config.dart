// Konfigurasi Cloudinary - Harap ganti dengan nilai yang sesuai
class CloudinaryConfig {
  // Ganti dengan cloud name kamu
  static const String cloudName = 'ddwvxa3p9';

  // Ganti dengan API Key kamu
  static const String apiKey = '183394796542258';

  // Ganti dengan API Secret kamu
  static const String apiSecret = 'g3cfT_mKFw5HitcFSHoiO3Ztsm8';

  // Jika kamu menggunakan unsigned upload, ganti dengan upload preset kamu
  // Untuk penggunaan di production, gunakan upload preset unsigned
  static const String uploadPreset = 'go_kantin_storage'; // Gunakan upload preset default dari Cloudinary

  // Base URL untuk upload
  static String get baseUrl =>
      'https://api.cloudinary.com/v1_1/${cloudName}/image/upload';
}
