import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  bool _isLoading = false;
  String _searchQuery = '';

  // Mock data - in real app, fetch from API
  final List<Map<String, dynamic>> _customers = [
    {
      'id': 2,
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '081234567891',
      'total_reservations': 5,
      'is_active': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;

    return _customers.where((customer) {
      final name = customer['name'].toString().toLowerCase();
      final email = customer['email'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Data Customer'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
                hintText: 'Cari customer...',
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

          // Customer List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _filteredCustomers.isEmpty
                    ? const custom.EmptyWidget(
                        message: 'Tidak ada customer',
                        icon: Icons.people_outline,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // TODO: Refresh data
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: AppConstants.paddingMedium,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(
                                  AppConstants.paddingMedium,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppConstants.primaryColor,
                                  child: Text(
                                    Helpers.getInitials(customer['name']),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  customer['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          size: 14,
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(customer['email']),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(customer['phone']),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.book,
                                          size: 14,
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${customer['total_reservations']} Reservasi',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: customer['is_active']
                                        ? AppConstants.successColor.withOpacity(0.1)
                                        : AppConstants.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    customer['is_active'] ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customer['is_active']
                                          ? AppConstants.successColor
                                          : AppConstants.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}