import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gilam/menu/admin/banner/batafsil.dart';
import 'package:gilam/menu/admin/banner/summa.dart';
import 'package:gilam/menu/admin/batafsil/dastavgabiriktirish.dart';
import 'package:gilam/menu/admin/batafsil/dastavka.dart';
import 'package:gilam/menu/admin/batafsil/qadoq.dart';
import 'package:gilam/menu/admin/batafsil/tugallangan.dart';
import 'package:gilam/menu/admin/batafsil/yuvish.dart';
import 'package:easy_localization/easy_localization.dart'; // Tarjimani qo'llash uchun import

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
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  final List<Widget> _pages = [
    HomePage(),
    AdminHomePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home'.tr(), // Tarjima qo'shildi
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings'.tr(), // Tarjima qo'shildi
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
        title: Text('admin_panel'.tr()), // Tarjima qo'shildi
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 100),
                  height: 200,
                  child: banners.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      return BannerCardWidget(
                        title: banners[index].title,
                        amount: banners[index].amount,
                        color: banners[index].color,
                        zakazStatus: banners[index].zakazStatus,
                        zakazSoni: banners[index].zakazSoni,
                        onDetailPressed: () {
                          switch (banners[index].zakazStatus) {
                            case '1':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YuvuvPage()),
                              );
                              break;
                            case '2':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QadoqPage()),
                              );
                              break;
                            case '3':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DastavgabiriktirishPage()),
                              );
                              break;
                            case '4':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DastavkaadminPage()),
                              );
                              break;
                            case '5':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TugallanganPage()),
                              );
                              break;
                          }
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Property1Frame40959(),
                SizedBox(height: 10),
                CartWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
