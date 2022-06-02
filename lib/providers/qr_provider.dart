import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../main.dart';
import '../utils/barcode_detector_painter.dart';

class QRProvider with ChangeNotifier {

  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  CameraController _controller;
  int _cameraIndex = 0;
  bool _canProcessImage = false;
  bool _cameraProcessing = false;
  CustomPaint _customPaint;
  Barcode _barcodeSelected;
  bool _uploadBarcode = false;
  List<Barcode> _listBarcodes = [];
  List<String> _savedCodes = [];

  List<String> get savedCodes => _savedCodes;

  set savedCodes(List<String> value) {
    _savedCodes = value;
    notifyListeners();
  }

  bool get uploadBarcode => _uploadBarcode;

  set uploadBarcode(bool value) {
    _uploadBarcode = value;
    notifyListeners();
  }

  Barcode get barcodeSelected => _barcodeSelected;

  set barcodeSelected(Barcode value) {
    _barcodeSelected = value;
    notifyListeners();
  }

  List<Barcode> get listBarcodes => _listBarcodes;

  set listBarcodes(List<Barcode> value) {
    _listBarcodes = value;
    notifyListeners();
  }

  CustomPaint get customPaint => _customPaint;

  set customPaint(CustomPaint value) {
    _customPaint = value;
    notifyListeners();
  }

  CameraController get controller => _controller;

  set controller(CameraController value) {
    _controller = value;
    notifyListeners();
  }

  bool get canProcessImage => _canProcessImage;

  set canProcessImage(bool value) {
    _canProcessImage = value;
    notifyListeners();
  }

  /// Inicializar camara
  void initCamera(){
    if(_controller != null) return;
    _canProcessImage = true;
    _uploadBarcode = false;
    _getBackCameraIndex();
    _startLiveFeed();
  }

  ///Obtener la camara trasera del dispositivo
  void _getBackCameraIndex(){
    if (cameras.any(
          (element) =>
      element.lensDirection == CameraLensDirection.back &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
        element.lensDirection == CameraLensDirection.back &&
            element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
              (element) => element.lensDirection == CameraLensDirection.back,
        ),
      );
    }
  }

  /// Inicializar transmision en vivo de la camara
  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize()?.then((_) {
      _controller?.startImageStream(_processCameraImage);
    });
  }

  /// Parar la transmision en vivo de la camara
  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  ///Procesar la imagen para mostrar en la vista
  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processQRImage(inputImage, bytes);
  }

  ///Procesar la imagen para obtener los codigos QR
  Future<void> _processQRImage(InputImage inputImage, Uint8List image) async {
    if (!_canProcessImage) return;
    if (_cameraProcessing) return;
    _cameraProcessing = true;
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = BarcodeDetectorPainter(
          barcodes,
          inputImage.inputImageData.size,
          inputImage.inputImageData.imageRotation);
      customPaint = CustomPaint(painter: painter);
      if(barcodes.length > 0){
        _canProcessImage = false;
        _controller.pausePreview();
        listBarcodes = barcodes;
        if(_listBarcodes.length == 1){
          barcodeSelected = _listBarcodes.first;
          if(barcodeSelected.type != BarcodeType.url){
            sendBarcode();
          }
        }
      }
    } else {
      customPaint = null;
    }
    _cameraProcessing = false;
  }

  void close(){
    _canProcessImage = false;
    _listBarcodes = null;
    _barcodeScanner?.close();
    _stopLiveFeed();
  }

  ///Reiniciar los procesos de preview de la camara
  ///Delay para prevenir el reescaneo anterior
  void resumeCamera() {
    Future.delayed(Duration(milliseconds: 270), (){
      barcodeSelected = null;
      listBarcodes = null;
      controller?.resumePreview();
      canProcessImage = true;
    });
  }

  ///Simular el envio de los datos
  void sendBarcode(){
    uploadBarcode = true;
    Future.delayed(Duration(seconds: 1), () {
      _savedCodes ??= [];
      savedCodes.add(_barcodeSelected.rawValue);
      uploadBarcode = false;
      globalScaffold.currentState.showSnackBar(SnackBar(content: Text("Guardado correcto...!", key: Key('scaffold'),)));
      resumeCamera();
    },);
  }

  ///Quita un elemento de los qr guardados
  void removeCode(int index) {
    _savedCodes.removeAt(index);
    notifyListeners();
  }

}