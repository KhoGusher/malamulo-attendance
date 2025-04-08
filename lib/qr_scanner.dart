import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';
import 'db_helper.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String lastScannedCode = ""; // To track the last scanned code
  int scannedCount = 0; // To keep track of scanned codes

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Section')),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              isScanning
                  ? Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isScanning) {
        String scannedCode = scanData.code!;

        // Check if this is a repeat scan of the same code
        if (scannedCode == lastScannedCode) {
          return; // Ignore the scan if it's the same as the last scanned code
        }

        // Update the last scanned code
        lastScannedCode = scannedCode;

        // Get the current date and time
        DateTime now = DateTime.now();
        String date = DateFormat('yyyy-MM-dd').format(now); // Separate date
        String time = DateFormat('kk:mm:ss').format(now); // Separate time

        // Check if the scanned code already exists in the database
        bool isAlreadyScanned = await DBHelper().isCodeScanned(scannedCode);

        if (!isAlreadyScanned) {
          // Insert the new code into the database
          await DBHelper().insertAttendee({
            'name': scannedCode,
            'date': date, // Insert date
            'time': time, // Insert time
          });
          scannedCount++;

          // Trigger vibration
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 100); // Vibrate for 100 milliseconds
          }

          // Turn on the flashlight
          // await TorchLight.enableTorch();

          // Delay before turning off the flashlight
          // Future.delayed(const Duration(milliseconds: 5000), () async {
          //   await TorchLight.disableTorch();
          // });

          // Show the SnackBar with scanned info and count
          _showScannedSnackBar(context, scannedCode, scannedCount);
        } else {
          // Notify the user that the code was already scanned
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This code has already been scanned.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  void _showScannedSnackBar(BuildContext context, String code, int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ID: $code'),
            Text('Count: $count'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
