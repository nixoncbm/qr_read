
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart' as drv;
import 'package:test/test.dart';

void main (){
  group('QR scan type url', (){

    final btnScan = drv.find.byValueKey('qr_scan');
    final scaffold = drv.find.byValueKey('scaffold');

    drv.FlutterDriver driver;

    setUpAll(() async {
      driver = await drv.FlutterDriver.connect();
    });
    
    tearDownAll((){
      if(driver != null){
        driver.close();
      }
    });

    test('scan qr', () async {
      await driver.tap(btnScan);

      sleep(Duration(seconds: 6));

      expect(await driver.getText(scaffold), "Guardado correcto...!");

    });
  });

  group('QR scan type plane text', (){

    final btnBack = drv.find.byTooltip('Back');
    final btnScan = drv.find.byValueKey('qr_scan');
    final scaffold = drv.find.byValueKey('scaffold');

    drv.FlutterDriver driver;

    setUpAll(() async {
      driver = await drv.FlutterDriver.connect();
    });

    tearDownAll((){
      if(driver != null){
        driver.close();
      }
    });

    test('scan qr', () async {
      await driver.tap(btnBack);

      sleep(Duration(seconds: 2));

      await driver.tap(btnScan);

      sleep(Duration(seconds: 5));

      expect(await driver.getText(scaffold), "Guardado correcto...!");

    });
  });
}