import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';
import '../../models/room.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import 'room_detail_screen.dart';
import 'reservation_history_screen.dart';
import 'notification_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  User? _user;
  List<Room> _rooms = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.getSavedUser();
      final rooms = await RoomService.getRooms();

      setState(() {
        _user = user;
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.Logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _searchRooms(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final rooms = await RoomService.getRooms(
        search: query.isEmpty ? null : query,
      );
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Reservation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // User Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _user?.name ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kamar...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchRooms('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchRooms,
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReservationHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('Riwayat'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Room List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                      ? const Center(child: Text('Tidak ada kamar tersedia'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return _buildRoomCard(room);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomDetailScreen(room: room),
            ),
          ).then((_) => _loadData());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: room.imageUrl != null
                  ? Image.network(
                      room.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.hotel,
                        size: 64,
                      ),
                    )
                  : const Icon(Icons.hotel, size: 64),
            ),

            // Room Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.roomType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: room.isAvailable()
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          room.getStatusText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamar ${room.roomNumber}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description ?? 'Kamar nyaman dengan fasilitas lengkap',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${room.price.toStringAsFixed(0)}/malam',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          Text('${room.capacity} orang'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}