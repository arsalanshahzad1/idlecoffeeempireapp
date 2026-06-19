class NumberFormatter {
  const NumberFormatter._();

  static String compact(double value) {
    final abs = value.abs();
    if (abs >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(abs >= 10000000000 ? 0 : 1)}B';
    }
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
    }
    if (abs >= 1000) {
      return '${(value / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}K';
    }
    return value.toStringAsFixed(value == value.floorToDouble() ? 0 : 1);
  }

  static String whole(int value) {
    final abs = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < abs.length; i++) {
      final indexFromEnd = abs.length - i;
      buffer.write(abs[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    final text = buffer.toString();
    return value < 0 ? '-$text' : text;
  }
}
