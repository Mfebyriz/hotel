import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/admin/stats_card.dart';
import '../../widgets/admin/dashboard_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';

  // Mock data - in real app, fetch from API
  final Map<String, dynamic> _reportData = {
    'total_revenue': 125000000,
    'total_reservations': 38,
    'total_checkins': 35,
    'total_checkouts': 32,
    'occupancy_rate': 72.5,
    'avg_room_price': 850000,
    'most_popular_category': 'Deluxe',
    'top_customers': [
      {'name': 'Bob Wilson', 'total': 8, 'revenue': 12500000},
      {'name': 'John Doe', 'total': 5, 'revenue': 8750000},
      {'name': 'Jane Smith', 'total': 3, 'revenue': 4500000},
    ],
    'revenue_by_category': [
      {'category': 'Suite', 'revenue': 45000000},
      {'category': 'Deluxe', 'revenue': 38000000},
      {'category': 'Standard', 'revenue': 28000000},
      {'category': 'Family', 'revenue': 14000000},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Periode Laporan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPeriodChip('today', 'Hari Ini'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPeriodChip('week', 'Minggu Ini'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPeriodChip('month', 'Bulan Ini'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Revenue Summary
              const Text(
                'Ringkasan Pendapatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              StatsCard(
                title: 'Total Pendapatan',
                value: Helpers.formatCurrency(_reportData['total_revenue']),
                icon: Icons.payments,
                color: AppConstants.successColor,
                trend: '+15.5%',
                isPositive: true,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Rata-rata Harga',
                      value: Helpers.formatCurrency(
                        _reportData['avg_room_price'].toDouble(),
                      ),
                      icon: Icons.attach_money,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      title: 'Okupansi',
                      value: '${_reportData['occupancy_rate']}%',
                      icon: Icons.show_chart,
                      color: AppConstants.accentColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Reservation Stats
              const Text(
                'Statistik Reservasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Reservasi',
                      value: '${_reportData['total_reservations']}',
                      icon: Icons.book,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Check-in',
                      value: '${_reportData['total_checkins']}',
                      icon: Icons.login,
                      color: AppConstants.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              StatsCard(
                title: 'Check-out',
                value: '${_reportData['total_checkouts']}',
                subtitle: 'Total transaksi selesai',
                icon: Icons.logout,
                color: AppConstants.warningColor,
              ),

              const SizedBox(height: 24),

              // Revenue by Category
              const Text(
                'Pendapatan per Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    children: _reportData['revenue_by_category']
                        .map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['category'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Helpers.formatCurrency(
                                      item['revenue'].toDouble(),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: item['revenue'] /
                                          _reportData['total_revenue'],
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppConstants.primaryColor,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Top Customers
              const Text(
                'Top Customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: _reportData['top_customers']
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    final index = entry.key;
                    final customer = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index == 0
                            ? Colors.amber
                            : index == 1
                                ? Colors.grey
                                : Colors.brown,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customer['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${customer['total']} reservasi'),
                      trailing: Text(
                        Helpers.formatCurrency(customer['revenue'].toDouble()),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = value;
          });
          Helpers.showSnackBar(context, 'Periode: $label');
        }
      },
      selectedColor: AppConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.textPrimaryColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}