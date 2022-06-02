import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
import 'package:read_qr/providers/qr_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScannerView extends StatefulWidget {
  static const String ROUTE = "scannerViewRoute";
  @override
  _QRScannerViewState createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  QRProvider qrProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    qrProvider?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    qrProvider = Provider.of<QRProvider>(context);
    qrProvider.initCamera();

    return Scaffold(
      appBar: AppBar(
        key: Key('back'),
        title: Text("Scaner QR"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (qrProvider.controller?.value?.isInitialized)
                  AspectRatio(
                      aspectRatio: qrProvider.controller.value.aspectRatio,
                      child: CameraPreview(qrProvider.controller)),
                if (qrProvider.customPaint != null) qrProvider.customPaint,
                if (qrProvider.uploadBarcode) ...[
                  _SavingBarcode()
                ] else if ((qrProvider?.listBarcodes?.length ?? 0) > 0) ...[
                  if (qrProvider.barcodeSelected != null) ...[
                    if (qrProvider.barcodeSelected.type == BarcodeType.url) ...[
                      _BarcodeSelected()
                    ]
                  ] else ...[
                    _ListBarcodes()
                  ]
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeSelected extends StatelessWidget {
  const _BarcodeSelected({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    QRProvider _qrProvider = Provider.of<QRProvider>(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () => _qrProvider.resumeCamera(),
                    icon: Icon(Icons.close))),
            Text(
              "¿Qué deseas hacer con el código QR?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text("${_qrProvider.barcodeSelected.rawValue}"),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  child: Text("GUARDAR"),
                  onPressed: () => _qrProvider.sendBarcode(),
                )),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: ElevatedButton(
                  child: Text("ABRIR"),
                  onPressed: () {
                    launchUrl(Uri.parse(_qrProvider.barcodeSelected.rawValue), mode: LaunchMode.externalApplication).then((send) {
                      if(!send) print('No se pudo abrir el link');
                    });
                  },
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ListBarcodes extends StatelessWidget {
  const _ListBarcodes({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    QRProvider _qrProvider = Provider.of<QRProvider>(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Selecciona el código QR que quierés utilizar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _qrProvider.listBarcodes?.length ?? 0,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final barcode = _qrProvider.listBarcodes[index];
                  return InkWell(
                    onTap: () {
                      _qrProvider.barcodeSelected = barcode;
                      if(_qrProvider.barcodeSelected.type != BarcodeType.url){
                        _qrProvider.sendBarcode();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Text("${barcode.rawValue}"),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class _SavingBarcode extends StatelessWidget {
  const _SavingBarcode({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Guardando código QR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: LinearProgressIndicator(),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
