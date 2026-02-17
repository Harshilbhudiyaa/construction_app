import 'package:flutter/services.dart';

/// Phone number formatter for Indian phone numbers
/// Formats as: +91 98765 43210 or 9876543210
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    // Handle +91 prefix
    if (text.startsWith('91') && text.length > 2) {
      formatted = '+91 ';
      final remaining = text.substring(2);
      if (remaining.length <= 5) {
        formatted += remaining;
      } else {
        formatted += '${remaining.substring(0, 5)} ${remaining.substring(5, remaining.length > 10 ? 10 : remaining.length)}';
      }
    } else if (text.length <= 10) {
      // Format as groups: 98765 43210
      if (text.length <= 5) {
        formatted = text;
      } else {
        formatted = '${text.substring(0, 5)} ${text.substring(5)}';
      }
    } else {
      formatted = text.substring(0, 10);
      if (formatted.length > 5) {
        formatted = '${formatted.substring(0, 5)} ${formatted.substring(5)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Currency formatter for Indian Rupees
/// Formats with commas and rupee symbol
class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    final text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Parse the number
    final parts = text.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1].substring(0, parts[1].length > 2 ? 2 : parts[1].length)}' : '';

    // Add commas to integer part (Indian numbering system)
    if (integerPart.length > 3) {
      final lastThree = integerPart.substring(integerPart.length - 3);
      final remaining = integerPart.substring(0, integerPart.length - 3);
      
      String formatted = lastThree;
      int count = 0;
      for (int i = remaining.length - 1; i >= 0; i--) {
        if (count == 2) {
          formatted = ',$formatted';
          count = 0;
        }
        formatted = remaining[i] + formatted;
        count++;
      }
      integerPart = formatted;
    }

    final result = integerPart + decimalPart;
    
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Uppercase text formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Name formatter (capitalizes first letter of each word)
class NameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final words = text.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalized,
      selection: newValue.selection,
    );
  }
}
