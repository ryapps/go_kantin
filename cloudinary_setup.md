# Setup Cloudinary untuk Upload Gambar

## Konfigurasi Awal

1. Buat akun di [Cloudinary](https://cloudinary.com/)
2. Dapatkan credentials dari dashboard Cloudinary:
   - Cloud Name
   - API Key
   - API Secret

## Konfigurasi Upload Preset (Wajib untuk keamanan)

1. Di dashboard Cloudinary, buka menu "Settings" > "Upload"
2. Buat "Upload Preset" baru
3. Atur mode ke "Unsigned" (ini penting untuk keamanan client-side)
4. Beri nama preset (misalnya: `kantin_app_upload`)
5. Simpan nama upload preset yang dibuat

## Konfigurasi Aplikasi

1. Buka file `lib/core/config/cloudinary_config.dart`
2. Ganti nilai berikut dengan konfigurasi Cloudinary kamu:
   ```dart
   static const String cloudName = 'your_cloud_name';
   static const String apiKey = 'your_api_key';
   static const String uploadPreset = 'your_upload_preset_name'; // Nama preset yang dibuat di langkah sebelumnya
   ```

## Catatan Keamanan Penting

- ⚠️ JANGAN pernah menyimpan API Secret di kode client dalam production
- Selalu gunakan "Upload Preset" Unsigned untuk upload dari client-side
- API Secret TIDAK BOLEH disimpan di aplikasi client
- Pertimbangkan untuk membuat endpoint server untuk upload jika keamanan sangat penting
- Ikuti panduan di SECURE_CLOUDINARY_SETUP.md untuk konfigurasi yang lebih aman

## Struktur yang Telah Diubah

1. `lib/core/config/cloudinary_config.dart` - Konfigurasi Cloudinary
2. `lib/core/services/cloudinary_service.dart` - Service untuk upload ke Cloudinary
3. `lib/features/admin/presentation/bloc/stan_profile_bloc.dart` - Ditambahkan upload ke Cloudinary
4. `lib/features/admin/presentation/bloc/stan_profile_state.dart` - Ditambahkan state untuk upload
5. `lib/features/admin/presentation/screens/StanProfileScreen.dart` - Ditambahkan UI untuk upload
6. `lib/features/stan/presentation/bloc/stan_profile_completion_bloc.dart` - Ditambahkan upload ke Cloudinary
7. `lib/features/stan/presentation/screens/complete_stan_profile_screen.dart` - Ditambahkan UI untuk upload
8. `lib/core/di/injection_container.dart` - Ditambahkan import CloudinaryService
9. `pubspec.yaml` - Ditambahkan dependency http

## Cara Kerja

1. User memilih gambar dari galeri
2. Gambar diupload langsung ke Cloudinary menggunakan upload preset
3. URL hasil upload disimpan dan digunakan untuk update profil stan