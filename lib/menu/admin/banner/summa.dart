// summ.dart fayli
import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/qoshimcha/hodimlar_hisoboti_page.dart';

class CartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Cart bosilganda HodimlarHisobotiPage ga o'tkazish
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HodimlarHisobotiPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        width: 320,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFF323232),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Hodimlar hisoboti', // Matn
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.yellow, // Matn rangini sariq qilish
            ),
            textAlign: TextAlign.center, // Matnni o'rtaga joylash
          ),
        ),
      ),
    );
  }
}
