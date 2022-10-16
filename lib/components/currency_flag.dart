class CurrencyFlag {
  /// Return Flag (Emoji Unicode) of a given currency
  static String currencyToEmoji(String currencycode) {
    // final String currencyFlag = currency.flag!;
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = currencycode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = currencycode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);

  }
}

