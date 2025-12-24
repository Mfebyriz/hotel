import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _revenueData;
  Map<String, dynamic>? _occupancyData;
  List<dynamic>? _reservationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final revenue = await ApiService.get('${AppConstants.REPORTS}/revenue');
      final occupancy = await ApiService.get('${AppConstants.REPORTS}/occupancy');
      final reservations = await ApiService.get('${AppConstants.REPORTS}/reservations');

      setState(() {
        _revenueData = revenue['data'];
        _occupancyData = occupancy['data'];
        _reservationData = reservations['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Revenue Card
                    if (_revenueData != null)
                      _buildRevenueCard(),
                    const SizedBox(height: 16),

                    // Occupancy Card
                    if (_occupancyData != null)
                      _buildOccupancyCard(),
                    const SizedBox(height: 16),

                    // Reservation Stats
                    if (_reservationData != null)
                      _buildReservationStats(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    final revenue = _revenueData!['total_revenue'] ?? 0;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green.shade700, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Total Pendapatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Rp ${revenue.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bulan ini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard() {
    final totalRooms = _occupancyData!['total_rooms'] ?? 0;
    final occupiedRooms = _occupancyData!['occupied_rooms'] ?? 0;
    final availableRooms = _occupancyData!['available_rooms'] ?? 0;
    final occupancyRate = _occupancyData!['occupancy_rate'] ?? 0;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hotel, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Tingkat Hunian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$occupancyRate%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOccupancyItem('Total Kamar', totalRooms.toString(), Colors.grey),
                _buildOccupancyItem('Terisi', occupiedRooms.toString(), Colors.red),
                _buildOccupancyItem('Tersedia', availableRooms.toString(), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReservationStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Reservasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ..._reservationData!.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStatusText(item['status']),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item['count']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'checked_in':
        return 'Check-in';
      case 'checked_out':
        return 'Check-out';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'checked_in':
        return Colors.green;
      case 'checked_out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}