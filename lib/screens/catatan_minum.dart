import 'package:flutter/material.dart';

class CatatanMinumScreen extends StatelessWidget {
  const CatatanMinumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
}
