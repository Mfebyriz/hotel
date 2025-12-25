
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/reservation.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_button.dart';
import '../../widgets/admin/dashboard_card.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailScreen({
    Key? key,
    required this.reservationId,
  }) : super(key: key);

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  Reservation? _reservation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      final reservation = await provider.fetchReservationById(widget.reservationId);

      if (mounted) {
        setState(() {
          _reservation = reservation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelReservation() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Batalkan Reservasi',
      message: 'Apakah Anda yakin ingin membatalkan reservasi ini?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
    );

    if (!confirm) return;

    final provider = Provider.of<ReservationProvider>(context, listen: false);
    final success = await provider.cancelReservation(_reservation!.id);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Reservasi berhasil dibatalkan');
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        'Gagal membatalkan reservasi',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (_error != null || _reservation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Reservasi')),
        body: custom.ErrorWidget(
          message: _error ?? 'Reservasi tidak ditemukan',
          onRetry: _loadReservation,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Reservasi'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            if (_reservation!.room?.imageUrl != null)
              CachedNetworkImage(
                imageUrl: _reservation!.room!.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.hotel, size: 60),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Code & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Booking',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                          Text(
                            _reservation!.bookingCode,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.getStatusColor(_reservation!.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _reservation!.statusText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.getStatusColor(_reservation!.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Room Info
                  const Text(
                    'Informasi Kamar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    label: 'Kamar',
                    value: 'Kamar ${_reservation!.room?.roomNumber ?? '-'}',
                    icon: Icons.hotel,
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    label: 'Kategori',
                    value: _reservation!.room?.category?.name ?? '-',
                    icon: Icons.category,
                  ),

                  const SizedBox(height: 24),

                  // Check-in/out Info
                  const Text(
                    'Tanggal Menginap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          label: 'Check-in',
                          value: Helpers.formatDate(_reservation!.checkInDate),
                          icon: Icons.login,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoCard(
                          label: 'Check-out',
                          value: Helpers.formatDate(_reservation!.checkOutDate),
                          icon: Icons.logout,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Guest & Night Info
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          label: 'Jumlah Tamu',
                          value: '${_reservation!.numGuests} Orang',
                          icon: Icons.people,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoCard(
                          label: 'Durasi',
                          value: '${_reservation!.totalNights} Malam',
                          icon: Icons.nightlight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price Details
                  const Text(
                    'Rincian Biaya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            const Text('Harga per malam'),
                            Text(
                              Helpers.formatCurrency(_reservation!.pricePerNight),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_reservation!.totalNights} malam'),
                            Text(
                              Helpers.formatCurrency(
                                _reservation!.pricePerNight * _reservation!.totalNights,
                              ),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Helpers.formatCurrency(_reservation!.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Special Requests
                  if (_reservation!.specialRequests != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Permintaan Khusus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Text(
                        _reservation!.specialRequests!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Cancel Button
                  if (_reservation!.canCancel)
                    CustomButton(
                      text: 'Batalkan Reservasi',
                      onPressed: _cancelReservation,
                      backgroundColor: AppConstants.errorColor,
                      icon: Icons.cancel,
                      width: double.infinity,
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}