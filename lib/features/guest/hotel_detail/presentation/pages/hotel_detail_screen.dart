import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/core/models/review_model.dart';
import 'package:bookit/core/models/room_model.dart';
import 'package:bookit/core/utils/responsive_layout.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/guest/hotel_detail/data/services/hotel_detail_api_service.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/widgets/add_review_form.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/widgets/amenity_chip.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/widgets/review_card.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/widgets/room_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../core/utils/custom_shamsi_date_picker.dart';
import '../../../../../pages/guest_pages/reservation_detail_page/reservation_detail_page.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late final HotelDetailApiService _apiService;
  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = HotelDetailApiService(authService);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _roomsFuture = _apiService.fetchHotelRooms(widget.hotel.id.toString());
      _reviewsFuture =
          _apiService.fetchHotelReviews(widget.hotel.id.toString());
    });
  }

  Future<void> _showBookingDateRangePicker(BuildContext context, Room room) async {
    Jalali? startDate;
    Jalali? endDate;
    final Jalali today = Jalali.now();

    startDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: today,
      firstDate: today,
      lastDate: today.addDays(365),
      titleText: "تاریخ ورود را انتخاب کنید",
    );

    if (startDate == null || !mounted) return;

    final Jalali firstDateForEndDate = startDate.addDays(1);
    endDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: firstDateForEndDate,
      firstDate: firstDateForEndDate,
      lastDate: firstDateForEndDate.addDays(90),
      titleText: "تاریخ خروج را انتخاب کنید",
    );

    if (endDate == null || !mounted) return;

    final checkInDateTime = startDate.toDateTime();
    final checkOutDateTime = endDate.toDateTime();
    final numberOfNights = checkOutDateTime.difference(checkInDateTime).inDays;
    final totalPrice =
        room.pricePerNight * (numberOfNights > 0 ? numberOfNights : 1);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailPage(
          hotelName: widget.hotel.name,
          roomInfo: room.name,
          checkInDate: checkInDateTime,
          checkOutDate: checkOutDateTime,
          totalPrice: totalPrice,
          hotelId: widget.hotel.id.toString(),
          hotelAddress: widget.hotel.address,
          hotelRating: widget.hotel.rating,
          hotelImageUrl: widget.hotel.imageUrl,
          roomNumber: room.roomNumber,
          numberOfAdults: room.capacity, roomID: room.id,
        ),
      ),
    );
  }

  Future<void> _handleReviewSubmission({
    required double rating,
    required List<String> goodThings,
    required List<String> badThings,
  }) async {
    try {
      final success = await _apiService.submitReview(
        hotelId: widget.hotel.id.toString(),
        rating: rating,
        goodThings: goodThings,
        badThings: badThings,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('نظر شما با موفقیت ثبت شد.'),
              backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطا در ثبت نظر: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: _buildMobileLayout(),
        desktopBody: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildDesktopHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                  child: _buildMainContent(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('اتاق‌های موجود',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                Expanded(child: _buildRoomsList(isScrollable: true)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ResponsiveLayout.isDesktop(context))
          _buildHeader()
        else
          const SizedBox.shrink(),
        const SizedBox(height: 24),
        _buildSection('درباره هتل', Text(widget.hotel.description)),
        const SizedBox(height: 24),
        _buildSection('امکانات', _buildAmenities()),
        const SizedBox(height: 24),
        if (!ResponsiveLayout.isDesktop(context)) _buildRoomsSection(),
        const SizedBox(height: 24),
        _buildSection('نظرات کاربران', _buildReviewsList()),
        const SizedBox(height: 24),
        _buildSection('نظر خود را ثبت کنید',
            AddReviewForm(onSubmit: _handleReviewSubmission)),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.hotel.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Theme.of(context).colorScheme.surface),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      stretch: true,
      pinned: true,
      expandedHeight: 250,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.hotel.name,
            style: const TextStyle(
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
        centerTitle: true,
        background: _buildDesktopHeader(),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.hotel.name, style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 4),
            Expanded(
                child:
                Text(widget.hotel.address, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.hotel.amenities
          .map((facility) => AmenityChip(facility: facility))
          .toList(),
    );
  }

  Widget _buildRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اتاق‌ها', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _buildRoomsList(),
      ],
    );
  }

  Widget _buildRoomsList({bool isScrollable = false}) {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطا: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('اتاقی برای رزرو موجود نیست.'));
        }
        final rooms = snapshot.data!;

        if (isScrollable) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RoomCard(
                  room: rooms[index],
                  onBookNow: () =>
                      _showBookingDateRangePicker(context, rooms[index])),
            ),
          );
        }

        return SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rooms.length,
            itemBuilder: (context, index) => SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: RoomCard(
                    room: rooms[index],
                    onBookNow: () =>
                        _showBookingDateRangePicker(context, rooms[index])),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطا: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('نظری برای این هتل ثبت نشده است.'));
        }
        final reviews = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) => SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ReviewCard(review: reviews[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}