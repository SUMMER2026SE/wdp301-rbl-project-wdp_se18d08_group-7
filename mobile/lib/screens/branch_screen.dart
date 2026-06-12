import 'package:flutter/material.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  final List<Map<String, dynamic>> _staffs = [
    {'name': 'Dược sĩ Nguyễn Thị Lan', 'status': 'ON_DUTY', 'sales': '4,500,000 ₫', 'time': 'Ca sáng (06:00 - 14:00)'},
    {'name': 'Dược sĩ Phạm Minh Tuấn', 'status': 'ON_DUTY', 'sales': '3,800,000 ₫', 'time': 'Ca sáng (06:00 - 14:00)'},
    {'name': 'Dược sĩ Đỗ Hoàng Nam', 'status': 'OFF', 'sales': '0 ₫', 'time': 'Ca chiều (14:00 - 22:00)'},
  ];

  final List<Map<String, dynamic>> _lowStockAlerts = [
    {'name': 'Amoxicillin 500mg', 'stock': 12, 'unit': 'Hộp', 'supplier': 'Dược phẩm Minh Dân'},
    {'name': 'Panadol Extra', 'stock': 5, 'unit': 'Hộp', 'supplier': 'Tập đoàn OPC'},
    {'name': 'Decolgen Forte', 'stock': 0, 'unit': 'Vỉ', 'supplier': 'Dược Hậu Giang'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Quản Lý Cơ Sở', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branch Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHI NHÁNH QUẬN 10', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Doanh Thu Hôm Nay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('8,300,000 ₫', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        const Text('16 giao dịch', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Staff roster / duty lists
              const Text(
                'Nhân Sự Đang Trong Ca',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _staffs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final staff = _staffs[index];
                    final isOnDuty = staff['status'] == 'ON_DUTY';
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        staff['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${staff['time']} \nDoanh số bán: ${staff['sales']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnDuty ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOnDuty ? 'Đang trực' : 'Vắng mặt',
                          style: TextStyle(
                            color: isOnDuty ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Local low stock warnings
              const Text(
                'Cảnh Báo Thiếu Thuốc Tại Cơ Sở',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lowStockAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _lowStockAlerts[index];
                  final isOut = alert['stock'] == 0;

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
                                alert['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOut ? Colors.red.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isOut ? 'Hết hàng' : 'Cận kho',
                                  style: TextStyle(
                                    color: isOut ? Colors.red : Colors.amber.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Tồn kho hiện tại: ${alert['stock']} ${alert['unit']}'),
                          Text('Nhà cung cấp: ${alert['supplier']}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã gửi yêu cầu cấp hàng thuốc ${alert['name']}')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.send, size: 16),
                                label: const Text('Gửi yêu cầu cấp hàng'),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
