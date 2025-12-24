import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class RoomFormScreen extends StatefulWidget {
  final Room? room;

  const RoomFormScreen({Key? key, this.room}) : super(key: key);

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _RoomNumberController = TextEditingController();
  final _roomTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _capacityContoller = TextEditingController();
  String _status = 'available';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _RoomNumberController.text = widget.room!.roomNumber;
      _roomTypeController.text = widget.room!.roomType;
      _priceController.text = widget.room!.price.toString();
      _descriptionController.text = widget.room!.description ?? '';
      _imageUrlController.text = widget.room!.imageUrl ?? '';
      _capacityContoller.text = widget.room!.capacity.toString();
      _status = widget.room!.status;
    }
  }

  @override
  void dispose() {
    _RoomNumberController.dispose();
    _roomTypeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _capacityContoller.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final roomData = {
        'room_number': _RoomNumberController.text.trim(),
        'room_type': _roomTypeController.text.trim(),
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text.trim(),
        'iamge_url': _imageUrlController.text.trim(),
        'capacity': int.parse(_capacityContoller.text),
        'status': _status,
      };

      if (widget.room == null) {
        await RoomService.createRoom(roomData);
      } else {
        await RoomService.updateRoom(widget.room!.id, roomData);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.room == null
                ? 'Kamar berhasil ditambahkan'
                : 'Kamar berhasil diupdate',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
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
      appBar: AppBar(
        title: Text(widget.room == null ? 'Tambah kamar' : 'Edit Kamar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _RoomNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kamar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor kammar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _roomTypeController,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kamar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipe kamar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per Malam',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _capacityContoller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas (orang)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kapasitas tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Kapasitas harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'occupied', child: Text('Terisi')),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.room == null ? 'Tambah Kamar' : 'Update Kamar',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
