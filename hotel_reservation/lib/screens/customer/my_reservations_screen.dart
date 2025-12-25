import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/customer/reservation_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({Key? key}) : super(key: key);

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final provider = Provider.of<ReservationProvider>(context, listen: false);
    await provider.fetchMyReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Reservasi Saya'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Semua'),
          ],
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return custom.ErrorWidget(
              message: provider.error!,
              onRetry: _loadReservations,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReservations,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Reservations
                _buildReservationList(provider.activeReservations),

                // Completed Reservations
                _buildReservationList(provider.completedReservations),

                // All Reservations
                _buildReservationList(provider.reservations),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReservationList(List reservations) {
    if (reservations.isEmpty) {
      return const custom.EmptyWidget(
        message: 'Belum ada reservasi',
        icon: Icons.book_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
          child: ReservationCard(
            reservation: reservation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationDetailScreen(
                    reservationId: reservation.id,
                  ),
                ),
              ).then((_) => _loadReservations());
            },
          ),
        );
      },
    );
  }
}