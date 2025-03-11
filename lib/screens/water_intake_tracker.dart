import 'package:flutter/material.dart';

class WaterIntakeView extends CustomPainter {
  final double percentage;

  WaterIntakeView({this.percentage = 0.0});
  
  @override
void paint(Canvas canvas, Size size) {
  // Draw water intake circle visualization
  final Paint circlePaint = Paint()
    ..color = Colors.blue.withOpacity(0.3)
    ..style = PaintingStyle.fill;
    
  final Paint waterPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
  
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width / 2;
  
  // Draw background circle
  canvas.drawCircle(center, radius, circlePaint);
  
  // Draw water level based on percentage
  if (percentage > 0) {
    // Create a clipping path for the circle
    final Path clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    
    canvas.save();
    canvas.clipPath(clipPath);
    
    // Calculate the water fill height based on percentage
    final waterTop = size.height * (1 - percentage);
    
    // Draw water as a rectangle, but it will be clipped to the circle shape
    canvas.drawRect(
      Rect.fromLTRB(0, waterTop, size.width, size.height),
      waterPaint,
    );
    
    canvas.restore();
  }
}
  
  @override
  bool shouldRepaint(WaterIntakeView oldDelegate) => 
    oldDelegate.percentage != percentage;
}

class WaterIntakeTracker extends StatefulWidget {
  @override
  _WaterIntakeTrackerState createState() => _WaterIntakeTrackerState();
}

class _WaterIntakeTrackerState extends State<WaterIntakeTracker> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedTab = 0;
  double _waterIntake = 0.0;
  double _maxWaterIntake = 2000.0; // Default 2L daily goal
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedTab = _tabController!.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  void _addWater(double amount) {
    setState(() {
      _waterIntake = (_waterIntake + amount).clamp(0, _maxWaterIntake);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title
            Text(
              'Asupan Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
            SizedBox(height: 20),
            
            // Tab Bar
            Container(
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.teal,
                unselectedLabelColor: Color(0xFF555555),
                indicatorColor: Colors.teal,
                tabs: [
                  Tab(text: 'Cari Makanan'),
                  Tab(text: 'Terakhir Dimakan'),
                  Tab(text: 'Catatan Minum'),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Main Content - Water Intake Section
            Expanded(
  child: Container(
    color: Color(0xFFE7FBF9),
    padding: EdgeInsets.all(20),
    child: Center(
      child: AspectRatio(
        aspectRatio: 1, // Keep it circular
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return CustomPaint(
              painter: WaterIntakeView(
                percentage: _waterIntake / _maxWaterIntake,
              ),
              size: Size(size, size),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_waterIntake.toInt()} ml',
                      style: TextStyle(
                        fontSize: size * 0.08, // Responsive text size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'dari ${_maxWaterIntake.toInt()} ml',
                      style: TextStyle(
                        fontSize: size * 0.053, // Responsive text size
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    ),
  ),
),
            
            // Increase/Decrease Buttons
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrease Button
                  Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.remove, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: () => _addWater(-100),
                    ),
                  ),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      // Save water intake logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Catatan minum air disimpan!'))
                      );
                    },
                    child: Text(
                      'SIMPAN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00CDBD),
                      minimumSize: Size(200, 40),
                    ),
                  ),
                ],
              ),
            ),
            
            // Water Amount Presets
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWaterPresetButton(100, 'bg_water100ml'),
                  SizedBox(width: 10),
                  _buildWaterPresetButton(250, 'bg_water250ml'),
                  SizedBox(width: 10),
                  _buildWaterPresetButton(500, 'bg_water500ml'),
                  SizedBox(width: 10),
                  _buildCustomButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaterPresetButton(int amount, String bgImage) {
  return InkWell(
    onTap: () => _addWater(amount.toDouble()),
    child: Container(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Smaller image with aspect ratio
          SizedBox(
            width: 30, // Adjust this value to make the image smaller
            height: 30, // Adjust this value to make the image smaller
            child: Image.asset(
              'assets/$bgImage.png',
              fit: BoxFit.contain,
            ),
          ),
          // Text positioned at the top
          Positioned(
            bottom: 2,
            child: Text(
              '$amount ml',
              style: TextStyle(
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  
  Widget _buildCustomButton() {
  return InkWell(
    onTap: () {
      // Show dialog to enter custom amount
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Jumlah Kustom'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah (ml)',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _addWater(double.tryParse(value) ?? 0);
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Logic handled in TextField onSubmitted
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    },
    child: Container(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Smaller image with aspect ratio
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/bg_waterlainnya.png',
              fit: BoxFit.contain,
            ),
          ),
          // Text positioned at the bottom
          Positioned(
            bottom: 2,
            child: Text(
              'Lainnya',
              style: TextStyle(
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}