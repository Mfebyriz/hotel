import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationManagementScreen> createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends State<ReservationManagementScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);

    try {
      final reservations = await ReservationService.getReservations(
        status: _filterStatus == 'all' ? null : _filterStatus,
      );
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _checkIn(Reservation reservation) async {
    try {
      await ReservationService.checkIn(reservation.id);
      _loadReservations();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in berhasil')));
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

  Future<void> _checkOut(Reservation reservation) async {
    try {
      await ReservationService.checkOut(reservation.id);
      _loadReservations();
      if (mounted) {
        // Show payment info if there's late fee
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Check-out Berhasil'),
            content: const Text(
              'Tamu telah check-out. Silahkan proses pembayaran.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(Reservation reservation) async {
    if (reservation.payment == null) return;

    final method = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Metode Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tunai'),
              onTap: () => Navigator.pop(context, 'cash'),
            ),
            ListTile(
              title: const Text('Transfer'),
              onTap: () => Navigator.pop(context, 'transfer'),
            ),
            ListTile(
              title: const Text('Kartu'),
              onTap: () => Navigator.pop(context, 'card'),
            ),
          ],
        ),
      ),
    );

    if (method != null) {
      try {
        await ApiService.post(
          '${AppConstants.PAYMENTS}/${reservation.payment!.id}/process',
          body: {'payment_method': method},
        );

        _loadReservations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil diproses')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
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
      appBar: AppBar(title: const Text('Kelola Reservasi')),
      body: Column(
        children: [
          // Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Dikonfirmasi', 'confirmed'),
                _buildFilterChip('Check-in', 'checked_in'),
                _buildFilterChip('Check-out', 'checked_out'),
              ],
            ),
          ),

          // Reservation List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReservations,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reservations.isEmpty
                  ? const Center(child: Text('Tidak ada reservasi'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = _reservations[index];
                        return _buildReservationCard(reservation);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (isSelected) {
          setState(() => _filterStatus = value);
          _loadReservations();
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final room = reservation.room;
    final user = reservation.user;
    final payment = reservation.payment;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${room?.roomType ?? 'Room'} - ${room?.roomNumber ?? '-'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reservation.getStatusText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Details
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DateFormat('dd MMM yyyy').format(DateTime.parse(reservation.checkInDate))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(reservation.checkOutDate))}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${reservation.totalNights} malam'),
                Text(
                  'Rp ${reservation.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            // Payment Info
            if (payment != null && payment.lateFee > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Denda: Rp ${payment.lateFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Actions
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reservation.isConfirmed())
                  ElevatedButton.icon(
                    onPressed: () => _checkIn(reservation),
                    icon: const Icon(Icons.login, size: 16),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (reservation.isCheckedIn())
                  ElevatedButton.icon(
                    onPressed: () => _checkOut(reservation),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Check-out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                if (payment != null && !payment.isPaid())
                  ElevatedButton.icon(
                    onPressed: () => _processPayment(reservation),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Proses Pembayaran'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                if (payment != null && payment.isPaid())
                  Chip(
                    avatar: const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Lunas',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'check_in':
        return Colors.green;
      case 'check_out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
