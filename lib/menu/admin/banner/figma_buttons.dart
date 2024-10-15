import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/banner/batafsil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Add this import for number formatting

class Property1Frame40959 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 327,
        height: 100,
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Color(0xFF393939),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 'Kirim' menu
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: 'Kirim',
                        isAvans: false,
                        isChiqim: false, // Not Chiqim
                      );
                    },
                  );
                },
                child: buildMenuColumn('Kirim', 'assets/2.png'),
              ),
            ),
            // 'Chiqim' menu
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: 'Chiqim',
                        isAvans: false,
                        isChiqim: true, // This is Chiqim
                      );
                    },
                  );
                },
                child: buildMenuColumn('Chiqim', 'assets/3.png'),
              ),
            ),
            // 'Avans' menu
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: 'Avans',
                        isAvans: true, // This is Avans
                        isChiqim: false,
                      );
                    },
                  );
                },
                child: buildMenuColumn('Avans', 'assets/1.png'),
              ),
            ),
            // 'Batafsil' menu (no dialog)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BatafsilPage()),
                  );
                },
                child: buildMenuColumn('Batafsil', 'assets/4.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildMenuColumn(String title, String asset) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          child: Image.asset(asset),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// CustomDialog widget
class CustomDialog extends StatefulWidget {
  final String title;
  final bool isAvans; // Add a flag to determine if it's the Avans dialog
  final bool isChiqim; // Add a flag to determine if it's the Chiqim dialog

  const CustomDialog({
    required this.title,
    required this.isAvans,
    required this.isChiqim,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  List<dynamic> kirimTuriList = [];
  String? selectedKirimTuri;
  bool isLoading = false; // Add loading state
  TextEditingController summaController = TextEditingController();
  TextEditingController izohController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isAvans) {
      // Use hardcoded values for Avans
      kirimTuriList = [
        {"id": "1", "kirim_nomi": "Avans"},
        {"id": "2", "kirim_nomi": "Oylik"},
      ];
    } else {
      fetchKirimTuri(); // Fetch from API for other dialogs
    }
  }

  Future<void> fetchKirimTuri() async {
    final response = await http.get(Uri.parse('https://visualai.uz/apidemo/kirim_turi.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          kirimTuriList = data['data'];
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Helper function to format numbers with commas
  String formatCurrency(String value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(double.tryParse(value) ?? 0);
  }

  Future<void> sendKirimData() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    int kirimStatus = 1; // Default to 1 for both Chiqim and Avans

    // If it's not Avans or Chiqim, set kirim_status to 2
    if (!widget.isAvans && !widget.isChiqim) {
      kirimStatus = 2;
    }

    final kirimData = {
      "kirim_turi": int.parse(selectedKirimTuri ?? "1"), // Set default value if null
      "kirim_status": kirimStatus,
      "kirim_summa": double.parse(summaController.text.replaceAll(',', '')), // Remove commas before sending
      "kirim_izoh": izohController.text,
    };

    final response = await http.post(
      Uri.parse('https://visualai.uz/apidemo/kirim_add.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kirimData),
    );

    setState(() {
      isLoading = false; // Hide loading indicator
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        Navigator.of(context).pop(); // Close the dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data successfully saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send data to the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.title} kiriting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF393939),
              ),
            ),
            SizedBox(height: 20),
            // Improved Dropdown for selecting 'Kirim turi'
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xFFf5f5f5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF393939)),
              ),
              child: DropdownButton<String>(
                hint: Text(
                  'Kirim turi tanlang',
                  style: TextStyle(color: Color(0xFF393939)),
                ),
                value: selectedKirimTuri,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedKirimTuri = newValue;
                  });
                },
                underline: SizedBox(), // Remove the default underline
                isExpanded: true, // Make the dropdown take full width
                items: kirimTuriList.map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value['id'],
                    child: Text(
                      value['kirim_nomi'],
                      style: TextStyle(color: Color(0xFF393939)),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // TextField for Summa with number formatting
            TextField(
              controller: summaController,
              onChanged: (value) {
                setState(() {
                  // Reformat the entered value
                  summaController.text = formatCurrency(value.replaceAll(',', ''));
                  // Move the cursor to the end
                  summaController.selection = TextSelection.fromPosition(
                    TextPosition(offset: summaController.text.length),
                  );
                });
              },
              decoration: InputDecoration(
                labelText: 'Summa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // TextField for Izoh (comments)
            TextField(
              controller: izohController,
              decoration: InputDecoration(
                labelText: 'Izoh',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.comment),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: sendKirimData,
              child: Text('Saqlash'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF393939), // Set the text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
