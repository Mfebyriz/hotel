import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/room.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius),
              ),
              child: room.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: room.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.hotel, size: 50),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.hotel, size: 50),
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Number & Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kamar ${room.roomNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: room.isAvailable
                              ? AppConstants.successColor.withOpacity(0.1)
                              : AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          room.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: room.isAvailable
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Category Name
                  if (room.category != null)
                    Text(
                      room.category!.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Details
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${room.category?.maxGuests ?? 0} Tamu',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      if (room.sizeSqm != null) ...[
                        Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${room.sizeSqm} m²',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  if (room.category != null)
                    Text(
                      Helpers.formatCurrency(room.category!.basePrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  const SizedBox(height: 2),
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
          ],
        ),
      ),
    );
  }
}