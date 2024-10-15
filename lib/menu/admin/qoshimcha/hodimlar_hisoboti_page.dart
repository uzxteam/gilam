import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HodimlarHisobotiPage extends StatefulWidget {
  @override
  _HodimlarHisobotiPageState createState() => _HodimlarHisobotiPageState();
}

class _HodimlarHisobotiPageState extends State<HodimlarHisobotiPage> {
  List<dynamic> hodimlar = [];
  List<dynamic> zakazlar = [];
  List<dynamic> maxsulotlar = [];
  List<dynamic> tariflar = [];
  bool isLoading = true;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Load API data when the page is initialized
  }

  Future<void> _fetchData() async {
    final hodimlarResponse = await http.get(Uri.parse('https://visualai.uz/apidemo/hodimlar.php'));
    final zakazlarResponse = await http.get(Uri.parse('https://visualai.uz/apidemo/barchazakazlar.php'));
    final maxsulotlarResponse = await http.get(Uri.parse('https://visualai.uz/apidemo/maxsulot.php'));
    final tariflarResponse = await http.get(Uri.parse('https://visualai.uz/apidemo/tariflar.php'));

    if (hodimlarResponse.statusCode == 200 &&
        zakazlarResponse.statusCode == 200 &&
        maxsulotlarResponse.statusCode == 200 &&
        tariflarResponse.statusCode == 200) {
      final hodimlarData = json.decode(hodimlarResponse.body);
      final zakazlarData = json.decode(zakazlarResponse.body);
      final maxsulotlarData = json.decode(maxsulotlarResponse.body);
      final tariflarData = json.decode(tariflarResponse.body);

      if (!hodimlarData['error'] &&
          maxsulotlarData['status'] == 'success' &&
          tariflarData['status'] == 'success') {
        setState(() {
          hodimlar = hodimlarData['data'];
          zakazlar = zakazlarData;
          maxsulotlar = maxsulotlarData['data'];
          tariflar = tariflarData['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> _filterZakazlarByDate(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return zakazlar;

    return zakazlar.where((zakaz) {
      DateTime registrDate = DateTime.parse(zakaz['registr_date']);
      return registrDate.isAfter(startDate) && registrDate.isBefore(endDate);
    }).toList();
  }

  Map<String, dynamic> _getTarifInfo(String tarifId) {
    // First, make sure you are dealing with a valid Map<String, dynamic>
    var tarif = tariflar.firstWhere(
          (tarif) => tarif['id'] == tarifId,
      orElse: () => null,
    );
    return tarif != null ? Map<String, dynamic>.from(tarif) : {};
  }

  Map<String, dynamic> _getProductInfo(String maxsulotTuriId) {
    // Similarly ensure correct type conversion
    var maxsulot = maxsulotlar.firstWhere(
          (maxsulot) => maxsulot['id'] == maxsulotTuriId,
      orElse: () => null,
    );
    return maxsulot != null ? Map<String, dynamic>.from(maxsulot) : {};
  }


  Map<String, dynamic> _calculateTotalForUser(String userId, String yuvuvId, String qadoqId, String dastavkaId) {
    Map<String, dynamic> totalData = {
      'zakaz': {},
      'yuvuv': {},
      'qadoq': {},
      'dastavka': {}
    };

    _filterZakazlarByDate(startDate, endDate).forEach((zakaz) {
      String maxsulotTuriId = zakaz['maxsulot_turi'];
      String tarifId = zakaz['zakaz_tarif'];
      Map<String, dynamic> productInfo = _getProductInfo(maxsulotTuriId);
      Map<String, dynamic> tarifInfo = _getTarifInfo(tarifId);

      if (productInfo.isNotEmpty && tarifInfo.isNotEmpty) {
        String holati = productInfo['maxsulot_holati'];
        String turi = productInfo['maxsulot_turi'];

        if (zakaz['user_id'] == userId) {
          if (holati == '1') {
            double kvadrat = double.tryParse(zakaz['zakaz_kvadrat']) ?? 0.0;
            totalData['zakaz'][turi] = {
              'kvadrat': (totalData['zakaz'][turi]?['kvadrat'] ?? 0.0) + kvadrat,
            };
          } else if (holati == '2') {
            totalData['zakaz'][turi] = {
              'soni': (totalData['zakaz'][turi]?['soni'] ?? 0) + 1,
            };
          }
        }

        if (zakaz['yuvuv_id'] == yuvuvId) {
          totalData['yuvuv'][turi] = {
            'soni': (totalData['yuvuv'][turi]?['soni'] ?? 0) + 1,
          };
        }

        if (zakaz['qadoq_id'] == qadoqId) {
          totalData['qadoq'][turi] = {
            'soni': (totalData['qadoq'][turi]?['soni'] ?? 0) + 1,
          };
        }

        if (zakaz['dastavka_id'] == dastavkaId) {
          totalData['dastavka'][turi] = {
            'soni': (totalData['dastavka'][turi]?['soni'] ?? 0) + 1,
          };
        }
      }
    });

    return totalData;
  }

  String _getUserRole(String status) {
    switch (status) {
      case '1':
        return 'Zakazchi';
      case '2':
        return 'Yuvuvchi';
      case '3':
        return 'Qadoqlovchi';
      case '4':
        return 'Yetkazib beruvchi';
      case '5':
        return 'Zakazchi + Yetkazib beruvchi';
      case '6':
        return 'Yuvuvchi + Qadoqlovchi';
      case '7':
        return 'Yordamchi Admin';
      default:
        return 'Noma\'lum';
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hodimlar Hisoboti'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hodimlar.length,
        itemBuilder: (context, index) {
          final hodim = hodimlar[index];
          final totalData = _calculateTotalForUser(hodim['id'], hodim['id'], hodim['id'], hodim['id']);
          final userRole = _getUserRole(hodim['user_status']);

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: Icon(Icons.person, size: 40),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: hodim['user_name'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' ($userRole)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (totalData['zakaz'].isNotEmpty) ...[
                    Text('Zakaz oldi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...totalData['zakaz'].entries.map((entry) {
                      return Text('${entry.key}: ${entry.value['kvadrat'] ?? entry.value['soni']}');
                    }).toList(),
                  ],
                  if (totalData['yuvuv'].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Yuvdi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...totalData['yuvuv'].entries.map((entry) {
                      return Text('${entry.key}: ${entry.value['soni']}');
                    }).toList(),
                  ],
                  if (totalData['qadoq'].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Qadoqladi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...totalData['qadoq'].entries.map((entry) {
                      return Text('${entry.key}: ${entry.value['soni']}');
                    }).toList(),
                  ],
                  if (totalData['dastavka'].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Yetkazdi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...totalData['dastavka'].entries.map((entry) {
                      return Text('${entry.key}: ${entry.value['soni']}');
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
