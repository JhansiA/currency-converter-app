import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:currency_converter/components/currency_flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:currency_converter/data/exchange_data.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  static String id = 'currencyexchange_screen';

  const CurrencyExchangeScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  bool isWaiting = false;
  bool showEditScreen = false;
  // bool isDelete = false;
  Map<String,dynamic> favourite = {};
  Map<String, String> exchangeData = {};
  String selectedCurrency = "";
  double amount = 0;

  void readCurrencyPreference () async{
    try {
      final prefs = await SharedPreferences.getInstance();
      String? encodedMap = prefs.getString('selectedCurrencies');
      Map<String, dynamic> decodedMap = json.decode(encodedMap!);
      setState(() {
        favourite = decodedMap.isEmpty ?  {'USD': 'United States Dollar'} :decodedMap;
      });
    }
    catch(e){print(e);}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readCurrencyPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: const Text('Currency'),backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
      child: isWaiting
          ? const Center(
            child: CircularProgressIndicator(),
      )
          :Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Card(
              child: ListTile(
                leading: IconButton(iconSize: 30, icon: const Icon(Icons.add),onPressed: (){
                  _currencyPicker();
                },color: Colors.lightBlueAccent,),
                trailing: TextButton(onPressed: (){
                  setState(() {
                    if(showEditScreen) {
                      showEditScreen = false;
                      saveCurrencyPreference(favourite);
                    }
                    else{
                    showEditScreen = true;}
                  });
                },
                style: TextButton.styleFrom(primary: Colors.lightBlueAccent),
                  child: showEditScreen? const Text('Done'): const Text('Edit')),
          ),
        ),
          Expanded(
            child: SingleChildScrollView(
            child: showEditScreen?
            Column(
                children: favourite.entries.map((element) => editFavoriteCurrencyList(element)).toList(),
                )
            : Column(
              children: favourite.entries.map((element) => favoriteCurrencyList(element)).toList(),
            ),
          ),
          ),
        ],
      ),
    ),
    );
  }

  Widget editFavoriteCurrencyList(favCurrency){
    return Card(
      child: ListTile(
        leading: IconButton(iconSize: 30, icon: const Icon(Icons.delete),onPressed: (){
        setState(() {
          favourite.remove(favCurrency.key);
        });

      },color: Colors.red,),
        title: Text(favCurrency.key),
        subtitle: Text(favCurrency.value),

        ),
    );
  }

  Widget favoriteCurrencyList(favCurrency){
      return Card(
        child: InkWell(
          hoverColor: Colors.lightBlueAccent,
          highlightColor:  Colors.lightBlueAccent,
          onTap: ()  {
            
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                isDismissible: false,
                builder: (context) => SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: _simpleCalculator(favCurrency),
                  ),
                )
            );
            },
         child: ListTile(leading: _flagWidget(favCurrency.key),
           title: Text(favCurrency.key),
           subtitle: Text(favCurrency.value),
           trailing: Text(style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.lightBlueAccent,
           fontSize: 20),
               exchangeData.isNotEmpty ? exchangeData[favCurrency.key].toString() :'0'
           ),
        )),
      );
  }
  
  Widget _flagWidget(String currencyCode) {
    return Text(
      CurrencyFlag.currencyToEmoji(currencyCode),
      style: const TextStyle(
        fontSize: 25,
      ),
    );
  }

  Future<dynamic> _currencyPicker(){
    return showCurrencyPicker(
        context: context,
        showFlag: true,
        showSearchField: true,
        showCurrencyName: true,
        showCurrencyCode: true,
        favorite: favourite,
        onSelect: (Currency currency) {
          setState(() {
            if(favourite.containsKey(currency.code)){
              favourite.remove(currency.code);
            }
            else {
              favourite[currency.code] = currency.name;
              if(selectedCurrency != "" && amount != 0) {
                isWaiting = true;
                getData(selectedCurrency,amount);
              }
            }
            saveCurrencyPreference(favourite);
          });});
  }

  Widget _simpleCalculator(currency) {
    return ListView(
      children: [Column(
        children: [ListTile(leading: _flagWidget(currency.key),
          title: Text(currency.key),
          subtitle: Text(currency.value),
          trailing: IconButton(iconSize: 20, icon: const Icon(Icons.close),onPressed: (){
            Navigator.pop(context);
          },color: Colors.lightBlueAccent,),
        ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: TextField(
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter value to convert',
                ),
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              onChanged: (newText) {
                setState(() {
                  selectedCurrency = currency.key;
                  amount = double.parse(newText);
                });
              },
            ),
          ),
          ElevatedButton.icon(onPressed: (){
            if(amount != 0){
              Navigator.pop(context);
              setState((){
              isWaiting = true;
              getData(selectedCurrency,amount);
              });}

           }, icon: const Icon(Icons.currency_exchange), label: const Text('Convert',style: TextStyle(fontSize: 20),),
          ),
        ],
      ),]
    );
  }

  void saveCurrencyPreference(Map<String,dynamic> favorite) async{
    final prefs = await SharedPreferences.getInstance();
    try{
    String encodedMap = json.encode(favorite);
    prefs.setString('selectedCurrencies', encodedMap);
    }
    catch(e){print(e);}
  }

  void getData(selectedCurrency, amount) async {
    // String selectedCurrency = 'USD';
    try {
      var data = await ExchangeData().getExchangeData(selectedCurrency,favourite.keys,amount);
      setState(() {
        exchangeData = data;
        isWaiting = false;
      });
    } catch (e) {
      print(e);
    }
  }
}

