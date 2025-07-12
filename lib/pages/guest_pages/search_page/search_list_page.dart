import 'package:bookit/pages/guest_pages/search_page/search_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/room_model.dart';
import '../../../features/auth/data/services/auth_service.dart';
import '../reservation_detail_page/reservation_detail_page.dart';
import 'model/search_params_model.dart';
import 'widgets/hotel_search_list_card.dart';

import '../reservation_detail_page//reservation_api_service.dart';

enum SortType { none, popular, cheapest, expensive, discount }

class SearchListPage extends StatefulWidget {
  final SearchParams searchParams;

  const SearchListPage({super.key, required this.searchParams});

  @override
  State<SearchListPage> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  late final SearchApiService _apiService;
  final ReservationApiService _reservationApiService = ReservationApiService();
  late final String? _token; // برای دسترسی به توکن کاربر

  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  SortType _currentSortType = SortType.none;
  late RangeValues _currentPriceRange;
  double _maxPrice = 10000000.0;
  bool _isInitialPriceRangeDefault = true;

  static const Color pageBackgroundColor = Color(0xFFEEEEEE);
  static const Color appBarTextColor = Colors.black87;
  static const Color appBarActionsColor = Color(0xFF542545);
  static const Color searchFieldBgColor = Colors.white;
  static const Color searchIconColor = Color(0xFF757575);
  static const String vazirmatnFontFamily = 'Vazirmatn';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = SearchApiService(authService);
    _token = authService.token;

    _searchController.addListener(_applyFiltersAndSort);
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _apiService.searchAvailableRooms(widget.searchParams);
      if (mounted) {
        setState(() {
          _allRooms = rooms;
          _filteredRooms = rooms;
          _calculateAndSetInitialPriceRange();
          _applyFiltersAndSort();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'خطا در دریافت نتایج: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRoomBooking(Room room) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برای رزرو، ابتدا باید وارد شوید.")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: appBarActionsColor),
              SizedBox(width: 20),
              Text("در حال قفل کردن اتاق..."),
            ],
          ),
        ),
      ),
    );

    final bool isLocked = await _reservationApiService.lockRoom(
      roomID: [room.id],
      token: _token!,
    );

    if (mounted) Navigator.pop(context);

    if (isLocked) {
      try {
        final DateTime checkIn = DateTime.parse(widget.searchParams.checkInDate);
        final DateTime checkOut = DateTime.parse(widget.searchParams.checkOutDate);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationDetailPage(
              hotelId: room.hotel.id,
              hotelName: room.hotel.name,
              hotelAddress: room.hotel.location,
              hotelRating: room.rating,
              hotelImageUrl: room.imageUrl ?? '',
              roomID: room.id,
              roomNumber: room.roomNumber,
              roomInfo: room.name,
              checkInDate: checkIn,
              checkOutDate: checkOut,
              totalPrice: room.pricePerNight,
              numberOfAdults: widget.searchParams.numberOfPassengers,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("خطا: فرمت تاریخ ارسال شده نامعتبر است."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("خطا: این اتاق در حال حاضر توسط شخص دیگری رزرو شده یا در دسترس نیست."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  void _calculateAndSetInitialPriceRange() {
    if (_allRooms.isEmpty) {
      _maxPrice = 10000000.0;
    } else {
      _maxPrice = _allRooms.map((r) => r.pricePerNight).reduce((a, b) => a > b ? a : b);
      if (_maxPrice == 0) _maxPrice = 10000000.0;
    }
    _currentPriceRange = RangeValues(0, _maxPrice);
    _isInitialPriceRangeDefault = true;
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndSort);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltersAndSort() {
    String query = _searchController.text.toLowerCase();
    List<Room> tempFilteredRooms = List.from(_allRooms);

    if (query.isNotEmpty) {
      tempFilteredRooms = tempFilteredRooms.where((room) {
        return room.name.toLowerCase().contains(query) ||
            room.hotel.name.toLowerCase().contains(query);
      }).toList();
    }

    if (!_isInitialPriceRangeDefault) {
      tempFilteredRooms = tempFilteredRooms.where((room) {
        return room.pricePerNight >= _currentPriceRange.start &&
            room.pricePerNight <= _currentPriceRange.end;
      }).toList();
    }

    switch (_currentSortType) {
      case SortType.popular:
        tempFilteredRooms.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortType.cheapest:
        tempFilteredRooms.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case SortType.expensive:
        tempFilteredRooms.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
        break;
      case SortType.discount:
        tempFilteredRooms.sort((a, b) => b.discount.compareTo(a.discount));
        break;
      case SortType.none:
        break;
    }

    setState(() => _filteredRooms = tempFilteredRooms);
  }

  String _getSortTypeDisplayName(SortType sortType) {
    switch (sortType) {
      case SortType.popular: return "محبوب‌ترین";
      case SortType.cheapest: return "ارزان‌ترین";
      case SortType.expensive: return "گران‌ترین";
      case SortType.discount: return "پرتخفیف";
      default: return "";
    }
  }

  String _buildActiveFiltersString() {
    List<String> activeFilters = [];
    String sortDisplayName = _getSortTypeDisplayName(_currentSortType);
    if (sortDisplayName.isNotEmpty) activeFilters.add(sortDisplayName);
    if (!_isInitialPriceRangeDefault) {
      final priceFormat = NumberFormat.compact(locale: "fa");
      activeFilters.add("قیمت: ${priceFormat.format(_currentPriceRange.start)} - ${priceFormat.format(_currentPriceRange.end)}");
    }
    if (activeFilters.isEmpty) return "نتایج برای: ${widget.searchParams.city}";
    return activeFilters.join(" | ");
  }

  void _showFilterModal(BuildContext context) {
    SortType tempSortType = _currentSortType;
    RangeValues tempPriceRange = _currentPriceRange;
    bool tempIsPriceRangeDefault = _isInitialPriceRangeDefault;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 12.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 8.0), decoration: BoxDecoration(color: appBarActionsColor.withOpacity(0.7), borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 16),
                    // ... (بخش گزینه‌های مرتب‌سازی)
                    CheckboxListTile(title: const Text("محبوب ترین"), value: tempSortType == SortType.popular, onChanged: (val) => setModalState(() => tempSortType = val! ? SortType.popular : SortType.none), activeColor: appBarActionsColor, controlAffinity: ListTileControlAffinity.trailing),
                    CheckboxListTile(title: const Text("ارزان ترین"), value: tempSortType == SortType.cheapest, onChanged: (val) => setModalState(() => tempSortType = val! ? SortType.cheapest : SortType.none), activeColor: appBarActionsColor, controlAffinity: ListTileControlAffinity.trailing),
                    CheckboxListTile(title: const Text("گرانترین"), value: tempSortType == SortType.expensive, onChanged: (val) => setModalState(() => tempSortType = val! ? SortType.expensive : SortType.none), activeColor: appBarActionsColor, controlAffinity: ListTileControlAffinity.trailing),
                    CheckboxListTile(title: const Text("پر تخفیف"), value: tempSortType == SortType.discount, onChanged: (val) => setModalState(() => tempSortType = val! ? SortType.discount : SortType.none), activeColor: appBarActionsColor, controlAffinity: ListTileControlAffinity.trailing),
                    const Divider(indent: 24, endIndent: 24),
                    // ... (بخش اسلایدر قیمت)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16), child: Align(alignment: Alignment.centerRight, child: Text("رنج قیمت", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                    RangeSlider(
                      values: tempPriceRange, min: 0, max: _maxPrice,
                      divisions: (_maxPrice > 0) ? (_maxPrice / 100000).round().clamp(1, 200) : 1,
                      activeColor: appBarActionsColor, inactiveColor: appBarActionsColor.withOpacity(0.3),
                      onChanged: (values) {
                        setModalState(() {
                          tempPriceRange = values;
                          tempIsPriceRangeDefault = (values.start == 0 && values.end == _maxPrice);
                        });
                      },
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${NumberFormat.decimalPattern('fa').format(tempPriceRange.start.round())} تومان"), Text("${NumberFormat.decimalPattern('fa').format(tempPriceRange.end.round())} تومان")])),
                    // ... (دکمه اعمال)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: appBarActionsColor, minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          setState(() {
                            _currentSortType = tempSortType;
                            _currentPriceRange = tempPriceRange;
                            _isInitialPriceRangeDefault = tempIsPriceRangeDefault;
                          });
                          Navigator.pop(modalContext);
                          _applyFiltersAndSort();
                        },
                        child: const Text("اعمال فیلترها", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: appBarActionsColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _buildActiveFiltersString(),
          style: const TextStyle(color: appBarTextColor, fontWeight: FontWeight.w500, fontFamily: vazirmatnFontFamily, fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: appBarActionsColor),
            onPressed: () => _showFilterModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: appBarActionsColor))
          : _errorMessage != null
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_errorMessage!)))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: "جستجوی نام هتل یا اتاق...",
                  prefixIcon: const Icon(Icons.search, color: searchIconColor),
                  filled: true,
                  fillColor: searchFieldBgColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16)
              ),
            ),
          ),
          Expanded(
            child: _filteredRooms.isEmpty
                ? const Center(child: Text("اتاقی با این مشخصات یافت نشد."))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
              itemCount: _filteredRooms.length,
              itemBuilder: (context, index) {
                final room = _filteredRooms[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: HotelSearchListCard(
                    imageUrl: room.imageUrl ?? '',
                    name: "${room.hotel.name} - ${room.name}",
                    location: room.hotel.location,
                    rating: room.rating,
                    isFavorite: room.isFavorite,
                    price: room.pricePerNight.toInt(),
                    onTap: () {
                      // می‌توانید اینجا کاربر را به صفحه جزئیات هتل ببرید
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailsPage(hotelId: room.hotel.id.toString())));
                    },
                    onFavoriteToggle: () {
                      // منطق toggle favorite را اینجا پیاده‌سازی کنید
                      // setState(() => room.isFavorite = !room.isFavorite);
                    },
                    // +++ 4. اتصال دکمه رزرو به متد جدید +++
                    onReserveTap: () => _handleRoomBooking(room),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}