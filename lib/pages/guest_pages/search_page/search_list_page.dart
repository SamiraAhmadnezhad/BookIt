
import 'package:flutter/material.dart';

import '../home_page/widgets/hotel_list_card.dart';

// Enum for sorting options
enum SortType { none, popular, cheapest, expensive, discount }

class SearchListPage extends StatefulWidget {
  final String? initialSearchQuery; // پارامتر برای دریافت عبارت جستجوی اولیه

  const SearchListPage({super.key, this.initialSearchQuery});

  @override
  State<SearchListPage> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  late List<Map<String, dynamic>> hotelDataList;
  late List<Map<String, dynamic>> _allHotels;
  late List<Map<String, dynamic>> _filteredHotels;
  final TextEditingController _searchController = TextEditingController();

  // Filter and Sort State
  SortType _currentSortType = SortType.none;
  late RangeValues _currentPriceRange;
  double _maxPrice = 100000000.0;

  // Colors
  static const Color pageBackgroundColor = Color(0xFFEEEEEE);
  static const Color appBarTextColor = Colors.black; // برای عنوان اپ‌بار
  static const Color appBarActionsColor = Color(0xFF542545); // رنگ آیکون فیلتر و برگشت
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
    _calculateAndSetInitialPriceRange();
    _filteredHotels = List.from(_allHotels);
    _searchController.addListener(_onSearchOrFilterChanged);
    _applyFiltersAndSort(); // اعمال فیلتر اولیه (بر اساس initialSearchQuery و رنج قیمت پیش‌فرض)
  }

  void _calculateAndSetInitialPriceRange() {
    if (_allHotels.isEmpty) {
      _maxPrice = 100000000.0;
    } else {
      _maxPrice = _allHotels
          .map((h) => h['price'] as num)
          .reduce((a, b) => a > b ? a : b)
          .toDouble();
      if (_maxPrice == 0) _maxPrice = 100000000.0;
    }
    double minVal = 0;
    if (_maxPrice < minVal) {
      minVal = _maxPrice;
    }
    _currentPriceRange = RangeValues(minVal, _maxPrice);
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

    // 1. Text Search (even if not actively typed on this page, initial query applies)
    if (query.isNotEmpty) {
      tempFilteredHotels = tempFilteredHotels.where((hotel) {
        final name = hotel["name"].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    // 2. Price Range Filter
    tempFilteredHotels = tempFilteredHotels.where((hotel) {
      final price = hotel["price"] as num;
      return price >= _currentPriceRange.start &&
          price <= _currentPriceRange.end;
    }).toList();

    // 3. Sorting
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

  void _showFilterModal(BuildContext context) {
    SortType tempSortType = _currentSortType;
    RangeValues tempPriceRange = _currentPriceRange;

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
                  activeColor: appBarActionsColor, // رنگ بنفش
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
                          max: _maxPrice,
                          divisions: (_maxPrice > 0)
                              ? (_maxPrice / 100000).round().clamp(1, 200)
                              : 1,
                          activeColor: appBarActionsColor,
                          inactiveColor: appBarActionsColor.withOpacity(0.3),
                          onChanged: (RangeValues values) {
                            setModalState(() {
                              tempPriceRange = values;
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
                            });
                            Navigator.pop(modalContext);
                            _applyFiltersAndSort();
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
        elevation: 0,
        surfaceTintColor: pageBackgroundColor,
        // دکمه برگشت
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: appBarActionsColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          tooltip: 'برگشت',
        ),
        // عنوان اپ‌بار
        title: Text(
          widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty
              ? 'نتایج برای: "${widget.initialSearchQuery}"'
              : "لیست هتل‌ها",
          style: const TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: vazirmatnFontFamily,
            fontSize: 17, // کمی کوچکتر برای جا شدن بهتر
          ),
          overflow: TextOverflow.ellipsis, // برای جلوگیری از سرریز شدن متن طولانی
        ),
        centerTitle: true, // برای وسط‌چین کردن عنوان
        // دکمه فیلتر در سمت راست
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: appBarActionsColor),
            iconSize: 26.0,
            onPressed: () {
              _showFilterModal(context);
            },
            tooltip: 'فیلتر',
          ),
          const SizedBox(width: 8), // فاصله کوچک از لبه
        ],
      ),
      body: Column( // استفاده از Column برای قرار دادن ListView.builder
        children: [
          Expanded( // ListView.builder باید در Expanded قرار گیرد تا ارتفاع نامحدود نگیرد
            child: _filteredHotels.isEmpty
                ? Center(
                child: Text(
                  "موردی با این مشخصات یافت نشد.",
                  style: TextStyle(
                      fontFamily: vazirmatnFontFamily,
                      fontSize: 16,
                      color: Colors.grey[700]),
                  textDirection: TextDirection.rtl,
                ))
                : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Tapped on ${hotel["name"]}",
                                textDirection: TextDirection.rtl)),
                      );
                    },
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
                    onReserveTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Reserve tapped for ${hotel["name"]}",
                                textDirection: TextDirection.rtl)),
                      );
                    },
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