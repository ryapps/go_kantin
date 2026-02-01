import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/cloudinary_config.dart';
import '../utils/image_validator.dart';

class CloudinaryService {
  static Future<String> uploadImage(File imageFile) async {
    try {
      print('Starting Cloudinary upload for file: ${imageFile.path}');

      // Validasi gambar sebelum upload
      bool isValid = await ImageValidator.isValidImage(imageFile);
      if (!isValid) {
        throw Exception('File tidak valid. Pastikan file adalah gambar dengan format yang didukung (JPG, PNG, GIF, WebP) dan ukuran tidak lebih dari 10MB.');
      }

      // Buat URL untuk upload
      final url = Uri.parse(CloudinaryConfig.baseUrl);
      print('Upload URL: $url');

      // Buat request multipart
      var request = http.MultipartRequest('POST', url);

      // Tambahkan file ke request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

      // Tambahkan API key untuk signed upload
      request.fields['api_key'] = CloudinaryConfig.apiKey;
      print('Added API key to request');

      // Tambahkan upload preset jika tersedia
      if (CloudinaryConfig.uploadPreset.isNotEmpty) {
        request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
        print('Added upload preset: ${CloudinaryConfig.uploadPreset}');
      } else {
        print('No upload preset specified, using signed upload');
      }

      // Kirim request
      var response = await request.send();
      print('Request sent, waiting for response...');

      // Baca respons
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        // Parsing JSON response
        var jsonData = json.decode(responseBody);
        String secureUrl = jsonData['secure_url'];
        print('Successfully uploaded, received URL: $secureUrl');
        return secureUrl; // URL gambar yang bisa diakses publik
      } else {
        throw Exception('Gagal upload gambar: ${response.reasonPhrase ?? 'Unknown error'} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Exception during Cloudinary upload: $e');
      rethrow; // Re-throw agar error bisa ditangkap di bloc
    }
  }
}