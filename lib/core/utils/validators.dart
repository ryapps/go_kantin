import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return validateRequired(value, fieldName: 'Email');
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return ErrorMessages.invalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return validateRequired(value, fieldName: 'Password');
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return ErrorMessages.weakPassword;
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName ${ErrorMessages.fieldRequired.toLowerCase()}'
          : ErrorMessages.fieldRequired;
    }
    return null;
  }

  // Name validation (min 3, max 100 chars)
  static String? validateName(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Nama');
    if (requiredError != null) return requiredError;
    
    if (value!.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    
    if (value.length > AppConstants.maxNameLength) {
      return 'Nama maksimal ${AppConstants.maxNameLength} karakter';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return validateRequired(value, fieldName: 'Nomor Telepon');
    }
    
    // Remove spaces and dashes
    final cleanedPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if only digits (optionally starts with +)
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return ErrorMessages.invalidPhoneNumber;
    }
    
    // Check length
    if (cleanedPhone.length < AppConstants.minPhoneLength || 
        cleanedPhone.length > AppConstants.maxPhoneLength) {
      return ErrorMessages.invalidPhoneNumber;
    }
    
    return null;
  }

  // Price validation (must be > 0)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return validateRequired(value, fieldName: 'Harga');
    }
    
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return ErrorMessages.invalidPrice;
    }
    
    return null;
  }

  // Description validation (optional, max 500 chars)
  static String? validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Deskripsi maksimal ${AppConstants.maxDescriptionLength} karakter';
    }
    return null;
  }

  // Quantity validation (must be > 0)
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah harus diisi';
    }
    
    final qty = int.tryParse(value);
    if (qty == null || qty <= 0) {
      return 'Jumlah harus lebih dari 0';
    }
    
    if (qty > 100) {
      return 'Jumlah maksimal 100';
    }
    
    return null;
  }

  // Discount percentage validation (0-100)
  static String? validateDiscountPercentage(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.fieldRequired;
    }
    
    final percentage = double.tryParse(value);
    if (percentage == null || percentage < 0 || percentage > 100) {
      return 'Persentase harus 0-100';
    }
    
    return null;
  }
}