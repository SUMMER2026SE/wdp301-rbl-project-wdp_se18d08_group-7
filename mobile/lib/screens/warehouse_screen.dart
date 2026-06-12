import 'package:flutter/material.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  // Track expanded medicine IDs for batch dropdowns
  final Set<String> _expandedMedIds = {};

  final List<Map<String, dynamic>> _medicines = [
    {
      'id': 'MED-001',
      'name': 'Amoxicillin 500mg',
      'category': 'Kháng sinh',
      'stock': 120,
      'minStock': 50,
      'price': '85,000 ₫',
      'unit': 'Hộp',
      'batches': [
        {'batchNo': 'Lô A1', 'expDate': '12/12/2026', 'stock': 80, 'status': 'ACTIVE'},
        {'batchNo': 'Lô A2', 'expDate': '10/05/2027', 'stock': 40, 'status': 'ACTIVE'},
      ]
    },
    {
      'id': 'MED-002',
      'name': 'Panadol Extra',
      'category': 'Giảm đau',
      'stock': 35,
      'minStock': 50,
      'price': '45,000 ₫',
      'unit': 'Hộp',
      'batches': [
        {'batchNo': 'Lô B1', 'expDate': '25/08/2026', 'stock': 35, 'status': 'ACTIVE'}
      ]
    },
    {
      'id': 'MED-003',
      'name': 'Decolgen Forte',
      'category': 'Cảm cúm',
      'stock': 0,
      'minStock': 50,
      'price': '38,000 ₫',
      'unit': 'Vỉ',
      'batches': []
    },
    {
      'id': 'MED-004',
      'name': 'Cefuroxim 500mg',
      'category': 'Kháng sinh',
      'stock': 200,
      'minStock': 50,
      'price': '120,000 ₫',
      'unit': 'Hộp',
      'batches': [
        {'batchNo': 'Lô C1', 'expDate': '10/07/2026', 'stock': 150, 'status': 'ACTIVE'},
        {'batchNo': 'Lô C2', 'expDate': '15/12/2026', 'stock': 50, 'status': 'ACTIVE'}
      ]
    }
  ];

  final List<Map<String, dynamic>> _expiredBatches = [
    {
      'medicineName': 'Panadol Extra',
      'batchNo': 'Lô B0 (Hết hạn)',
      'expDate': '01/05/2026',
      'stock': 20,
      'unit': 'Hộp',
      'status': 'EXPIRED',
    },
    {
      'medicineName': 'Amoxicillin 500mg',
      'batchNo': 'Lô A0 (Hết hạn)',
      'expDate': '20/04/2026',
      'stock': 15,
      'unit': 'Hộp',
      'status': 'EXPIRED',
    },
    {
      'medicineName': 'Cefuroxim 500mg',
      'batchNo': 'Lô C0 (Cận hạn)',
      'expDate': '30/06/2026',
      'stock': 50,
      'unit': 'Hộp',
      'status': 'SOON_TO_EXPIRE',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedMedIds.contains(id)) {
        _expandedMedIds.remove(id);
      } else {
        _expandedMedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _medicines.where((med) {
      final name = med['name']!.toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Thủ Kho Dược', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
            Tab(text: 'Tồn Kho'),
            Tab(text: 'Báo Cáo Hết Hạn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Inventory Management & Search
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats overview row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSimpleStatCard(
                          title: 'Mặt hàng',
                          value: '${_medicines.length}',
                          icon: Icons.medical_services,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSimpleStatCard(
                          title: 'Sắp hết hàng',
                          value: '${_medicines.where((m) => (m['stock'] as int) <= (m['minStock'] as int)).length}',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSimpleStatCard(
                          title: 'Cận/Hết hạn',
                          value: '${_expiredBatches.length}',
                          icon: Icons.calendar_today,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm kiếm thuốc theo tên...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medicine items with batch dropdowns
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final med = filteredMedicines[index];
                      final isExpanded = _expandedMedIds.contains(med['id']);
                      final isLow = (med['stock'] as int) <= (med['minStock'] as int);
                      final hasMultipleBatches = (med['batches'] as List).length > 1;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      med['name']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  if (isLow)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade100),
                                      ),
                                      child: const Text(
                                        'Sắp hết',
                                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Danh mục: ${med['category']}  •  Giá: ${med['price']}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tồn kho: ${med['stock']} ${med['unit']} / Tối thiểu: ${med['minStock']} ${med['unit']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isLow ? Colors.red : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: hasMultipleBatches
                                  ? IconButton(
                                      icon: Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _toggleExpand(med['id']!),
                                    )
                                  : null,
                            ),
                            
                            // Collapsible Batch Dropdown list
                            if (hasMultipleBatches && isExpanded)
                              Container(
                                color: Colors.blue.shade50.withValues(alpha: 0.4),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.inventory_2_outlined, size: 14, color: Colors.blue),
                                        SizedBox(width: 6),
                                        Text(
                                          'Hạn sử dụng chi tiết từng lô:',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 12),
                                    ...(med['batches'] as List).map((b) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${b['batchNo']}  (HSD: ${b['expDate']})',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${b['stock']} ${med['unit']}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // TAB 2: Expiration Reports View
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _expiredBatches.length,
              itemBuilder: (context, index) {
                final eb = _expiredBatches[index];
                final isExpired = eb['status'] == 'EXPIRED';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              eb['medicineName']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isExpired ? Colors.red.shade50 : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isExpired ? 'Hết Hạn' : 'Cận Hạn',
                                style: TextStyle(
                                  color: isExpired ? Colors.red : Colors.amber.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Mã Lô: ${eb['batchNo']}'),
                        const SizedBox(height: 4),
                        Text('Hạn sử dụng: ${eb['expDate']}'),
                        const SizedBox(height: 4),
                        Text('Tồn lô: ${eb['stock']} ${eb['unit']}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã lên kế hoạch tiêu hủy lô ${eb['batchNo']}')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isExpired ? Colors.red : const Color(0xFF1A73E8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.delete_sweep, size: 16),
                              label: Text(isExpired ? 'Tiêu hủy' : 'Xử lý cận hạn'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
