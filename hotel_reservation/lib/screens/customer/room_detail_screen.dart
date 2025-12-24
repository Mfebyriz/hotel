import 'package:flutter/material.dart';
import '../../models/room.dart';
import 'booking_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Kamar ${room.roomNumber}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: room.imageUrl != null
                  ? Image.network(
                      room.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.hotel, size: 100),
                    )
                  : const Icon(Icons.hotel, size: 100),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Type & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.roomType,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: room.isAvailable() ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room.getStatusText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamar ${room.roomNumber}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga per malam',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Rp ${room.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Facilities
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFacilityItem(
                    Icons.people,
                    'Kapasitas ${room.capacity} orang',
                  ),
                  _buildFacilityItem(Icons.wifi, 'WIFI Gratis'),
                  _buildFacilityItem(Icons.ac_unit, 'AC'),
                  _buildFacilityItem(Icons.tv, 'TV'),
                  _buildFacilityItem(Icons.bathtub, 'Kamar Mandi Pribadi'),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    room.description ??
                        'Kamar nyaman dengan fasilitas yang lengkap untuk kenyamanan Anda.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: room.isAvailable()
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(room: room),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              room.isAvailable() ? 'Booking Sekarang' : 'Kamar Tidak Tersedia',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
