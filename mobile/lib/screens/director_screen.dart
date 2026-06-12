import 'package:flutter/material.dart';

class DirectorScreen extends StatefulWidget {
  const DirectorScreen({super.key});

  @override
  State<DirectorScreen> createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final List<Map<String, dynamic>> _poPendingApprovals = [
    {
      'id': 'PO-88231',
      'branch': 'Cơ sở Quận 1',
      'supplier': 'Dược phẩm Minh Dân',
      'amount': '84,500,000 ₫',
      'date': '12/06/2026',
      'items': 'Thuốc kháng sinh Amoxicillin (x500), Paracetamol 500mg (x1000)',
    },
    {
      'id': 'PO-88232',
      'branch': 'Cơ sở Quận 3',
      'supplier': 'Tập đoàn OPC',
      'amount': '120,000,000 ₫',
      'date': '12/06/2026',
      'items': 'Hoạt huyết dưỡng não (x2000), Dầu khuynh diệp (x1500)',
    },
    {
      'id': 'PO-88233',
      'branch': 'Cơ sở Quận 10',
      'supplier': 'Dược Hậu Giang (DHG)',
      'amount': '45,000,000 ₫',
      'date': '11/06/2026',
      'items': 'Hapacol 250 (x1000), Klamentin 625 (x800)',
    },
  ];

  final List<Map<String, dynamic>> _branchPerformances = [
    {'name': 'Cơ sở Quận 1', 'revenue': '420,000,000 ₫', 'transactions': '1,450', 'growth': '+12.4%'},
    {'name': 'Cơ sở Quận 3', 'revenue': '310,000,000 ₫', 'transactions': '980', 'growth': '+4.2%'},
    {'name': 'Cơ sở Quận 10', 'revenue': '285,000,000 ₫', 'transactions': '850', 'growth': '-2.1%'},
    {'name': 'Cơ sở Quận 7', 'revenue': '190,000,000 ₫', 'transactions': '520', 'growth': '+8.6%'},
  ];

  void _approvePO(int index, String poId) {
    setState(() {
      _poPendingApprovals.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã PHÊ DUYỆT đơn nhập hàng $poId')),
    );
  }

  void _rejectPO(int index, String poId) {
    setState(() {
      _poPendingApprovals.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã TỪ CHỐI đơn nhập hàng $poId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Báo cáo Giám Đốc', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              // Chart Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Doanh Thu Toàn Hệ Thống (Tháng 6)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B365D)),
                          ),
                          Text(
                            '1.205 tỷ ₫',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.green),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Custom Revenue chart painter
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: RevenueChartPainter(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegend('Q.1', Colors.blue),
                          _buildLegend('Q.3', Colors.green),
                          _buildLegend('Q.10', Colors.orange),
                          _buildLegend('Q.7', Colors.purple),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // PO Pending approval list
              Text(
                'Duyệt Đơn Nhập Hàng (${_poPendingApprovals.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B365D)),
              ),
              const SizedBox(height: 12),
              _poPendingApprovals.isEmpty
                  ? Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Không có đơn PO nào đang chờ duyệt.',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _poPendingApprovals.length,
                      itemBuilder: (context, index) {
                        final po = _poPendingApprovals[index];
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
                                      'Mã đơn: ${po['id']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B365D)),
                                    ),
                                    Text(
                                      po['amount']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Chi nhánh: ${po['branch']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('Nhà cung cấp: ${po['supplier']}'),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    po['items']!,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => _rejectPO(index, po['id']!),
                                      child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _approvePO(index, po['id']!),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1B365D),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Phê duyệt'),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),

              // Pharmacy branches list
              const Text(
                'Hiệu Suất Từng Chi Nhánh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
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
                  itemCount: _branchPerformances.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final branch = _branchPerformances[index];
                    final isUp = branch['growth']!.startsWith('+');
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        branch['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Giao dịch: ${branch['transactions']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            branch['revenue']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B365D)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: isUp ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                branch['growth']!,
                                style: TextStyle(
                                  color: isUp ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Custom Painter to draw a clean and beautiful bar/line chart representing revenue
class RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.01)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // Simulating points for days in month
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw dot at latest point
    final paintDot = Paint()..color = Colors.green..strokeWidth = 8;
    canvas.drawCircle(points.last, 6, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
