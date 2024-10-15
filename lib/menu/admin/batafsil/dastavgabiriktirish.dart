import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DastavgabiriktirishPage extends StatefulWidget {
  @override
  _DastavgabiriktirishPageState createState() => _DastavgabiriktirishPageState();
}

class _DastavgabiriktirishPageState extends State<DastavgabiriktirishPage> {
  List<dynamic> zakazlarList = [];
  List<dynamic> dastavkachilarList = [];
  bool isEditing = false; // Editing panel visibility toggle
  int? selectedZakazId;
  int? selectedDastavkachiId;

  @override
  void initState() {
    super.initState();
    _fetchZakazlar(); // Zakazlar ma'lumotlarini yuklash
    _fetchDastavkachilar(); // Dastavkachilar ma'lumotlarini yuklash
  }

  // API orqali zakazlar ro'yxatini yuklash
  Future<void> _fetchZakazlar() async {
    final url = 'https://visualai.uz/apidemo/dastavka_update.php?zakaz_status=4';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data); // Debugging
        if (data['status'] == 'success') {
          setState(() {
            zakazlarList = data['data'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ma\'lumotlar yuklanmadi: ${data['message']}'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Serverdan noto\'g\'ri javob: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Internet ulanishi xato'),
      ));
    }
  }

  // API orqali dastavkachilar ro'yxatini yuklash
  Future<void> _fetchDastavkachilar() async {
    final url = 'https://visualai.uz/apidemo/shopirlar.php'; // Corrected API endpoint
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data); // Debugging: Check the entire response
        if (data['error'] == false) {
          setState(() {
            dastavkachilarList = data['data']; // Assign the fetched data
            print(dastavkachilarList); // Debugging: Check assigned data
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Dastavkachilar yuklanmadi: ${data['message']}'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Serverdan noto\'g\'ri javob: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Internet ulanishi xato'),
      ));
    }
  }

  // Zakaz va Dastavkachi biriktirish
  Future<void> _assignDastavkachiToZakaz() async {
    if (selectedZakazId == null || selectedDastavkachiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Iltimos, zakaz va dastavkachini tanlang!'),
      ));
      return;
    }

    final url = 'https://visualai.uz/apidemo/shopir_update.php';
    final body = json.encode({
      'user_id': selectedDastavkachiId,
      'zakaz_id': selectedZakazId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final responseData = json.decode(response.body);
      if (!responseData['error']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Dastavkachi muvaffaqiyatli biriktirildi!'),
        ));
        setState(() {
          isEditing = false; // Close the panel
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Xatolik yuz berdi: ${responseData['message']}'),
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Internet ulanishi xato'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dastavkaga biriktirish',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Orqaga qaytish tugmasi
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Main zakaz list
          _buildZakazList(),

          // Sliding editing panel
          _buildEditingPanel(),
        ],
      ),
    );
  }

  // Zakazlar ro'yxatini qurish
  Widget _buildZakazList() {
    return zakazlarList.isEmpty
        ? Center(child: CircularProgressIndicator()) // Ma'lumotlar yuklanayotganda
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: zakazlarList.length,
        itemBuilder: (context, index) {
          final zakaz = zakazlarList[index];
          return _buildZakazCard(zakaz);
        },
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
            _buildEditButton(zakaz['zakaz_id']), // Add edit button with zakaz_id
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

  // Tahrirlash panelini ko'rsatish tugmasi
  Widget _buildEditButton(int zakazId) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          setState(() {
            isEditing = true; // Show editing panel
            selectedZakazId = zakazId; // Set selected zakaz ID
          });
        },
      ),
    );
  }

// Tahrirlash paneli
  Widget _buildEditingPanel() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: isEditing ? 0 : -300, // Adjust the position based on `isEditing`
      top: 0,
      bottom: 0,
      child: Container(
        width: 300,
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zakaz ID: $selectedZakazId',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Dastavkachiga biriktiring:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            _buildDastavkachilarDropdown(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false; // Close the panel
                    });
                  },
                  child: Text('Yopish'),
                ),
                ElevatedButton(
                  onPressed: _assignDastavkachiToZakaz,
                  child: Text('Tastiqlash'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Dastavkachilar uchun DropdownButton yaratish
  // Dastavkachilar uchun DropdownButton yaratish
  Widget _buildDastavkachilarDropdown() {
    return DropdownButton<int>(
      isExpanded: true,
      hint: Text('Dastavkachini tanlang'),
      value: selectedDastavkachiId,
      items: dastavkachilarList
          .map((dastavkachi) {
        // Check for null values and handle them appropriately
        final int? id = int.tryParse(dastavkachi['id'] ?? '');
        final String userName = dastavkachi['user_name'] ?? 'No name';
        if (id == null) return null; // If id is null, skip this item
        return DropdownMenuItem<int>(
          value: id,
          child: Text(userName),
        );
      })
          .whereType<DropdownMenuItem<int>>() // Filter out null items and ensure type safety
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedDastavkachiId = value;
        });
      },
    );
  }

}
