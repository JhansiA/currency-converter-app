import 'package:flutter/material.dart';
import 'package:currency_converter/screens/currencyExchange_Screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        // home: CurrencyExchange_Screen(),
      initialRoute: CurrencyExchangeScreen.id,
      routes: {
        CurrencyExchangeScreen.id: (context) => CurrencyExchangeScreen(),
      },
    );
  }
}
