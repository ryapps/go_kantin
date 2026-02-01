import 'dart:io';
import 'dart:typed_data';

class ImageValidator {
  /// Validates if the file is a valid image and meets size requirements
  static Future<bool> isValidImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return false;
      }

      // Check file size (max 10MB for Cloudinary free tier)
      int fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB in bytes
        return false;
      }

      // Check file extension
      String extension = imageFile.path.split('.').last.toLowerCase();
      List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!validExtensions.contains(extension)) {
        return false;
      }

      // Read the first few bytes to check for valid image headers
      RandomAccessFile randomAccessFile = await imageFile.open(mode: FileMode.read);
      Uint8List header = await randomAccessFile.read(10); // Read first 10 bytes
      await randomAccessFile.close();

      // Check for common image file signatures
      if (_isValidImageHeader(header, extension)) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  /// Checks if the file header matches the expected image format
  static bool _isValidImageHeader(Uint8List header, String extension) {
    if (extension == 'jpg' || extension == 'jpeg') {
      // JPEG files start with FF D8 FF
      return header.length >= 3 && 
             header[0] == 0xFF && 
             header[1] == 0xD8 && 
             header[2] == 0xFF;
    } else if (extension == 'png') {
      // PNG files start with 89 50 4E 47 0D 0A 1A 0A
      return header.length >= 8 && 
             header[0] == 0x89 && 
             header[1] == 0x50 && 
             header[2] == 0x4E && 
             header[3] == 0x47 && 
             header[4] == 0x0D && 
             header[5] == 0x0A && 
             header[6] == 0x1A && 
             header[7] == 0x0A;
    } else if (extension == 'gif') {
      // GIF files start with 47 49 46 38 (GIF8)
      return header.length >= 4 && 
             header[0] == 0x47 && 
             header[1] == 0x49 && 
             header[2] == 0x46 && 
             header[3] == 0x38;
    } else if (extension == 'webp') {
      // WebP files start with RIFF....WEBP
      return header.length >= 12 && 
             header[0] == 0x52 && // R
             header[1] == 0x49 && // I
             header[2] == 0x46 && // F
             header[3] == 0x46 && // F
             header[8] == 0x57 && // W
             header[9] == 0x45 && // E
             header[10] == 0x42 && // B
             header[11] == 0x50; // P
    }
    
    return false;
  }

  /// Gets human-readable file size
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).round()} MB';
  }
}