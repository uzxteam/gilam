import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BatafsilPage extends StatefulWidget {
  @override
  _BatafsilPageState createState() => _BatafsilPageState();
}

class _BatafsilPageState extends State<BatafsilPage> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  String selectedFilter = 'Barchasi';
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://visualai.uz/api/kirimlar.php'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          data = jsonData['data'];
          filteredData = data; // Dastlab barcha ma'lumotlarni yuklash
          print('Kelgan ma\'lumotlar: $filteredData');
        });
      } else {
        print('Ma\'lumotlarni olishda xatolik: ${response.statusCode}');
      }
    } catch (error) {
      print('Ma\'lumotlarni olishda xatolik: $error');
    }
  }

  void _filterData(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Barchasi') {
        filteredData = data;
      } else if (filter == 'Kirimlar') {
        filteredData = data.where((item) => item['kirim_status'] == '2').toList();
      } else if (filter == 'Chiqimlar') {
        filteredData = data.where((item) => item['kirim_status'] == '1').toList();
      }
    });
  }

  void _filterDataByDate(DateTimeRange? range) {
    setState(() {
      selectedDateRange = range;
      if (range == null) {
        filteredData = data; // Hech qanday sanani tanlanmagan holat
      } else {
        filteredData = data.where((item) {
          DateTime itemDate = DateTime.parse(item['registr_date']);
          return itemDate.isAfter(range.start.subtract(Duration(days: 1))) &&
              itemDate.isBefore(range.end.add(Duration(days: 1)));
        }).toList();
      }
    });
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 7)),
            end: DateTime.now(),
          ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDateRange) {
      _filterDataByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kirim va Chiqimlar'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDateRange, // Sana tanlash uchun funksiya chaqiriladi
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _filterData('Barchasi'),
                      child: Text('Barchasi', style: TextStyle(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: selectedFilter == 'Barchasi' ? Colors.blue : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _filterData('Kirimlar'),
                      child: Text('Kirimlar', style: TextStyle(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: selectedFilter == 'Kirimlar' ? Colors.blue : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _filterData('Chiqimlar'),
                      child: Text('Chiqimlar', style: TextStyle(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: selectedFilter == 'Chiqimlar' ? Colors.blue : Colors.grey.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  print('Element: $item'); // Elementni konsolga chiqaramiz
                  return Card(
                    color: Colors.white.withOpacity(0.7),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(
                        item['kirim_status'] == '1' ? Icons.arrow_upward : Icons.arrow_downward,
                        color: item['kirim_status'] == '2' ? Colors.green : Colors.red,
                      ),
                      title: Text(item['kirim_nomi'] ?? 'Nomi yo\'q'), // Null check
                      subtitle: Text('${item['summa']} so\'m'),
                      trailing: Text(
                        item['registr_date']?.split(' ')[0] ?? '', // Null check
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
