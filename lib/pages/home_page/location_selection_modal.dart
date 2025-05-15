import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocationSelectionModal extends StatefulWidget {
  final List<String> allCities;
  final String currentCity;
  final Function(String) onCitySelected;

  const LocationSelectionModal({
    super.key,
    required this.allCities,
    required this.currentCity,
    required this.onCitySelected,
  });

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  late TextEditingController _searchController;
  late List<String> _filteredCities;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCities = widget.allCities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCities);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = widget.allCities.where((city) {
        return city.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets, // برای مدیریت کیبورد
        child: Container( // کانتینر اصلی برای محدودیت ارتفاع و پس زمینه کلی مدال (اختیاری)
          // decoration: BoxDecoration( // اگر می‌خواهید کل مدال (به جز دسته) یک پس‌زمینه داشته باشد
          //   color: Theme.of(context).canvasColor,
          //   borderRadius: const BorderRadius.only(
          //     topLeft: Radius.circular(20),
          //     topRight: Radius.circular(20),
          //   ),
          // ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82, // فضای کافی برای دکمه
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30), // ناحیه لمس گرد بزرگ
                  child: Container(
                    width: double.infinity, // تمام عرض برای لمس راحت تر
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    alignment: Alignment.center,
                    child: Container(
                      height: 5,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF542545).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 15),
                child: Text(
                  'شهری که در آن به دنبال هتل هستید را وارد کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Vazirmatn',
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white, // پس‌زمینه سفید برای این بخش
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [ // سایه ملایم برای جداسازی
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: TextField(
                              cursorColor: Color(0xFF542545),
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.black87),
                              decoration: InputDecoration(
                                hintTextDirection: TextDirection.rtl,
                                hintText: 'جستجوی نام شهر...',
                                hintStyle: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey.shade600, fontSize: 14),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                                border: OutlineInputBorder( // بردر اصلی (وقتی فعال نیست یا خطا ندارد)
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none, // حذف بردر، چون از filled استفاده می‌کنیم
                                ),
                                enabledBorder: OutlineInputBorder( // بردر وقتی فعال است
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none, // حذف بردر
                                ),
                                focusedBorder: OutlineInputBorder( // بردر وقتی فوکوس دارد
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: const Color(0xFF542545).withOpacity(0.7), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                filled: true,
                                fillColor: Colors.grey.shade100, // رنگ پس‌زمینه TextField
                              ),
                            ),
                          ),
                          Expanded(
                            child: _filteredCities.isEmpty
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'شهری با این نام یافت نشد.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey.shade700, fontSize: 15),
                                ),
                              ),
                            )
                                : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(8,0,8,8), // پدینگ برای آیتم‌های لیست
                              // shrinkWrap: true, //  دیگر نیازی نیست چون داخل Expanded است
                              itemCount: _filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = _filteredCities[index];
                                final bool isSelected = city == widget.currentCity;
                                return ListTile(
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF542545) : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Color(0xFF542545), size: 22)
                                      : null,
                                  onTap: () {
                                    widget.onCitySelected(city);
                                    Navigator.pop(context);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  selected: isSelected,
                                  selectedTileColor: const Color(0xFF542545).withOpacity(0.08),
                                  dense: true, // برای فشرده‌تر شدن آیتم‌ها
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  color: Colors.grey.shade200,
                                  indent: 12,
                                  endIndent: 12,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30), // پدینگ برای دکمه، شامل پدینگ پایین مدال
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      backgroundColor: Color(0xFF542545), // رنگ پس زمینه دکمه
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'بیخیال',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // رنگ متن دکمه
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}