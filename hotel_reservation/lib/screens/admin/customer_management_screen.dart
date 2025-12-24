import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/constants.dart';
import '../../services/api_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get(AppConstants.CUSTOMERS);

      if (response['success']) {
        setState(() {
          _customers = response['data']['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteCustomer(dynamic customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Customer'),
        content: Text('Apakah Anda yakin ingin menghapus ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('${AppConstants.CUSTOMERS}/${customer['id']}');
        _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Customer'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: _isLoading
            ? const Center(child: Text('Belum ada customer'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return _buildCustomerCard(customer);
                },
            ),
      ),
    );
  }

  Widget _buildCustomerCard(dynamic customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            customer['name'][0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer['email']),
            if (customer['phone'] != null)
              Text(customer['phone']),
            Text(
              '${customer['reservations_count'] ?? 0} reservasi',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCustomer(customer),
        ),
      ),
    );
  }
}