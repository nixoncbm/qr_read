import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_qr/providers/qr_provider.dart';

class QRSavedView extends StatelessWidget {
  static const String ROUTE = "savedQrViewRoute";
  const QRSavedView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    QRProvider _qrProvider = Provider.of<QRProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Código Escaneados"),
      ),
      body: ListView.builder(
        itemCount: _qrProvider?.savedCodes?.length ?? 0,
        itemBuilder: (context, index) {
          String code = _qrProvider.savedCodes[index];
          return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: Text("$code")),
                IconButton(onPressed: () {
                  _qrProvider.removeCode(index);
                }, icon: Icon(Icons.delete_forever))
              ],
            ),
          );
        },
      ),
    );
  }
}
