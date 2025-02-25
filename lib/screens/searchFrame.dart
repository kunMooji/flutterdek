import 'package:flutter/material.dart';
import 'dart:async';
import 'selectedFood.dart';
import 'selectedOlahraga.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentImageIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();

  // Custom color scheme inspired by GoJek
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

  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'assets/food1.jpg',
      'title': 'Hidangan Spesial',
      'subtitle': 'Nikmati masakan terbaik kami'
    },
    {
      'image': 'assets/food2.jpg',
      'title': 'Menu Sehat',
      'subtitle': 'Pilihan makanan sehat untuk Anda'
    },
    {
      'image': 'assets/food3.jpg',
      'title': 'Dessert Premium',
      'subtitle': 'Manjakan lidah Anda'
    }
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
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentImageIndex < _carouselItems.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      _pageController.animateToPage(
        _currentImageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // App Bar
              Container(
                padding: EdgeInsets.all(16.0),
                color: customGreen,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: customGreen),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selamat Datang!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Search Bar with enhanced design
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari makanan favoritmu...',
                    prefixIcon: Icon(Icons.search, color: customGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: customGreen),
                    ),
                  ),
                ),
              ),

              // Enhanced Carousel
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: _carouselItems.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  _carouselItems[index]['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _carouselItems[index]['title']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _carouselItems[index]['subtitle']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Enhanced Dots Indicator
                    Positioned(
                      bottom: 10,
                      right: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _carouselItems.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.all(4),
                            width: _currentImageIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentImageIndex == index
                                  ? customGreen
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Sections
              _buildSection(
                'Resep Pilihan',
                [
                  {
                    'icon': Icons.restaurant_menu,
                    'title': 'Makanan Berat',
                    'subtitle': 'Menu utama'
                  },
                  {
                    'icon': Icons.local_drink,
                    'title': 'Minuman Sehat',
                    'subtitle': 'Fresh & sehat'
                  },
                  {
                    'icon': Icons.cake,
                    'title': 'Dessert',
                    'subtitle': 'Penutup lezat'
                  },
                ],
              ),

              _buildSection(
                'Program Olahraga',
                [
                  {
                    'icon': Icons.directions_run,
                    'title': 'Kardio',
                    'subtitle': '30 menit'
                  },
                  {
                    'icon': Icons.fitness_center,
                    'title': 'Kekuatan',
                    'subtitle': '45 menit'
                  },
                  {
                    'icon': Icons.timer,
                    'title': 'Interval',
                    'subtitle': '20 menit'
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(color: customGreen),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showItemDialog(items[index]['title']),
                  child: Container(
                    width: 140,
                    margin: EdgeInsets.all(4),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: customGreen.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              items[index]['icon'],
                              size: 32,
                              color: customGreen,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            items[index]['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            items[index]['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(String title) {
    switch (title) {
      // Food categories
      case 'Dessert':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedFoodScreen(
              category: 'dessert',
              title: 'Menu Dessert',
            ),
          ),
        );
        break;
      case 'Makanan Berat':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedFoodScreen(
              category: 'makanan_berat',
              title: 'Menu Makanan Berat',
            ),
          ),
        );
        break;
      case 'Minuman Sehat':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedFoodScreen(
              category: 'minuman_sehat',
              title: 'Menu Minuman Sehat',
            ),
          ),
        );
        break;

      // Exercise categories
      case 'Kardio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedOlahragaScreen(
              category: 'kardio',
              title: 'Menu Kardio',
            ),
          ),
        );
        break;
      case 'Kekuatan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedOlahragaScreen(
              category: 'kekuatan',
              title: 'Menu Kekuatan',
            ),
          ),
        );
        break;
      case 'Interval':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedOlahragaScreen(
              category: 'interval',
              title: 'Menu Interval',
            ),
          ),
        );
        break;

      default:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(title),
              content: Text('Menu ini sedang dalam pengembangan'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Tutup',
                    style: TextStyle(color: customGreen),
                  ),
                ),
              ],
            );
          },
        );
    }
  }
}
