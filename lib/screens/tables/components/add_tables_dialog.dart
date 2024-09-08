import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';

void showAddTableDialog(BuildContext context) async {
  final _titleController = TextEditingController();

  // Verilen tablo numarasına göre ID belirleyen harita
  Map<String, String> idToTableNumber = {
    '38232': '1',
    '23894': '2',
    '59382': '3',
    '49283': '4',
    '10293': '5',
    '83749': '6',
    '58293': '7',
    '72938': '8',
    '48392': '9',
    '28374': '10',
    '38475': '11',
    '71938': '12',
    '39475': '13',
    '29485': '14',
    '48592': '15',
    '58392': '16',
    '41283': '17',
    '59483': '18',
    '11293': '19',
    '20394': '20',
    '29384': '21',
    '31475': '22',
    '42283': '23',
    '73938': '24',
    '32475': '25',
    '21485': '26',
    '41592': '27',
    '51392': '28',
    '43283': '29',
    '53483': '30',
    '13293': '31',
    '25394': '32',
    '23384': '33',
    '35475': '34',
    '45283': '35',
    '76938': '36',
    '36475': '37',
    '22485': '38',
    '18592': '39',
    '18392': '40',
    '19283': '41',
    '19483': '42',
    '20293': '43',
    '30394': '44',
    '39384': '45',
    '48475': '46',
    '59283': '47',
    '62938': '48',
    '78475': '49',
    '89485': '50',
  };

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
                      keyboardType: TextInputType
                          .number, // Sadece sayı girişi için klavye tipi
                      decoration: InputDecoration(
                        labelText: 'Masa Numarası (1-50)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Sadece sayı girişine izin verir
                        LengthLimitingTextInputFormatter(
                            2), // En fazla 2 karakter (50'yi aşmaz)
                        CustomRangeTextInputFormatter(
                            min: 1, max: 50), // 1-50 aralığını kontrol eder
                      ],
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
                      content: Text(
                          'Masa numarası alanı zorunludur. Lütfen doldurun.'),
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
                String title = _titleController.text
                    .trim(); // Trim ile gereksiz boşlukları kaldır

                // title değerine göre tableID'yi haritadan belirle
                String? tableID;
                idToTableNumber.forEach((key, value) {
                  if (value == title) {
                    tableID = key;
                  }
                });

                // Aynı tableID'yi veritabanında kontrol et
                final existingTable = await FirebaseFirestore.instance
                    .collection('tables')
                    .where('tableID', isEqualTo: tableID)
                    .get();
                if (existingTable.docs.isNotEmpty) {
                  // Eğer aynı tableID ile bir masa varsa uyarı ver
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Uyarı'),
                        content: Text(
                            'Bu masa numarası ile zaten bir masa kayıtlı.'),
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
                  // QR kodu oluştur ve Firebase Storage'a yükle
                  final qrImageBytes = await generateQRCode(
                    'https://menu.enjula.com/#$tableID',
                    'Enjula\n${"Masa " + _titleController.text}',
                  );
                  final qrImageUrl =
                      await uploadImageToFirebase(qrImageBytes, tableID!);

                  // Veriyi Firestore'a ekle
                  try {
                    await myTables.addNewTableAndRefresh(
                        _titleController.text, tableID!, qrImageUrl);
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
              }
            },
          ),
        ],
      );
    },
  );
}

class CustomRangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  CustomRangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Girilen değeri sayıya çevir
    final int? value = int.tryParse(newValue.text);

    if (value == null || value < min || value > max) {
      // Eğer sayı değilse ya da 1 ile 50 arasında değilse eski değeri döndür
      return oldValue;
    }

    // Geçerli ise yeni değeri döndür
    return newValue;
  }
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

  // QR kod boyutu
  final Size qrSize = const Size(350, 350);

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint backgroundPaint = Paint()..color = Colors.white;

  // QR kodu çiz
  painter.paint(canvas, qrSize);

  // Yazı alanının genişliği QR kodun 3'te 1'i olacak şekilde
  final double labelWidth = qrSize.width / 3;
  final double labelHeight = 50.0; // Yükseklik yazı için ayarlanır

  // Beyaz arka plan (yazının arkasına)
  final double labelX = (qrSize.width - labelWidth) / 2; // Ortalamak için
  final double labelY = (qrSize.height - labelHeight) / 2; // Ortalamak için
  final Rect labelRect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

  canvas.drawRect(labelRect, backgroundPaint);

  // Yazıyı çiz
  final labelPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: Colors.grey,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  labelPainter.layout(minWidth: 0, maxWidth: labelWidth);

  // Yazıyı ortala
  final offset = Offset(
    labelX + (labelWidth - labelPainter.width) / 2,
    labelY + (labelHeight - labelPainter.height) / 2,
  );
  labelPainter.paint(canvas, offset);

  // Kenarlık çizimi
  final borderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  canvas.drawRect(labelRect, borderPaint);

  final picture = recorder.endRecording();
  final img =
      await picture.toImage(qrSize.width.toInt(), qrSize.height.toInt());
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
