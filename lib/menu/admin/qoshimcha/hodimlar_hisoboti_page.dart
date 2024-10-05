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
  bool isLoading = true; // Ma'lumotlar yuklanayotganini belgilash

  @override
  void initState() {
    super.initState();
    _fetchData(); // Sahifa yuklanganida API ma'lumotlarini olish
  }

  Future<void> _fetchData() async {
    // Hodimlar ma'lumotini olish
    final hodimlarResponse = await http.get(Uri.parse('https://visualai.uz/api/hodimlar.php'));

    // Zakazlar ma'lumotini olish
    final zakazlarResponse = await http.get(Uri.parse('https://visualai.uz/api/barchazakazlar.php'));

    if (hodimlarResponse.statusCode == 200 && zakazlarResponse.statusCode == 200) {
      final hodimlarData = json.decode(hodimlarResponse.body);
      final zakazlarData = json.decode(zakazlarResponse.body);

      if (!hodimlarData['error']) {
        setState(() {
          hodimlar = hodimlarData['data']; // Hodimlar ma'lumotlari
          zakazlar = zakazlarData; // Zakazlar ma'lumotlari
          isLoading = false; // Yuklanish tugadi
        });
      } else {
        setState(() {
          isLoading = false; // Ma'lumotlarda xatolik bo'lsa yuklanishni to'xtatamiz
        });
      }
    } else {
      setState(() {
        isLoading = false; // API xatolik bo'lsa yuklanishni to'xtatamiz
      });
    }
  }

  double _calculateTotalKvadratForUser(String userId) {
    double totalKvadrat = 0.0;

    // Hodimning barcha zakazlarini ko'rib chiqish va zakaz_kvadrat ni qo'shish
    zakazlar.forEach((zakaz) {
      if (zakaz['user_id'] == userId) {
        totalKvadrat += double.tryParse(zakaz['zakaz_kvadrat']) ?? 0.0;
      }
    });

    return totalKvadrat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hodimlar Hisoboti'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Ma'lumotlar yuklanayotganida loader
          : ListView.builder(
        itemCount: hodimlar.length,
        itemBuilder: (context, index) {
          final hodim = hodimlar[index];
          final totalKvadrat = _calculateTotalKvadratForUser(hodim['id']); // Hodimning umumiy kvadrati

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: Icon(Icons.person, size: 40),
              title: Text(hodim['user_name'], style: TextStyle(fontSize: 18)),
              subtitle: Text('Umumiy kvadrat: $totalKvadrat m²'), // Umumiy kvadrat ko'rsatish
            ),
          );
        },
      ),
    );
  }
}
