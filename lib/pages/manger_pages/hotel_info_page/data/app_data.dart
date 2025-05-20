import '../models/room_model.dart';

// داده‌های نمونه اتاق‌ها - در یک برنامه واقعی، این داده‌ها از سرور یا دیتابیس می‌آیند
// این لیست قابل تغییر است (برای افزودن اتاق جدید)
List<Room> sampleRooms = [
  Room(
    id: 'r1',
    hotelId: '1',
    name: 'اتاق دوتخته استاندارد',
    type: '2 نفر',
    pricePerNight: '1,200,000',
    imageUrl: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aG90ZWwlMjByb29tJTIwYmVkfGVufDB8fDB8fHww',
  ),
  Room(
    id: 'r2',
    hotelId: '1',
    name: 'سوئیت جونیور',
    type: '3 نفر + کودک',
    pricePerNight: '2,500,000',
    imageUrl: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8aG90ZWwlMjByb29tJTIwYmVkfGVufDB8fDB8fHww',
  ),
  Room(
    id: 'r3',
    hotelId: '2',
    name: 'اتاق یک تخته اکونومی',
    type: '1 نفر',
    pricePerNight: '800,000',
    imageUrl: 'https://images.unsplash.com/photo-1568495248636-6412b2b58075?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGhvdGVsJTIwcm9vbSUyMGJlZHxlbnwwfHwwfHx8MA%3D%3D',
  ),
];