import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'olahragaFrame.dart';

class OlahragaItem {
  final String idOlahraga;
  final String namaOlahraga;
  final String kalori;
  final String gambar;
  final String deskripsi;

  OlahragaItem({
    required this.idOlahraga,
    required this.namaOlahraga,
    required this.kalori,
    required this.gambar,
    required this.deskripsi,
  });

  factory OlahragaItem.fromJson(Map<String, dynamic> json) {
    return OlahragaItem(
      idOlahraga: json['id_olahraga'] ?? '',
      namaOlahraga: json['nama_olahraga'] ?? '',
      kalori: json['kalori'] ?? '',
      gambar: json['gambar'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }
}

class SelectedOlahragaScreen extends StatefulWidget {
  final String category;
  final String title;

  const SelectedOlahragaScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  _SelectedOlahragaScreenState createState() => _SelectedOlahragaScreenState();
}

class _SelectedOlahragaScreenState extends State<SelectedOlahragaScreen> {
  List<OlahragaItem> olahragaList = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchOlahraga();
  }

  Future<void> fetchOlahraga() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2/ads_mysql/search/get_olahraga_by_category.php?kategori=${widget.category}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          setState(() {
            olahragaList = (data['data'] as List)
                .map((item) => OlahragaItem.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else if (data.containsKey('error')) {
          setState(() {
            error = data['error'];
            isLoading = false;
          });
        } else if (data.containsKey('message')) {
          setState(() {
            error = data['message'];
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
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: olahragaList.length,
                  itemBuilder: (context, index) {
                    final olahraga = olahragaList[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OlahragaFrame(olahraga: olahraga),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                              child: Image.network(
                                'http://10.0.2.2/ads_mysql/image/${olahraga.gambar}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      olahraga.namaOlahraga,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kalori: ${olahraga.kalori}',
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
