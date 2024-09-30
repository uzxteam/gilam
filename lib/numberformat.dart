import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    int? value = int.tryParse(newValue.text.replaceAll(',', ''));
    if (value == null) {
      return oldValue;
    }
    String newText = _numberFormat.format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
