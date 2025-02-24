import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'riwayat_makanan.dart';
import 'catatan_minum.dart';

class BussinesScreen extends StatefulWidget {
  const BussinesScreen({super.key});

  @override
  _BussinesScreenState createState() => _BussinesScreenState();
}

class _BussinesScreenState extends State<BussinesScreen> {
  final int _currentImageIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();
  int selectedMenuCount = 0;
  int totalCalories = 0;
  final TextEditingController _searchController = TextEditingController();
  int _activeTabIndex = 0;
  List<dynamic> menuItems = [];
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
    fetchMenuItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchMenuItems() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2/ads_mysql/asupan/get_menu_asupan.php'));

      if (response.statusCode == 200) {
        setState(() {
          menuItems = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMenuDetail(String namaMenu) async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/ads_mysql/asupan/bot_sheet_asupan.php?nama_menu=$namaMenu'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        int itemCount = 1;

        showModalBottomSheet(
          context: context,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25,
          ),
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['nama_menu'],
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    if (itemCount > 1) itemCount--;
                                  });
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                color: customGreen,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  itemCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    itemCount++;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: customGreen,
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedMenuCount += itemCount;
                                    totalCalories += (int.tryParse(
                                                data['kalori'].toString()) ??
                                            0) *
                                        itemCount;
                                  });
                                  postMenuDetail(
                                    data['id_menu'], // Kirim id_menu
                                    data['nama_menu'],
                                    itemCount,
                                    int.tryParse(data['kalori'].toString()) ??
                                        0,
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customGreen,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kalori: ${data['kalori']}'),
                              Text('Protein: ${data['protein']}'),
                              Text('Karbohidrat: ${data['karbohidrat']}'),
                              Text('Lemak: ${data['lemak']}'),
                              Text('Gula: ${data['gula']}'),
                              Text('Satuan: ${data['satuan']}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat detail menu'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        return const RiwayatMakananScreen();
      case 2:
        return const CatatanMinumScreen();
      default:
        return _buildCariMakananTab();
    }
  }

  Future<void> postMenuDetail(
      String idMenu, String namaMenu, int itemCount, int kalori) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/ads_mysql/asupan/post_menu_detail.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id_user': '0508e',
          'id_menu': idMenu,
          'nama_menu': namaMenu,
          'jumlah': itemCount,
          'total_kalori': kalori * itemCount,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to post menu detail');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan menu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCariMakananTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
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
                  title: Text(menuItems[index]['nama_menu']),
                  subtitle: const Text('Tap untuk melihat detail'),
                  onTap: () {
                    fetchMenuDetail(menuItems[index]['nama_menu']);
                  },
                ),
              );
            },
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                  child:
                      _buildTabButton('Terakhir Dimakan', _activeTabIndex == 1),
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
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }
}
