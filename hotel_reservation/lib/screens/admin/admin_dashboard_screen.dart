import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/admin/dashboard_card.dart';
import '../../widgets/admin/stats_card.dart';
import '../auth/login_screen.dart';
import 'customer_list_screen.dart';
import 'room_category_screen.dart';
import 'room_management_screen.dart';
import 'reservation_management_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Mock data - in real app, fetch from API
  final Map<String, dynamic> _dashboardData = {
    'total_customers': 45,
    'total_rooms': 22,
    'total_reservations': 38,
    'active_reservations': 12,
    'available_rooms': 10,
    'occupied_rooms': 8,
    'maintenance_rooms': 4,
    'today_checkin': 3,
    'today_checkout': 5,
    'monthly_revenue': 125000000,
  };

  Future<void> _logout() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
    );

    if (!confirm) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Helpers.getGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.currentUser?.name ?? 'Admin',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats
              const Text(
                'Statistik Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Check-in Hari Ini',
                      value: '${_dashboardData['today_checkin']}',
                      icon: Icons.login,
                      color: AppConstants.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Check-out Hari Ini',
                      value: '${_dashboardData['today_checkout']}',
                      icon: Icons.logout,
                      color: AppConstants.warningColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Overview Cards
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  DashboardCard(
                    title: 'Total Customer',
                    value: '${_dashboardData['total_customers']}',
                    icon: Icons.people,
                    color: AppConstants.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerListScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Total Kamar',
                    value: '${_dashboardData['total_rooms']}',
                    icon: Icons.hotel,
                    color: AppConstants.secondaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoomManagementScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Total Reservasi',
                    value: '${_dashboardData['total_reservations']}',
                    icon: Icons.book,
                    color: AppConstants.successColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReservationManagementScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Kamar Tersedia',
                    value: '${_dashboardData['available_rooms']}',
                    icon: Icons.check_circle,
                    color: AppConstants.accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoomManagementScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Room Status
              const Text(
                'Status Kamar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              StatsCard(
                title: 'Kamar Tersedia',
                value: '${_dashboardData['available_rooms']}',
                subtitle: 'Siap untuk reservasi',
                icon: Icons.check_circle,
                color: AppConstants.successColor,
              ),

              const SizedBox(height: 12),

              StatsCard(
                title: 'Kamar Terisi',
                value: '${_dashboardData['occupied_rooms']}',
                subtitle: 'Sedang digunakan',
                icon: Icons.hotel,
                color: AppConstants.primaryColor,
              ),

              const SizedBox(height: 12),

              StatsCard(
                title: 'Maintenance',
                value: '${_dashboardData['maintenance_rooms']}',
                subtitle: 'Dalam perbaikan',
                icon: Icons.build,
                color: AppConstants.warningColor,
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Menu Manajemen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.category,
                title: 'Kategori Kamar',
                subtitle: 'Kelola kategori kamar',
                color: AppConstants.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoomCategoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.hotel,
                title: 'Manajemen Kamar',
                subtitle: 'Kelola data kamar',
                color: AppConstants.secondaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoomManagementScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.book,
                title: 'Manajemen Reservasi',
                subtitle: 'Kelola reservasi customer',
                color: AppConstants.successColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReservationManagementScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.people,
                title: 'Data Customer',
                subtitle: 'Lihat daftar customer',
                color: AppConstants.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerListScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.bar_chart,
                title: 'Laporan',
                subtitle: 'Lihat laporan dan statistik',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}