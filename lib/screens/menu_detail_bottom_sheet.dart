import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuDetailBottomSheet extends StatefulWidget {
  final String menuName;
  final String userId;
  final Function(int count, int calories) onMenuAdded;

  const MenuDetailBottomSheet({
    super.key,
    required this.menuName,
    required this.userId,
    required this.onMenuAdded,
  });

  @override
  _MenuDetailBottomSheetState createState() => _MenuDetailBottomSheetState();
}

class _MenuDetailBottomSheetState extends State<MenuDetailBottomSheet> {
  int itemCount = 1;
  Map<String, dynamic>? menuDetail;
  bool isLoading = true;

  static const MaterialColor customGreen = MaterialColor(
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
  );

  @override
  void initState() {
    super.initState();
    fetchMenuDetail();
  }

  Future<void> fetchMenuDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2/ads_mysql/asupan/bot_sheet_asupan.php?nama_menu=${widget.menuName}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          menuDetail = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load menu detail');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat detail menu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> postMenuDetail() async {
    try {
      // Properly calculate nutritional values
      final kalori =
          (int.tryParse(menuDetail!['kalori'].toString()) ?? 0) * itemCount;
      final protein =
          (int.tryParse(menuDetail!['protein'].toString()) ?? 0) * itemCount;
      final karbohidrat =
          (int.tryParse(menuDetail!['karbohidrat'].toString()) ?? 0) *
              itemCount;
      final lemak =
          (int.tryParse(menuDetail!['lemak'].toString()) ?? 0) * itemCount;
      final gula =
          (int.tryParse(menuDetail!['gula'].toString()) ?? 0) * itemCount;

      // Format the date as YYYY-MM-DD HH:MM:SS
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('http://10.0.2.2/ads_mysql/asupan/simpan_detail_kalori.php'),
        body: {
          'id_user': widget.userId,
          'id_menu': menuDetail!['id_menu'],
          'tanggal': formattedDate,
          'jumlah': itemCount.toString(),
          'total_kalori': kalori.toString(),
          'total_protein': protein.toString(),
          'total_karbohidrat': karbohidrat.toString(),
          'total_lemak': lemak.toString(),
          'total_gula': gula.toString(),
        },
      );

      // Debug response
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Decoded response: $responseData");

        if (responseData['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onMenuAdded(
              itemCount,
              kalori,
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception('Server returned error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to post menu detail: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan menu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (menuDetail == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Tidak ada data menu'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  menuDetail!['nama_menu'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (itemCount > 1) itemCount--;
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: customGreen,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        itemCount++;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: customGreen,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: postMenuDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kalori: ${menuDetail!['kalori']}'),
                  Text('Protein: ${menuDetail!['protein']}'),
                  Text('Karbohidrat: ${menuDetail!['karbohidrat']}'),
                  Text('Lemak: ${menuDetail!['lemak']}'),
                  Text('Gula: ${menuDetail!['gula']}'),
                  Text('Satuan: ${menuDetail!['satuan']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
