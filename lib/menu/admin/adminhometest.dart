import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/banner/batafsil.dart';
import 'package:gilam/menu/admin/banner/summa.dart';
import 'package:gilam/menu/admin/batafsil/dastavgabiriktirish.dart';
import 'package:gilam/menu/admin/batafsil/dastavka.dart';
import 'package:gilam/menu/admin/batafsil/qadoq.dart';
import 'package:gilam/menu/admin/batafsil/tugallangan.dart';
import 'package:gilam/menu/admin/batafsil/yuvish.dart';
import 'adminhome.dart';
import 'banner/banners_page.dart'; // Banner sahifasini import qilish
import 'banner/figma_buttons.dart'; // Figma tugmalarini import qilish

class AdminHomeTestPage extends StatefulWidget {
  @override
  _AdminHomeTestPageState createState() => _AdminHomeTestPageState();
}

class _AdminHomeTestPageState extends State<AdminHomeTestPage> {
  final PageController _pageController = PageController(); // PageController yaratiladi
  int _currentIndex = 0;

  // Sahifalar ro'yxati
  final List<Widget> _pages = [
    HomePage(),
    AdminHomePage(),
  ];

  // BottomNavigationBar tugmalarini tanlash funksiyasi
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index); // Sahifani almashtirish uchun PageView ga o'tish
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent, // Backgroundni shaffof qiladi
        elevation: 0, // Elevation (soya) ni olib tashlaydi
        selectedItemColor: Colors.blue, // Tanlangan element rangi
        unselectedItemColor: Colors.grey, // Tanlanmagan element rangi
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  List<BannerInfo> banners = [];

  @override
  void initState() {
    super.initState();
    _loadBannerData();
  }

  Future<void> _loadBannerData() async {
    try {
      List<BannerInfo> fetchedBanners = await fetchBannerData();
      setState(() {
        banners = fetchedBanners;
      });
    } catch (error) {
      print('Ma\'lumotlarni olishda xatolik: $error');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Admin Paneli'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Orqa fon rasmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bannerlar uchun PageView
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 100), // AppBar'dan pastga bo'shliq qo'shildi
                height: 200, // Banner balandligini oshirish
                child: banners.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Ma'lumotlarni yuklash jarayoni
                    : PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    return BannerCardWidget(
                      title: banners[index].title,
                      amount: banners[index].amount,
                      color: banners[index].color,
                      zakazStatus: banners[index].zakazStatus,
                      zakazSoni: banners[index].zakazSoni, // Zakaz soni qo'shildi
                      onDetailPressed: () {
                        // Har bir banner uchun sahifaga yo'naltirish
                        switch (banners[index].zakazStatus) {
                          case '1':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => YuvuvPage()),
                            );
                            break;
                          case '2':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QadoqPage()),
                            );
                            break;
                          case '3':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DastavgabiriktirishPage()),
                            );
                            break;
                          case '4':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DastavkaadminPage()),
                            );
                            break;
                          case '5':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TugallanganPage()),
                            );
                            break;
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10), // Bannerdan pastdagi bo'shliqni kamaytirish
              Property1Frame40959(), // Figma tugmalarini aks ettiradi
              SizedBox(height: 10),
              CartWidget(),
            ],
          ),
        ],
      ),
    );
  }
}

