import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String _name = '';
  String _email = '';
  String _weight = '';
  String _height = '';
  String _dob = '';
  String _imagePath = '';
  double _bmi = 0.0;
  String _bmiCategory = '';
  Color _bmiColor = Colors.grey;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id_user');

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2/ads_mysql/account/get_profile.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id_user': userId}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            final userData = data['user_data'];
            setState(() {
              _name = userData['nama_lengkap'] ?? 'Name not found';
              _email = userData['email'] ?? 'Email not found';
              _weight = userData['berat_badan'] ?? '0';
              _height = userData['tinggi_badan'] ?? '0';
              _dob = userData['tanggal_lahir'] ?? '';
              _imagePath = userData['gambar'] ?? '';

              // Calculate BMI
              if (_weight.isNotEmpty && _height.isNotEmpty) {
                double weight = double.tryParse(_weight) ?? 0;
                double height = double.tryParse(_height) ?? 0;
                if (height > 0) {
                  _bmi = weight / ((height / 100) * (height / 100));
                  _setBmiCategory();
                  _animationController.forward();
                }
              }
            });
          }
        } else {
          throw Exception('Failed to load user data');
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  void _setBmiCategory() {
    if (_bmi < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiColor = Colors.blue;
    } else if (_bmi >= 18.5 && _bmi < 25) {
      _bmiCategory = 'Normal';
      _bmiColor = Colors.green;
    } else if (_bmi >= 25 && _bmi < 30) {
      _bmiCategory = 'Overweight';
      _bmiColor = Colors.orange;
    } else {
      _bmiCategory = 'Obese';
      _bmiColor = Colors.red;
    }
  }

  String _calculateAge() {
    if (_dob.isEmpty) return 'N/A';

    try {
      final birthDate = DateTime.parse(_dob);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileInfo(),
              _buildBmiSection(),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: _imagePath.isNotEmpty
                  ? NetworkImage('http://10.0.2.2/ads_mysql/images/$_imagePath')
                  : const AssetImage('assets/dj.png') as ImageProvider,
              onBackgroundImageError: (error, stackTrace) {
                print('Error loading image: $error');
              },
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(Icons.fitness_center, 'Weight', '$_weight kg'),
            _buildInfoItem(Icons.height, 'Height', '$_height cm'),
            _buildInfoItem(Icons.cake, 'Age', '${_calculateAge()} years'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _bmiCategory,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _bmiColor,
                  ),
                ),
                Text(
                  _bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animation.value *
                      (_bmi / 40), // Normalized to max BMI of 40
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_bmiColor),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('18.5',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('25', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('30', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('40', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
