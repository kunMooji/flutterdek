import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'resepFrame.dart'; 

class FoodItem {
  final String idMenu;
  final String namaMenu;
  final String kalori;
  final String gambar;
  final String resep;

  FoodItem({
    required this.idMenu,
    required this.namaMenu,
    required this.kalori,
    required this.gambar,
    required this.resep,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      idMenu: json['id_menu'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kalori: json['kalori'] ?? '',
      gambar: json['gambar'] ?? '',
      resep: json['resep'] ?? '',
    );
  }
}

class SelectedFoodScreen extends StatefulWidget {
  final String category;
  final String title;

  const SelectedFoodScreen({super.key, 
    required this.category,
    required this.title,
  });

  @override
  _SelectedFoodScreenState createState() => _SelectedFoodScreenState();
}

class _SelectedFoodScreenState extends State<SelectedFoodScreen> {
  List<FoodItem> foods = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/ads_mysql/search/get_food_by_category.php?kategori=${widget.category}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          setState(() {
            foods = (data['data'] as List)
                .map((item) => FoodItem.fromJson(item))
                .toList();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load ${widget.category}: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
      print('Error fetching ${widget.category}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                // Navigasi ke ResepFrame alih-alih menampilkan dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResepFrame(food: food),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Image.network(
                      'http://10.0.2.2/ads_mysql/image/${food.gambar}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.namaMenu,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kalori: ${food.kalori}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}