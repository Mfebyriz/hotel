import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/room.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'my_reservations_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room;

  const BookingScreen({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestsController = TextEditingController();
  final _requestsController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _totalNights = 0;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _guestsController.text = '1';
  }

  @override
  void dispose() {
    _guestsController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_checkInDate != null && _checkOutDate != null) {
      setState(() {
        _totalNights = _checkOutDate!.difference(_checkInDate!).inDays;
        _totalPrice = (widget.room.category?.basePrice ?? 0) * _totalNights;
      });
    }
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _checkInDate = date;
        if (_checkOutDate != null && _checkOutDate!.isBefore(date)) {
          _checkOutDate = null;
        }
      });
      _calculateTotal();
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      Helpers.showSnackBar(
        context,
        'Pilih tanggal check-in terlebih dahulu',
        isError: true,
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: _checkInDate!.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _checkOutDate = date;
      });
      _calculateTotal();
    }
  }

  Future<void> _bookRoom() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkInDate == null || _checkOutDate == null) {
      Helpers.showSnackBar(
        context,
        'Pilih tanggal check-in dan check-out',
        isError: true,
      );
      return;
    }

    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Konfirmasi Reservasi',
      message: 'Apakah Anda yakin ingin membuat reservasi ini?',
      confirmText: 'Ya, Pesan',
      cancelText: 'Batal',
    );

    if (!confirm) return;

    final reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );

    final reservation = await reservationProvider.createReservation(
      roomId: widget.room.id,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      totalGuests: int.parse(_guestsController.text),
      specialRequests: _requestsController.text.isEmpty
          ? null
          : _requestsController.text,
    );

    if (!mounted) return;

    if (reservation != null) {
      Helpers.showSnackBar(context, 'Reservasi berhasil dibuat!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
        (route) => route.isFirst,
      );
    } else {
      Helpers.showSnackBar(
        context,
        reservationProvider.error ?? 'Gagal membuat reservasi',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Reservasi'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            // Room Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamar ${widget.room.roomNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.room.category?.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Helpers.formatCurrency(widget.room.category?.basePrice ?? 0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const Text(
                      'per malam',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckInDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      _checkInDate != null
                          ? Helpers.formatDate(_checkInDate!)
                          : 'Pilih tanggal check-in',
                      style: TextStyle(
                        fontSize: 16,
                        color: _checkInDate != null
                            ? AppConstants.textPrimaryColor
                            : AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Check-out Date
            const Text(
              'Tanggal Check-out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckOutDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      _checkOutDate != null
                          ? Helpers.formatDate(_checkOutDate!)
                          : 'Pilih tanggal check-out',
                      style: TextStyle(
                        fontSize: 16,
                        color: _checkOutDate != null
                            ? AppConstants.textPrimaryColor
                            : AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Number of Guests
            CustomTextField(
              label: 'Jumlah Tamu',
              hint: 'Masukkan jumlah tamu',
              controller: _guestsController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.people,
              validator: (value) => Validators.validateNumber(
                value,
                min: 1,
                max: widget.room.category?.maxGuests ?? 10,
              ),
            ),

            const SizedBox(height: 16),

            // Special Requests
            CustomTextField(
              label: 'Permintaan Khusus (Opsional)',
              hint: 'Contoh: Lantai atas, view bagus, dll.',
              controller: _requestsController,
              maxLines: 3,
              prefixIcon: Icons.note,
            ),

            const SizedBox(height: 24),

            // Price Summary
            if (_totalNights > 0) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durasi'),
                        Text(
                          '$_totalNights malam',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga per malam'),
                        Text(
                          Helpers.formatCurrency(widget.room.category?.basePrice ?? 0),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(_totalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Book Button
            Consumer<ReservationProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Konfirmasi Reservasi',
                  onPressed: _bookRoom,
                  isLoading: provider.isLoading,
                  icon: Icons.check_circle,
                  width: double.infinity,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}