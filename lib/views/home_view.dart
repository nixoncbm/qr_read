import 'package:flutter/material.dart';
import 'package:read_qr/views/qr_saved_view.dart';
import 'package:read_qr/views/qr_scanner_view.dart';

class HomeView extends StatefulWidget {
  static const String ROUTE = "home";

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Read QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selecciona una opción:',
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                key: Key('qr_scan'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(QRScannerView.ROUTE),
                child: Text("ESCANEAR QR")),
            ElevatedButton(
                key: Key('qr_see'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(QRSavedView.ROUTE),
                child: Text("VER CÓDIGOS ESCANEADOS")),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
