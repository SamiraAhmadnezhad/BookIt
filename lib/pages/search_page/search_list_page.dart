import 'package:bookit/pages/home_page/widgets/hotel_list_card.dart'; // مسیر ویجت کارت هتل
import 'package:flutter/material.dart';

// Enum for sorting options
enum SortType { none, popular, cheapest, expensive, discount }

class SearchListPage extends StatefulWidget {
  final String? initialSearchQuery;

  const SearchListPage({super.key, this.initialSearchQuery});

  @override
  State<SearchListPage> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  late List<Map<String, dynamic>> hotelDataList;
  late List<Map<String, dynamic>> _allHotels;
  late List<Map<String, dynamic>> _filteredHotels;
  final TextEditingController _searchController = TextEditingController();

  SortType _currentSortType = SortType.none;
  late RangeValues _currentPriceRange;
  double _maxPrice = 100000000.0; // Default max price, updated in initState
  bool _isInitialPriceRangeDefault = true; // برای بررسی اینکه آیا رنج قیمت تغییر کرده یا نه

  static const Color pageBackgroundColor = Color(0xFFEEEEEE);
  static const Color appBarTextColor = Colors.black87;
  static const Color appBarActionsColor = Color(0xFF542545);
  static const Color searchFieldBgColor = Colors.white;
  static const Color searchIconColor = Color(0xFF757575);
  static const Color searchHintColor = Color(0xFFBDBDBD);
  static const String vazirmatnFontFamily = 'Vazirmatn';


  @override
  void initState() {
    super.initState();

    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
    }

    hotelDataList = [
      // ... (همان لیست هتل‌های شما)
      {
        "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=500&q=60",
        "name": "اسم هتل در حالت طولانی اسم هتل خیلی طولانی",
        "location": "تهران",
        "rating": 4.0,
        "isFavorite": true,
        "price": 3200000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=500&q=60",
        "name": "هتل پنج ستاره لوکس و مدرن",
        "location": "شیراز",
        "rating": 4.8,
        "isFavorite": false,
        "price": 7500000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=500&q=60",
        "name": "اقامتگاه سنتی دلنشین باصفا",
        "location": "اصفهان",
        "rating": 4.2,
        "isFavorite": true,
        "price": 4100000,
      },
      {
        "imageUrl": "bad_url_to_test_error.jpg",
        "name": "هتل با تصویر خراب شده",
        "location": "یزد",
        "rating": 3.1,
        "isFavorite": false,
        "price": 1800000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=500&q=60",
        "name": "هتل ساحلی آرامش بخش",
        "location": "کیش",
        "rating": 4.5,
        "isFavorite": false,
        "price": 6200000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=500&q=60",
        "name": "هتل جنگلی با ویو بی‌نظیر",
        "location": "مازندران",
        "rating": 4.9,
        "isFavorite": true,
        "price": 8800000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=500&q=60",
        "name": "هتل ارزان و تمیز مرکز شهر",
        "location": "مشهد",
        "rating": 3.5,
        "isFavorite": false,
        "price": 1500000,
      },
    ];

    _allHotels = List.from(hotelDataList);
    _calculateAndSetInitialPriceRange(); // این _maxPrice و _currentPriceRange اولیه را تنظیم می‌کند
    _filteredHotels = List.from(_allHotels);
    _searchController.addListener(_onSearchOrFilterChanged);
    _applyFiltersAndSort();
  }

  void _calculateAndSetInitialPriceRange() {
    if (_allHotels.isEmpty) {
      _maxPrice = 100000000.0;
    } else {
      _maxPrice = _allHotels
          .map((h) => h['price'] as num)
          .reduce((a, b) => a > b ? a : b)
          .toDouble();
      if (_maxPrice == 0) _maxPrice = 100000000.0; // اطمینان از اینکه مکس پرایس صفر نباشد
    }
    _currentPriceRange = RangeValues(0, _maxPrice);
    _isInitialPriceRangeDefault = true; // در ابتدا رنج قیمت پیش‌فرض است
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchOrFilterChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchOrFilterChanged() {
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    String query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> tempFilteredHotels = List.from(_allHotels);

    if (query.isNotEmpty) {
      tempFilteredHotels = tempFilteredHotels.where((hotel) {
        final name = hotel["name"].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    // بررسی می‌کنیم که آیا رنج قیمت از حالت پیش‌فرض تغییر کرده یا نه
    if (!_isInitialPriceRangeDefault) {
      tempFilteredHotels = tempFilteredHotels.where((hotel) {
        final price = hotel["price"] as num;
        return price >= _currentPriceRange.start &&
            price <= _currentPriceRange.end;
      }).toList();
    }


    switch (_currentSortType) {
      case SortType.popular:
        tempFilteredHotels.sort(
                (a, b) => (b["rating"] as num).compareTo(a["rating"] as num));
        break;
      case SortType.cheapest:
        tempFilteredHotels
            .sort((a, b) => (a["price"] as num).compareTo(b["price"] as num));
        break;
      case SortType.expensive:
        tempFilteredHotels
            .sort((a, b) => (b["price"] as num).compareTo(a["price"] as num));
        break;
      case SortType.discount:
        tempFilteredHotels.sort((a, b) {
          int ratingCompare =
          (b["rating"] as num).compareTo(a["rating"] as num);
          if (ratingCompare != 0) return ratingCompare;
          return (a["price"] as num).compareTo(b["price"] as num);
        });
        break;
      case SortType.none:
        tempFilteredHotels.sort(
                (a, b) => (a["name"] as String).compareTo(b["name"] as String));
        break;
    }

    setState(() {
      _filteredHotels = tempFilteredHotels;
    });
  }

  String _getSortTypeDisplayName(SortType sortType) {
    switch (sortType) {
      case SortType.popular:
        return "محبوب‌ترین";
      case SortType.cheapest:
        return "ارزان‌ترین";
      case SortType.expensive:
        return "گران‌ترین";
      case SortType.discount:
        return "پرتخفیف";
      case SortType.none:
        return ""; // یا "بدون مرتب‌سازی"
    }
  }

  String _buildActiveFiltersString() {
    List<String> activeFilters = [];

    String sortDisplayName = _getSortTypeDisplayName(_currentSortType);
    if (sortDisplayName.isNotEmpty) {
      activeFilters.add(sortDisplayName);
    }

    // فقط اگر رنج قیمت از حالت پیش‌فرض (0 تا maxPrice اولیه) تغییر کرده باشد، نمایش داده شود
    if (!_isInitialPriceRangeDefault) {
      activeFilters.add(
          "قیمت: ${_currentPriceRange.start.round()} تا ${_currentPriceRange.end.round()}");
    }

    if (activeFilters.isEmpty) {
      return "نتایج جستجو"; // یا "فیلترها را اعمال کنید"
    }
    return activeFilters.join("، "); // فیلترها با ویرگول جدا می‌شوند
  }

  void _showFilterModal(BuildContext context) {
    SortType tempSortType = _currentSortType;
    RangeValues tempPriceRange = _currentPriceRange;
    bool tempIsPriceRangeDefault = _isInitialPriceRangeDefault;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Widget buildSortOptionCheckbox({
              required String title,
              required SortType optionType,
            }) {
              return Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.grey[400],
                ),
                child: CheckboxListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontFamily: vazirmatnFontFamily,
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                    textDirection: TextDirection.rtl,
                  ),
                  value: tempSortType == optionType,
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        tempSortType = optionType;
                      } else {
                        if (tempSortType == optionType) {
                          tempSortType = SortType.none;
                        }
                      }
                    });
                  },
                  activeColor: appBarActionsColor,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                  dense: true,
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 12.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: appBarActionsColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildSortOptionCheckbox(
                          title: "محبوب ترین", optionType: SortType.popular),
                      const _CustomDivider(),
                      buildSortOptionCheckbox(
                          title: "ارزان ترین", optionType: SortType.cheapest),
                      const _CustomDivider(),
                      buildSortOptionCheckbox(
                          title: "گرانترین", optionType: SortType.expensive),
                      const _CustomDivider(),
                      buildSortOptionCheckbox(
                          title: "پر تخفیف", optionType: SortType.discount),
                      const _CustomDivider(),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "رنج قیمت",
                            style: TextStyle(
                                fontFamily: vazirmatnFontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RangeSlider(
                          values: tempPriceRange,
                          min: 0,
                          max: _maxPrice, // استفاده از _maxPrice محاسبه شده
                          divisions: (_maxPrice > 0)
                              ? (_maxPrice / 100000).round().clamp(1, 200)
                              : 1,
                          activeColor: appBarActionsColor,
                          inactiveColor: appBarActionsColor.withOpacity(0.3),
                          onChanged: (RangeValues values) {
                            setModalState(() {
                              tempPriceRange = values;
                              // اگر کاربر اسلایدر را حرکت داد، یعنی دیگر رنج پیش‌فرض نیست
                              tempIsPriceRangeDefault = (values.start == 0 && values.end == _maxPrice);
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${tempPriceRange.start.round()} تومان",
                              style: const TextStyle(
                                  fontFamily: vazirmatnFontFamily,
                                  fontSize: 13,
                                  color: Colors.black54),
                            ),
                            Text(
                              "${tempPriceRange.end.round()} تومان",
                              style: const TextStyle(
                                  fontFamily: vazirmatnFontFamily,
                                  fontSize: 13,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const _CustomDivider(
                          indent: 24, endIndent: 24, topPadding: 16),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appBarActionsColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentSortType = tempSortType;
                              _currentPriceRange = tempPriceRange;
                              _isInitialPriceRangeDefault = tempIsPriceRangeDefault;
                            });
                            Navigator.pop(modalContext);
                            _applyFiltersAndSort(); // این باعث آپدیت AppBar هم می‌شود
                          },
                          child: const Text(
                            "اعمال",
                            style: TextStyle(
                                fontFamily: vazirmatnFontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
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
        elevation: 0.5, // یک سایه خیلی کم برای جداسازی
        surfaceTintColor: pageBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: appBarActionsColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          tooltip: 'برگشت',
        ),
        title: Text(
          _buildActiveFiltersString(), // نمایش فیلترهای فعال
          style: const TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.w500, // کمی سبک‌تر از bold
            fontFamily: vazirmatnFontFamily,
            fontSize: 14, // کوچکتر برای جا شدن بهتر
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: appBarActionsColor),
            iconSize: 26.0,
            onPressed: () {
              _showFilterModal(context);
            },
            tooltip: 'فیلتر',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // نوار جستجو در اینجا قرار می‌گیرد
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 0.0, bottom: 8.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: searchFieldBgColor,
                borderRadius: BorderRadius.circular(24.0), // Pill shape
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                    fontFamily: vazirmatnFontFamily, fontSize: 14, color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: "جستجو",
                  hintStyle: TextStyle(
                      color: searchHintColor, fontFamily: vazirmatnFontFamily, fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: Padding( // آیکون جستجو در سمت چپ (برای RTL، prefixIcon در چپ قرار میگیرد)
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: searchIconColor, size: 22),
                  ),
                  // برای اینکه متن از آیکون فاصله بگیرد و hint هم درست نمایش داده شود
                  contentPadding: EdgeInsets.only(right: 16.0, left: 0, top: 2.0, bottom: 2.0),
                ),
              ),
            ),
          ),
          // لیست نتایج
          Expanded(
            child: _filteredHotels.isEmpty
                ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "موردی با این مشخصات یافت نشد.",
                    style: TextStyle(
                        fontFamily: vazirmatnFontFamily,
                        fontSize: 16,
                        color: Colors.grey[700]),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ))
                : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 4.0, bottom: 16.0, left: 16.0, right: 16.0), // کمی پدینگ بالا کمتر
              itemCount: _filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = _filteredHotels[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: HotelListCard(
                    imageUrl: hotel["imageUrl"]!,
                    name: hotel["name"]!,
                    location: hotel["location"]!,
                    rating: hotel["rating"]!,
                    isFavorite: hotel["isFavorite"]!,
                    price: hotel["price"]!,
                    onTap: () { /* ... */ },
                    onFavoriteToggle: () {
                      setState(() {
                        final originalHotelIndex = _allHotels.indexWhere(
                                (h) => h["name"] == hotel["name"]);
                        if (originalHotelIndex != -1) {
                          _allHotels[originalHotelIndex]["isFavorite"] =
                          !_allHotels[originalHotelIndex]
                          ["isFavorite"]!;
                        }
                        hotel["isFavorite"] = !hotel["isFavorite"]!;
                      });
                    },
                    onReserveTap: () { /* ... */ },
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

class _CustomDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final double topPadding;

  const _CustomDivider(
      {this.indent = 24.0, this.endIndent = 24.0, this.topPadding = 4.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: Colors.grey[300],
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}