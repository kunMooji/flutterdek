import 'package:flutter/material.dart';
import 'dart:async';

class BussinesScreen extends StatefulWidget {
  const BussinesScreen({Key? key}) : super(key: key);

  @override
  _BussinesScreenState createState() => _BussinesScreenState();
}

class _BussinesScreenState extends State<BussinesScreen> {
  int _currentImageIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();
  int selectedMenuCount = 0;
  int totalCalories = 0;
  final TextEditingController _searchController = TextEditingController();
  int _activeTabIndex = 0; // 0: Cari Makanan, 1: Terakhir Dimakan, 2: Catatan Minum

  // Custom color scheme
  static const MaterialColor customGreen = MaterialColor(
    0xFF00880C,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF00880C), // Primary
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  // Carousel items
  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'assets/carousel1.jpg',
      'title': 'Special Menu 1',
    },
    {
      'image': 'assets/carousel2.jpg',
      'title': 'Special Menu 2',
    },
    {
      'image': 'assets/carousel3.jpg',
      'title': 'Special Menu 3',
    },
  ];

  // Food menu items
  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Ayam Goreng', 'calories': 250},
    {'name': 'Ayam Kecap', 'calories': 300},
    {'name': 'Opor Ayam', 'calories': 280},
    {'name': 'Ayam Panggang', 'calories': 220},
    {'name': 'Ayam Pedas', 'calories': 260},
    {'name': 'Abon', 'calories': 180},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentImageIndex < _carouselItems.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _switchTab(int index) {
    setState(() {
      _activeTabIndex = index;
    });
  }

  Widget _buildTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildCariMakananTab();
      case 1:
        return _buildTerakhirDimakanTab();
      case 2:
        return _buildCatatanMinumTab();
      default:
        return _buildCariMakananTab();
    }
  }

  Widget _buildCariMakananTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari makanan/minuman',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),

        // Selected menu counter
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Jumlah Menu'),
                  Text(
                    '$selectedMenuCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Total Kalori'),
                  Text(
                    '$totalCalories',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Menu list
        Expanded(
          child: ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(menuItems[index]['name']),
                  subtitle: Text('${menuItems[index]['calories']} kalori'),
                  onTap: () {
                    setState(() {
                      selectedMenuCount++;
                      totalCalories += menuItems[index]['calories'] as int;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTerakhirDimakanTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Riwayat Makanan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Makanan yang terakhir dimakan akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanMinumTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_drink, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Catatan Minum',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Catat asupan air minum harian Anda di sini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Asupan Hari Ini',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tab buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(0),
                  child: _buildTabButton('Cari Makanan', _activeTabIndex == 0),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(1),
                  child: _buildTabButton('Terakhir Dimakan', _activeTabIndex == 1),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(2),
                  child: _buildTabButton('Catatan Minum', _activeTabIndex == 2),
                ),
              ),
            ],
          ),

          // Tab content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? customGreen : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? customGreen : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}