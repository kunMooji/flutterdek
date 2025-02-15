// File: resepFrame.dart
import 'package:flutter/material.dart';
import 'package:mesorry/screens/selectedFood.dart'; // Import untuk mengakses class FoodItem

class ResepFrame extends StatelessWidget {
  final FoodItem food;

  ResepFrame({required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.namaMenu),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar makanan
            Container(
              width: double.infinity,
              height: 200,
              child: Image.network(
                'http://10.0.2.2/ads_mysql/image/${food.gambar}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error, size: 50),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Informasi kalori
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(width: 10),
                    Text(
                      'Kalori:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      food.kalori,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Resep
            Text(
              'Resep',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              food.resep,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}