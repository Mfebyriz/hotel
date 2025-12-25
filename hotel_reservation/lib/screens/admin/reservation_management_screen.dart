import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationManagementScreen> createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends State<ReservationManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';

  // Mock data - in real app, fetch from API
  final List<Map<String, dynamic>> _reservations = [
    {
      'id': 1,
      'booking_code': 'BK20250101001',
      'customer_name': 'John Doe',
      'room_number': '301',
      'category': 'Deluxe',
      'check_in': '2025-01-15',
      'check_out': '2025-01-18',
      'total_price': 2550000,
      'status': 'confirmed',
    },
    {
      'id': 2,
      'booking_code': 'BK20250101002',
      'customer_name': 'Jane Smith',
      'room_number': '501',
      'category': 'Suite',
      'check_in': '2025-01-10',
      'check_out': '2025-01-15',
      'total_price': 7500000,
      'status': 'checked_in',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredReservations(String status) {
    var filtered = _reservations;

    if (status != 'all') {
      filtered = filtered.where((r) => r['status'] == status).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final code = r['booking_code'].toString().toLowerCase();
        final customer = r['customer_name'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return code.contains(query) || customer.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Reservasi'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Check-in'),
            Tab(text: 'Check-out'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari kode booking atau nama customer...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationList('all'),
                _buildReservationList('confirmed'),
                _buildReservationList('checked_in'),
                _buildReservationList('checked_out'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationList(String status) {
    final reservations = _getFilteredReservations(status);

    if (_isLoading) {
      return const LoadingWidget();
    }

    if (reservations.isEmpty) {
      return custom.EmptyWidget(
        message: 'Tidak ada reservasi',
        icon: Icons.book_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor:
                    AppConstants.getStatusColor(reservation['status']),
                child: const Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                reservation['booking_code'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(reservation['customer_name']),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.getStatusColor(reservation['status'])
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppConstants.getStatusLabel(reservation['status']),
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            AppConstants.getStatusColor(reservation['status']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Kamar',
                        'Kamar ${reservation['room_number']} (${reservation['category']})',
                        Icons.hotel,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Check-in',
                        reservation['check_in'],
                        Icons.login,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Check-out',
                        reservation['check_out'],
                        Icons.logout,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Total Biaya',
                        Helpers.formatCurrency(
                          reservation['total_price'].toDouble(),
                        ),
                        Icons.payment,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (reservation['status'] == 'confirmed')
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Check-in
                                  Helpers.showSnackBar(
                                    context,
                                    'Fitur check-in coming soon!',
                                  );
                                },
                                icon: const Icon(Icons.login, size: 18),
                                label: const Text('Check-in'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.successColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          if (reservation['status'] == 'checked_in') ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Check-out
                                  Helpers.showSnackBar(
                                    context,
                                    'Fitur check-out coming soon!',
                                  );
                                },
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Check-out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.warningColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (reservation['status'] == 'confirmed') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Cancel
                                  Helpers.showSnackBar(
                                    context,
                                    'Fitur batalkan coming soon!',
                                  );
                                },
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('Batalkan'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppConstants.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}