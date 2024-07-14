import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:admin/constants.dart';
import 'package:admin/date_service.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';

void showAddTableDialog(BuildContext context) async {
  final _titleController = TextEditingController();

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  final myTables = context.read<TablesPageViewModel>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shadowColor: Colors.yellow,
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Center(
          child: Column(
            children: [
              Text(
                'Yeni Masa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: spaceHeight),
              Divider(
                color: Colors.white,
              ),
            ],
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                width: SizeConstants.width * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Masa Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: spaceHeight),
                    Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('İptal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Ekle'),
            onPressed: () async {
              if (_titleController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Uyarı'),
                      content:
                          Text('Masa adı alanı zorunludur. Lütfen doldurun.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Tamam'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                String tableID = DateService().createEpoch(DateTime.now());

                // QR kodu oluştur ve Firebase Storage'a yükle
                final qrImageBytes = await generateQRCode(
                  'http://menu.enjula.com/#$tableID',
                  'Enjula\n${_titleController.text}',
                );
                final qrImageUrl =
                    await uploadImageToFirebase(qrImageBytes, tableID);

                // Verileri Firestore'a kaydet
                try {
                  await myTables.addNewTableAndRefresh(
                      _titleController.text, tableID, qrImageUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Masa başarıyla eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (error) {
                  print("Firestore'a veri eklerken hata: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Masa eklenirken hata oluştu: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<Uint8List> generateQRCode(String data, String label) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
  );
  final qrCode = qrValidationResult.qrCode;
  final painter = QrPainter.withQr(
    qr: qrCode!,
    color: const Color(0xFF000000),
    emptyColor: const Color(0xFFFFFFFF),
    gapless: true,
    embeddedImageStyle: null,
    embeddedImage: null,
  );

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Size size = const Size(350, 350);
  painter.paint(canvas, size);

  final labelPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 24,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.grey,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  labelPainter.layout(minWidth: 0, maxWidth: size.width);
  final offset = Offset(
    (size.width - labelPainter.width) / 2,
    (size.height - labelPainter.height) / 2,
  );
  labelPainter.paint(canvas, offset);

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<String> uploadImageToFirebase(
    Uint8List imageBytes, String tableID) async {
  final storage = FirebaseStorage.instance;

  try {
    final storageRef = storage.ref().child("qr_images/$tableID.png");
    final uploadTask = storageRef.putData(imageBytes);
    await uploadTask.whenComplete(() {});

    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Resim yükleme hatası: $e");
    return "";
  }
}
