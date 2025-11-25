import 'package:flutter/material.dart';
import 'coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'services/network.dart';
import 'reuseble.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  late FixedExtentScrollController controller;
  String selectedCurrency = 'USD';
  Map<String, double?> cryptoValue = {};
  String? allCurrencies = "";
  String? selectedCrypto = "";
  Map<String, Map<String, String>>? allData = {};

  void getAllCurrencies() {
    for (String currency in currenciesList) {
      allCurrencies = allCurrencies! + currency + ",";
    }
    for (String crypto in cryptoList) {
      selectedCrypto = selectedCrypto! + coinId[crypto]! + ",";
    }
  }

  Future<void> setSelectedCurrency() async {
    getAllCurrencies(); // assuming this is sync
    print(allCurrencies);
    try {
      final network = Network(
        'https://api.coingecko.com/api/v3/simple/price'
        '?ids=$selectedCrypto'
        '&vs_currencies=${allCurrencies!.toLowerCase()}',
      );

      final data = await network.getData();
      allData ??= {};

      for (final crypto in cryptoList) {
        final id = coinId[crypto]!;
        allData![crypto] = {};

        for (final currency in currenciesList) {
          final key = currency.toLowerCase();
          final rawValue = data[id]?[key];
          allData![crypto]![key] = rawValue == null
              ? 'N/A'
              : rawValue.toString();
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    fetchData(); // still ok to call this here
    print(allData);
  }

  double? parseValue(String crypto, String currency) {
    final raw = allData?[crypto]?[currency.toLowerCase()];
    if (raw == null || raw == "N/A") return null;
    return double.tryParse(raw);
  }

  void fetchData() {
    if (allData == null) {
      print('Unable to fetch data');
      setState(() {
        for (String crypto in cryptoList) {
          cryptoValue[crypto] = null;
        }
        allCurrencies = "";
      });
      return;
    }
    setState(() {
      for (String crypto in cryptoList) {
        cryptoValue[crypto] = parseValue(crypto, selectedCurrency);
      }
    });
    print(cryptoValue);
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
    print("Loaded!");
  }

  @override
  void initState() {
    super.initState();
    setSelectedCurrency();
    int initialIndex = currenciesList.indexOf('USD');
    controller = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  DropdownButton<String> getANDROIDDropdownButton() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      dropdownItems.add(
        DropdownMenuItem(value: currency, child: Text(currency)),
      );
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value!;
        });
        print(selectedCurrency);
      },
    );
  }

  CupertinoPicker getIOSCupertinoPickerItems() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      itemExtent: 32.0,
      scrollController: controller,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          fetchData();
          print(selectedCurrency);
        });
      },
      children: pickerItems,
    );
  }

  Widget getPickerWidget() {
    return Platform.isIOS
        ? getIOSCupertinoPickerItems()
        : getANDROIDDropdownButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              setSelectedCurrency();
              fetchData();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (String crypto in cryptoList)
                      Reuseble().buildCryptoCard(
                        crypto,
                        cryptoValue[crypto]?.toStringAsFixed(2) ?? '?',
                        selectedCurrency,
                      ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: getIOSCupertinoPickerItems(),
          ),
        ],
      ),
    );
  }
}
