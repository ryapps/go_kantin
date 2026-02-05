import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/cloudinary_config.dart';
import '../utils/image_validator.dart';

class CloudinaryService {
  // Method untuk web dan mobile - menerima path string
  static Future<String> uploadImageFromPath(String imagePath) async {
    try {
      print('Starting Cloudinary upload from path: $imagePath');

      // Buat URL untuk upload
      final url = Uri.parse(CloudinaryConfig.baseUrl);
      print('Upload URL: $url');

      // Buat request multipart
      var request = http.MultipartRequest('POST', url);

      if (kIsWeb) {
        // Untuk web, path sebenarnya adalah data URL atau bisa read bytes
        // Tapi karena XFile sudah memberikan bytes, kita perlu handle differently
        throw UnsupportedError('Use uploadImageFromBytes for web platform');
      } else {
        // Untuk mobile, gunakan File
        final imageFile = File(imagePath);

        // Validasi gambar sebelum upload
        bool isValid = await ImageValidator.isValidImage(imageFile);
        if (!isValid) {
          throw Exception(
            'File tidak valid. Pastikan file adalah gambar dengan format yang didukung (JPG, PNG, GIF, WebP) dan ukuran tidak lebih dari 10MB.',
          );
        }

        // Tambahkan file ke request
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

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
        throw Exception(
          'Gagal upload gambar: ${response.reasonPhrase ?? 'Unknown error'} (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Exception during Cloudinary upload: $e');
      rethrow; // Re-throw agar error bisa ditangkap di bloc
    }
  }

  // Method untuk upload dari bytes (web compatible)
  static Future<String> uploadImageFromBytes(
    List<int> bytes,
    String filename,
  ) async {
    try {
      print('Starting Cloudinary upload from bytes: $filename');
      print('Bytes length: ${bytes.length}');

      // Buat URL untuk upload
      final url = Uri.parse(CloudinaryConfig.baseUrl);
      print('Upload URL: $url');

      // Buat request multipart
      var request = http.MultipartRequest('POST', url);

      // Tentukan content type dari extension
      String extension = filename.split('.').last.toLowerCase();
      MediaType? contentType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg');
      }

      print('Content type: ${contentType.mimeType}');

      // Tambahkan file dari bytes
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: contentType,
      );

      print('MultipartFile created with length: ${multipartFile.length}');
      request.files.add(multipartFile);

      // Tambahkan upload preset jika tersedia
      if (CloudinaryConfig.uploadPreset.isNotEmpty) {
        request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
        print('Added upload preset: ${CloudinaryConfig.uploadPreset}');
      } else {
        // Tambahkan API key untuk signed upload jika tidak pakai preset
        request.fields['api_key'] = CloudinaryConfig.apiKey;
        print('Added API key to request');
      }

      // Kirim request
      print('Sending request...');
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
        throw Exception(
          'Gagal upload gambar: ${response.reasonPhrase ?? 'Unknown error'} (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Exception during Cloudinary upload: $e');
      rethrow;
    }
  }

  // Legacy method untuk backward compatibility
  static Future<String> uploadImage(File imageFile) async {
    return uploadImageFromPath(imageFile.path);
  }
}
