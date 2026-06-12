import 'package:flutter/material.dart';

class PharmacistScreen extends StatefulWidget {
  const PharmacistScreen({super.key});

  @override
  State<PharmacistScreen> createState() => _PharmacistScreenState();
}

class _PharmacistScreenState extends State<PharmacistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _cart = [];
  final List<String> _selectedInteractionMeds = [];
  bool _checkingInteractions = false;
  Map<String, dynamic>? _interactionResult;
  bool _scanningPrescription = false;

  final List<Map<String, dynamic>> _medicines = [
    {'id': 'MED-001', 'name': 'Amoxicillin 500mg', 'price': 85000, 'unit': 'Hộp'},
    {'id': 'MED-002', 'name': 'Panadol Extra', 'price': 45000, 'unit': 'Hộp'},
    {'id': 'MED-003', 'name': 'Decolgen Forte', 'price': 38000, 'unit': 'Vỉ'},
    {'id': 'MED-004', 'name': 'Cefuroxim 500mg', 'price': 120000, 'unit': 'Hộp'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> med) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['id'] == med['id']);
      if (existingIndex >= 0) {
        _cart[existingIndex]['qty'] += 1;
      } else {
        _cart.add({
          'id': med['id'],
          'name': med['name'],
          'price': med['price'],
          'unit': med['unit'],
          'qty': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${med['name']} vào giỏ hàng')),
    );
  }

  int get _totalAmount {
    return _cart.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
  }

  void _toggleSelectInteractionMed(String name) {
    setState(() {
      if (_selectedInteractionMeds.contains(name)) {
        _selectedInteractionMeds.remove(name);
      } else {
        _selectedInteractionMeds.add(name);
      }
      // Reset previous results
      _interactionResult = null;
    });
  }

  Future<void> _checkAIInteractions() async {
    if (_selectedInteractionMeds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất 2 loại thuốc để kiểm tra tương tác.')),
      );
      return;
    }

    setState(() {
      _checkingInteractions = true;
      _interactionResult = null;
    });

    // Simulate AI Service request lag
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _checkingInteractions = false;
      
      // Determine simulated results based on selections
      final hasAmoxicillin = _selectedInteractionMeds.contains('Amoxicillin 500mg');
      final hasCefuroxim = _selectedInteractionMeds.contains('Cefuroxim 500mg');
      final hasPanadol = _selectedInteractionMeds.contains('Panadol Extra');

      if (hasAmoxicillin && hasCefuroxim) {
        _interactionResult = {
          'risk': 'HIGH',
          'title': 'Cảnh báo nguy hiểm cấp độ Cao',
          'description': 'Dùng chung hai loại kháng sinh Amoxicillin và Cefuroxim có thể làm giảm hoạt lực diệt khuẩn của nhau và tăng nguy cơ tác dụng phụ trên hệ tiêu hóa, suy gan thận.',
        };
      } else if (hasAmoxicillin && hasPanadol) {
        _interactionResult = {
          'risk': 'LOW',
          'title': 'Tương tác nhẹ (An toàn)',
          'description': 'Không có tương tác đáng kể được ghi nhận giữa Amoxicillin và Paracetamol (Panadol). Việc phối hợp hai thuốc này trong điều trị sốt nhiễm khuẩn là an toàn dưới sự chỉ định của bác sĩ.',
        };
      } else {
        _interactionResult = {
          'risk': 'MEDIUM',
          'title': 'Cảnh báo mức độ Trung bình',
          'description': 'Chú ý theo dõi liều lượng dùng chung để tránh quá liều chất tá dược hoạt tính.',
        };
      }
    });
  }

  Future<void> _simulatePrescriptionScan() async {
    setState(() {
      _scanningPrescription = true;
    });

    await Future.delayed(const Duration(milliseconds: 2500));

    setState(() {
      _scanningPrescription = false;
      // Populate cart with scanned items
      _cart.clear();
      _cart.add({'id': 'MED-001', 'name': 'Amoxicillin 500mg', 'price': 85000, 'unit': 'Hộp', 'qty': 2});
      _cart.add({'id': 'MED-002', 'name': 'Panadol Extra', 'price': 45000, 'unit': 'Hộp', 'qty': 1});
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quét đơn thuốc AI thành công! Đã tự động điền danh sách thuốc vào giỏ.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Dược Sĩ Bán Hàng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_basket), text: 'Bán Hàng (POS)'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Tương Tác Thuốc'),
            Tab(icon: Icon(Icons.document_scanner), text: 'Quét Đơn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: POS Screen
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách dược phẩm',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) {
                            final med = _medicines[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${(med['price'] as int).toString()} ₫ / ${med['unit']}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _addToCart(med),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A73E8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Thêm'),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Cart area
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Giỏ hàng hiện tại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _cart.clear();
                              });
                            },
                            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                          )
                        ],
                      ),
                      Expanded(
                        child: _cart.isEmpty
                            ? const Center(child: Text('Giỏ hàng trống', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _cart.length,
                                itemBuilder: (context, index) {
                                  final item = _cart[index];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item['name']}  x${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${((item['price'] as int) * (item['qty'] as int)).toString()} ₫'),
                                    ],
                                  );
                                },
                              ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TỔNG CỘNG:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          Text('${_totalAmount.toString()} ₫', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3E50))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _cart.isEmpty
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thanh toán và xuất hóa đơn thành công!')),
                                );
                                setState(() {
                                  _cart.clear();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Xác nhận & Xuất Hóa Đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),

          // TAB 2: AI Interactions Check
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Chọn các thuốc cần kiểm tra tương tác thuốc chéo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Selector chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _medicines.map((med) {
                    final name = med['name']! as String;
                    final isSelected = _selectedInteractionMeds.contains(name);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(name),
                      onSelected: (val) => _toggleSelectInteractionMed(name),
                      selectedColor: const Color(0xFF1A73E8).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFF1A73E8),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _selectedInteractionMeds.length < 2 ? null : _checkAIInteractions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _checkingInteractions
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_checkingInteractions ? 'Đang phân tích y khoa AI...' : 'Phân tích tương tác thuốc chéo'),
                ),

                const SizedBox(height: 24),
                
                // Result display
                if (_interactionResult != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _interactionResult!['risk'] == 'HIGH'
                          ? Colors.red.shade50
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _interactionResult!['risk'] == 'HIGH'
                            ? Colors.red.shade200
                            : Colors.amber.shade200,
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _interactionResult!['risk'] == 'HIGH' ? Icons.dangerous : Icons.warning,
                              color: _interactionResult!['risk'] == 'HIGH' ? Colors.red : Colors.amber.shade800,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _interactionResult!['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _interactionResult!['risk'] == 'HIGH' ? Colors.red.shade900 : Colors.amber.shade900,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          _interactionResult!['description']!,
                          style: const TextStyle(height: 1.4, fontSize: 13),
                        )
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),

          // TAB 3: Scanning Prescription Simulator
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1A73E8), width: 3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_scanningPrescription)
                        const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
                      else
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 64, color: Colors.white54),
                            SizedBox(height: 8),
                            Text('GIẢ LẬP CAMERA QUÉT ĐƠN THUỐC', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      // Scanning target overlay lines
                      Positioned(
                        top: 20, left: 20,
                        child: Container(width: 30, height: 30, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1A73E8), width: 4), left: BorderSide(color: Color(0xFF1A73E8), width: 4)))),
                      ),
                      Positioned(
                        top: 20, right: 20,
                        child: Container(width: 30, height: 30, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1A73E8), width: 4), right: BorderSide(color: Color(0xFF1A73E8), width: 4)))),
                      ),
                      Positioned(
                        bottom: 20, left: 20,
                        child: Container(width: 30, height: 30, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1A73E8), width: 4), left: BorderSide(color: Color(0xFF1A73E8), width: 4)))),
                      ),
                      Positioned(
                        bottom: 20, right: 20,
                        child: Container(width: 30, height: 30, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1A73E8), width: 4), right: BorderSide(color: Color(0xFF1A73E8), width: 4)))),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đặt đơn thuốc giấy trước camera để AI phân tích nét chữ, tự động tìm kiếm thuốc và chèn thông tin y khoa vào giỏ hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _scanningPrescription ? null : _simulatePrescriptionScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Bắt đầu quét đơn thuốc bằng AI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
