import 'package:flutter/material.dart';
import '../../models/room_category.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class CategoryRoomsScreen extends StatefulWidget {
  final RoomCategory category;

  const CategoryRoomsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryRoomsScreen> createState() => _CategoryRoomsScreenState();
}

class _CategoryRoomsScreenState extends State<CategoryRoomsScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);

    try {
      final rooms = await RoomService.getRooms(categoryId: widget.category.id);
      setState(() {
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

  Future<void> _addRoom() async {
    final roomNumberController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Nomor Kamar'),
        content: TextField(
          controller: roomNumberController,
          decoration: const InputDecoration(
            labelText: 'Nomor Kamar',
            hintText: 'Contoh: 101, 102, 103',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (roomNumberController.text.trim().isNotEmpty) {
                Navigator.pop(context, roomNumberController.text.trim());
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await RoomService.createRoom(
          roomCategoryId: widget.category.id,
          roomNumber: result,
        );

        _loadRooms();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamar berhasil ditambahkan')),
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

  Future<void> _updateRoomStatus(Room room) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status Kamar ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tersedia'),
              leading: Radio<String>(
                value: 'available',
                groupValue: room.status,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'available'),
            ),
            ListTile(
              title: const Text('Terisi'),
              leading: Radio<String>(
                value: 'occupied',
                groupValue: room.status,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'occupied'),
            ),
            ListTile(
              title: const Text('Maintenance'),
              leading: Radio<String>(
                value: 'maintenance',
                groupValue: room.status,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'maintenance'),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null && newStatus != room.status) {
      try {
        await RoomService.updateRoom(room.id, {'status': newStatus});
        _loadRooms();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status kamar berhasil diupdate')),
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

  Future<void> _deleteRoom(Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kamar'),
        content: Text('Apakah Anda yakin ingin menghapus kamar ${room.roomNumber}?'),
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
        await RoomService.deleteRoom(room.id);
        _loadRooms();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamar berhasil dihapus')),
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
      appBar: AppBar(
        title: Text('Kamar ${widget.category.name}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRoom,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
      ),
      body: Column(
        children: [
          // Category Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.category.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.category.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.hotel, size: 40),
                          ),
                        )
                      : const Icon(Icons.hotel, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${widget.category.price.toStringAsFixed(0)}/malam',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Kapasitas: ${widget.category.capacity} orang'),
                      Text('Total Kamar: ${_rooms.length}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Room List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRooms,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada kamar.\nKlik tombol "Tambah Kamar" untuk menambahkan.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return _buildRoomCard(room);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    Color statusColor;
    switch (room.status) {
      case 'available':
        statusColor = Colors.green;
        break;
      case 'occupied':
        statusColor = Colors.red;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _updateRoomStatus(room),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                room.roomNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  room.getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteRoom(room),
              ),
            ],
          ),
        ),
      ),
    );
  }
}