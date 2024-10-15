import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class TugallanganPage extends StatefulWidget {
  @override
  _ZakazlarPageState createState() => _ZakazlarPageState();
}

class _ZakazlarPageState extends State<TugallanganPage> {
  List<dynamic> zakazlarList = [];
  DateTimeRange? selectedDateRange; // Sanalar oralig'i uchun o'zgaruvchi
  List<dynamic> filteredZakazlarList = []; // Filtrlash uchun zakazlar ro'yxati

  String _formatSum(dynamic sum) {
    final formatter = NumberFormat('#,###');
    int actualSum;
    if (sum is String) {
      actualSum = int.parse(sum);
    } else {
      actualSum = sum;
    }
    return formatter.format(actualSum);
  }

  @override
  void initState() {
    super.initState();
    _fetchZakazlar(); // Zakazlar ma'lumotlarini yuklash
  }

  // API orqali zakazlar ro'yxatini yuklash
  Future<void> _fetchZakazlar() async {
    final url = 'https://visualai.uz/apidemo/tugadi.php?zakaz_status=5';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            zakazlarList = data['data'];
            filteredZakazlarList = zakazlarList; // Asl ro'yxatni saqlaymiz
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ma\'lumotlar yuklanmadi'),
          ));
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Internet ulanishi xato'),
      ));
    }
  }

  // Ma'lumotlarni tanlangan vaqt oralig'iga qarab filtrlaydi
  void _filterZakazlarByDateRange(DateTimeRange? dateRange) {
    if (dateRange != null) {
      print('Tanlangan boshlanish sanasi: ${dateRange.start}');
      print('Tanlangan tugash sanasi: ${dateRange.end}');

      setState(() {
        filteredZakazlarList = zakazlarList.where((zakaz) {
          // "registr_date" ni DateTime obyektiga o'girib, sanalarni solishtirish
          DateTime registrDate = DateTime.parse(zakaz['registr_date']);
          print('Tekshirilayotgan zakazning registr_date: $registrDate');

          // Sanalar oralig'ini tekshirish
          bool isInDateRange = (registrDate.isAfter(dateRange.start) || registrDate.isAtSameMomentAs(dateRange.start)) &&
              (registrDate.isBefore(dateRange.end) || registrDate.isAtSameMomentAs(dateRange.end));

          print('Zakaz sanasi oralig\'ida: $isInDateRange');
          return isInDateRange;
        }).toList();
      });
    }
  }

  // Sanalar oralig'ini tanlash
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        _filterZakazlarByDateRange(selectedDateRange); // Zakazlar ro'yxatini sanaga qarab filtrlaymiz
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tugallangan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Orqaga qaytish tugmasi
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white), // Date icon tugmasi
            onPressed: () {
              _selectDateRange(context); // Sana oralig'ini tanlash
            },
          ),
        ],
      ),
      body: filteredZakazlarList.isEmpty
          ? Center(child: CircularProgressIndicator()) // Ma'lumotlar yuklanayotganda
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredZakazlarList.length,
          itemBuilder: (context, index) {
            final zakaz = filteredZakazlarList[index];
            return _buildZakazCard(zakaz);
          },
        ),
      ),
    );
  }

  // Har bir zakaz uchun karta yaratish
  Widget _buildZakazCard(Map<String, dynamic> zakaz) {
    bool showAdditionalInfo = zakaz['showAdditionalInfo'] ?? false;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildZakazBasicDetails(zakaz),
                _buildCallIcon(zakaz['mijoz']['mijoz_telefon']),
              ],
            ),
            if (showAdditionalInfo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  _buildZakazAdditionalDetails(zakaz),
                  Divider(),
                  _buildZakazProductDetails(zakaz['zakazlar']),
                ],
              ),
            _buildToggleAdditionalInfo(zakaz),
          ],
        ),
      ),
    );
  }

  // Asosiy ma'lumotlarni ko'rsatish
  Widget _buildZakazBasicDetails(Map<String, dynamic> zakaz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zakaz ID: ${zakaz['zakaz_id']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Hodim: ${zakaz['hodim']['user_name']}',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          'Mijoz: ${zakaz['mijoz']['mijoz_ismi']}',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          'Manzil: ${zakaz['mijoz']['mijoz_adres']}',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Qo'ng'iroq qilish ikonkasi
  Widget _buildCallIcon(String phoneNumber) {
    return GestureDetector(
      onTap: () async {
        final url = 'tel:$phoneNumber';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          print('Telefon raqamiga qo\'ng\'iroq qilish mumkin emas: $phoneNumber');
        }
      },
      child: Icon(
        Icons.phone,
        color: Colors.blue,
        size: 28,
      ),
    );
  }

  // Qo'shimcha ma'lumotlarni ko'rsatish
  Widget _buildZakazAdditionalDetails(Map<String, dynamic> zakaz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jami summa: ${zakaz['jami_summa']}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
          ),
        ),
        Text(
          'Chegirma: ${zakaz['skidka_summa']}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
          ),
        ),
        Text(
          'Qoldiq summa: ${zakaz['qoldiq_summa']}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
          ),
        ),
        if (zakaz['zakaz_haqida'] != null && zakaz['zakaz_haqida'].isNotEmpty)
          Text(
            'Zakaz haqida: ${zakaz['zakaz_haqida']}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  // Zakaz tarkibidagi maxsulotlarni ko'rsatish
  Widget _buildZakazProductDetails(List<dynamic> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zakaz tarkibi:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...products.map((product) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maxsulot turi: ${product['maxsulot_turi']['nomi']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Miqdori: ${product['zakaz_soni']} dona',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Kvadrat: ${product['zakaz_kvadrat']} m²',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Summa: ${product['zakaz_summa']} so\'m',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Tarif: ${product['zakaz_tarif']['nomi']}',
                style: TextStyle(fontSize: 16),
              ),
              Divider(),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Qo'shimcha ma'lumotlarni ko'rsatish va yashirish uchun tugma
  Widget _buildToggleAdditionalInfo(Map<String, dynamic> zakaz) {
    return GestureDetector(
      onTap: () {
        setState(() {
          zakaz['showAdditionalInfo'] = !(zakaz['showAdditionalInfo'] ?? false);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            zakaz['showAdditionalInfo'] == true ? 'Yopish' : 'Ko\'proq',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Icon(
            zakaz['showAdditionalInfo'] == true ? Icons.expand_less : Icons.expand_more,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
