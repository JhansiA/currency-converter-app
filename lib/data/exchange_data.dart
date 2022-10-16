import 'package:http/http.dart' as http;
import 'dart:convert';
const apikey = 'KpZQ9JXO9U6dFdQZuy3VwQpF9LNiaCnI';
const exchangeAppUrl = 'https://api.apilayer.com/exchangerates_data/convert';

class ExchangeData {

  Future getExchangeData(selectedCurrency,currencyList,amount) async{
    Map<String,String> exchangeCurrencyValues = {};

    for(String currency in currencyList){

      String requestURL = '$exchangeAppUrl?apikey=$apikey&to=$currency&from=$selectedCurrency&amount=$amount';
      http.Response response = await http.get(Uri.parse(requestURL));
      if(response.statusCode==200){
        var decodedData = jsonDecode(response.body);
        var value = decodedData['result'];
        exchangeCurrencyValues[currency] = value.toStringAsFixed(0);
      }
      else{print(response.statusCode);}
    }
    return exchangeCurrencyValues;
  }
}
