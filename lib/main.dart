import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=42ec313c";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.purple,
        primaryColor: Colors.purple,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          hintStyle: TextStyle(color: Colors.purple),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar = 0;
  double euro = 0;
  double btc = 0;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(6);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    btcController.text = (euro * this.euro / btc).toStringAsFixed(6);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(6);
  }

  void _btcChanged(String text) {
    double btc = double.parse(text);
    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
    euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            "\$ Conversor de moedas \$",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.purple,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.purple, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao carregar dados... :(",
                      style: TextStyle(color: Colors.purple, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data!["results"]["currencies"]["USD"]["buy"];
                    euro =
                        snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                    btc = snapshot.data!["results"]["currencies"]["BTC"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.purple,
                          ),
                          buildTextField(
                              "Real", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField(
                              "Dólar", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euro", "€", euroController, _euroChanged),
                          Divider(),
                          buildTextField(
                              "BTC", "₿", btcController, _btcChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) changed) {
  return TextField(
    onChanged: changed,
    keyboardType: TextInputType.number,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.purple, fontSize: 25.0),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.purple, fontSize: 25.0),
  );
}
