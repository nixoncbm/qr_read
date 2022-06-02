import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_qr/providers/qr_provider.dart';
import 'package:read_qr/views/home_view.dart';
import 'package:read_qr/views/qr_saved_view.dart';
import 'package:read_qr/views/qr_scanner_view.dart';

List<CameraDescription> cameras = [];
final GlobalKey<ScaffoldMessengerState> globalScaffold = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QRProvider>(create: (_) => QRProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Read QR',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: HomeView.ROUTE,
        routes: {
          HomeView.ROUTE: (_) => HomeView(),
          QRScannerView.ROUTE: (_) => QRScannerView(),
          QRSavedView.ROUTE: (_) => QRSavedView(),
        },
        scaffoldMessengerKey: globalScaffold,
      ),
    );
  }
}
