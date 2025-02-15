import 'package:flutter/material.dart';
import 'package:mesorry/screens/HomeFrame.dart';
import 'package:mesorry/screens/searchFrame.dart';
import 'screens/profile.dart';
import 'screens/supply.dart';
import 'screens/konsultasiFrame.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthy Food App',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF00880C,
          <int, Color>{
            50: Color(0xFFE8F5E9),
            100: Color(0xFFC8E6C9),
            200: Color(0xFFA5D6A7),
            300: Color(0xFF81C784),
            400: Color(0xFF66BB6A),
            500: Color(0xFF00880C),
            600: Color(0xFF43A047),
            700: Color(0xFF388E3C),
            800: Color(0xFF2E7D32),
            900: Color(0xFF1B5E20),
          },
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id_user');

      setState(() {
        _isAuthenticated = userId != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00880C),
          ),
        ),
      );
    }

    return _isAuthenticated ? const MainPage() : const LoginScreen();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Set Home (index 2) as default
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    BussinesScreen(),
    SearchScreen(),
    HomeScreen(),
    KonsultasiScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 2) { // Home is at index 2
      _onItemTapped(2);
      return false;
    }
    return true;
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      if (index > _currentIndex) {
        _animationController.forward(from: 0.0);
      } else {
        _animationController.reverse(from: 1.0);
      }
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: _pages[index],
                  );
                },
              );
            },
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF00880C),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.food_bank_outlined),
                activeIcon: Icon(Icons.food_bank),
                label: 'Asupan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_information_outlined),
                activeIcon: Icon(Icons.medical_information),
                label: 'Konsultasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}