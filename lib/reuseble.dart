import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Reuseble {
  Widget buildCryptoCard(String? bitcoinValue, String selectedCurrency) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 BTC = ${bitcoinValue != 0 ? bitcoinValue : '?'} $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
