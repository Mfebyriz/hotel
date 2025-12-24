import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);

    try {
      final reservations = await ReservationService.getReservations();
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

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Reservasi'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan reservasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ReservationService.cancelReservation(reservation.id);
        _loadReservations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservasi berhasil dibatalkan')),
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
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Reservasi')),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reservations.isEmpty
            ? const Center(child: Text('Belum ada reservasi'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  return _buildReservationCard(reservation);
                },
              ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final room = reservation.room;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room?.roomType ?? 'Room',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
            const SizedBox(height: 8),
            Text('Kamar ${room?.roomNumber ?? '-'}'),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM yyyy').format(DateTime.parse(reservation.checkInDate))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(reservation.checkOutDate))}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.nights_stay, size: 16),
                const SizedBox(width: 8),
                Text('${reservation.totalNights} malam'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${reservation.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            if (reservation.isConfirmed() || reservation.isPending())
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () => _cancelReservation(reservation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Batalkan Reservasi'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'padding':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'check-in':
        return Colors.green;
      case 'check-out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
