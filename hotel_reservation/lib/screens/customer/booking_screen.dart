import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/room.dart';
import '../../services/reservation_service.dart';
import 'customer_home_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room;

  const BookingScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalPrice {
    return _totalNights * widget.room.price;
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // Reset check-out jika sebelum check-in
        if (_checkOutDate != null && _checkInDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in terlebih dahulu')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  Future<void> _createBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in dan check-out')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ReservationService.createReservation(
        roomId: widget.room.id,
        checkInDate: DateFormat('yyyy-MM-dd').format(_checkInDate!),
        checkOutData: DateFormat('yyyy-MM-dd').format(_checkOutDate!),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Booking Berhasil'),
          content: const Text('Reservasi Anda telah dikonfirmasi.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Kamar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.room.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.room.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.hotel),
                              ),
                            )
                          : const Icon(Icons.hotel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.roomType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Kamar ${widget.room.roomNumber}'),
                          Text(
                            'Rp ${widget.room.price.toStringAsFixed(0)}/malam',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Check-in Date
            const Text(
              'Tanggal Check-in',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckInDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _checkInDate == null
                          ? 'Pilih tanggal check-in'
                          : DateFormat('dd MMMM yyyy').format(_checkInDate!),
                      style: TextStyle(
                        color: _checkInDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Check-out Date
            const Text(
              'Tanggal Check-out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckOutDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _checkOutDate == null
                          ? 'Pilih tanggal check-out'
                          : DateFormat('dd MMMM yyyy').format(_checkOutDate!),
                      style: TextStyle(
                        color: _checkOutDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan catatan untuk reservasi Anda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary
            if (_checkInDate != null && _checkOutDate != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildSummaryRow('Total Malam', '$_totalNights malam'),
                      _buildSummaryRow(
                        'Harga per Malam',
                        'Rp ${widget.room.price.toStringAsFixed(0)}',
                      ),
                      const Divider(),
                      _buildSummaryRow(
                        'Total Harga',
                        'Rp ${_totalPrice.toStringAsFixed(0)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Konfirmasi Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
