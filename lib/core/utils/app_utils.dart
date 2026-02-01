import 'package:intl/intl.dart';
import 'constants.dart';

class AppUtils {
  /// Format currency to Indonesian Rupiah
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format date to readable format
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format time to readable format
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Format datetime to readable format
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  /// Get date key for daily limit tracking (YYYY-MM-DD)
  static String getDateKey(DateTime date) {
    return DateFormat(AppConstants.dateKeyFormat).format(date);
  }

  /// Get today's date key
  static String getTodayKey() {
    return getDateKey(DateTime.now());
  }

  /// Check if two dates are same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get time ago string (e.g., "2 menit yang lalu")
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get status label in Indonesian
  static String getStatusLabel(String status) {
    switch (status) {
      case AppConstants.statusBelumDikonfirm:
        return 'Belum Dikonfirm';
      case AppConstants.statusDimasak:
        return 'Sedang Dimasak';
      case AppConstants.statusDiantar:
        return 'Siap Diambil';
      case AppConstants.statusSampai:
        return 'Selesai';
      case AppConstants.statusDibatalkan:
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Get menu type label in Indonesian
  static String getMenuTypeLabel(String jenis) {
    switch (jenis) {
      case AppConstants.jenisMakanan:
        return 'Makanan';
      case AppConstants.jenisMinuman:
        return 'Minuman';
      default:
        return jenis;
    }
  }

  /// Get role label in Indonesian
  static String getRoleLabel(String role) {
    switch (role) {
      case AppConstants.roleSiswa:
        return 'Siswa';
      case AppConstants.roleAdminStan:
        return 'Admin Stan';
      case AppConstants.roleSuperAdmin:
        return 'Super Admin';
      default:
        return role;
    }
  }

  /// Generate order number with prefix
  static String generateOrderNumber(String uuid) {
    return 'ORDER-${uuid.toUpperCase()}';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Calculate discount amount
  static double calculateDiscount(double price, double percentage) {
    return price * (percentage / 100);
  }

  /// Calculate final price after discount
  static double calculateFinalPrice(double price, double percentage) {
    return price - calculateDiscount(price, percentage);
  }

  /// Validate image file size
  static bool isImageSizeValid(int sizeInBytes) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= AppConstants.maxImageSizeMB;
  }

  /// Get Indonesian month name
  static String getIndonesianMonth(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (month >= 1 && month <= 12) {
      return months[month];
    }

    return '';
  }

  /// Format month-year in Indonesian
  static String formatMonthYearIndonesian(DateTime date) {
    return '${getIndonesianMonth(date.month)} ${date.year}';
  }
}