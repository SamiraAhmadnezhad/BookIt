import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  static const Color _primaryColor = Color(0xFF542545);

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat("#,###", "fa_IR");

    return Card(
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoomDetails(context),
                  _buildPriceSection(context, priceFormat),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: (room.imageUrl != null && room.imageUrl!.isNotEmpty)
          ? Image.network(
        room.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : const Center(child: CircularProgressIndicator(color: _primaryColor)),
      )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 50),
    );
  }

  Widget _buildRoomDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.name,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.tag_outlined, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              "شماره ${room.roomNumber}",
              style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[800], fontSize: 13),
            ),
            const SizedBox(width: 16),
            Icon(Icons.bed_outlined, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              room.roomType,
              style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[800], fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, NumberFormat priceFormat) {
    return Column(
      children: [
        const Divider(height: 24, color: Color(0xFFF0F0F0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${priceFormat.format(room.pricePerNight)} تومان',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                color: _primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const Text(
              'برای هر شب',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}