![hotelmanagment-ezgif com-optimize (1)](https://github.com/user-attachments/assets/fb691c00-bc0a-4242-8aa4-00379ff1b302)# Bookit - A Flutter Hotel Reservation

<p align="center">
  <strong>A comprehensive, multi-role hotel reservation app built to showcase advanced cross-platform development with Flutter for Web and Android.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter" alt="Framework: Flutter">
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android-green.svg" alt="Platform: Web & Android">
  <img src="https://img.shields.io/badge/UI-Fully%20Responsive-blueviolet" alt="Fully Responsive UI">
</p>

---

## 📖 Project Overview

**Bookit** is a full-featured application developed as a key portfolio piece to showcase proficiency in the Flutter framework. It was designed to tackle the complexities of a system with two distinct user roles: the **Guest** and the **Hotel Manager**.

The project's main focus is on delivering a **fully responsive UI** that provides a seamless and optimized experience on both **Web and Android** from a single codebase.

---

## ✨ Features & Live Previews

### 🏨 Guest Experience

The complete journey for a guest, from authentication to managing their bookings.

| Feature | Web Preview | Mobile Preview |
| :--- | :---: | :---: |
| **Login & Signup Page**<br/>_A single, unified page for authentication with a toggle to switch between login and registration._ | ![auth-ezgif com-optimize (1)](https://github.com/user-attachments/assets/3a8a5f80-0173-4047-ad97-f915d13cb857) | ![auth](https://github.com/user-attachments/assets/dcf30192-55a4-4600-803a-21c686ccbab6) |
| **Home Page**<br/>_Displays curated lists of discounted, top-rated hotels, and allows filtering by city._ | `[GIF goes here]` | ![home-ezgif com-optimize](https://github.com/user-attachments/assets/9f899642-467c-4fa9-bc87-bbf0195227c0) |
| **Search Page**<br/>_Finds rooms by city/date, with powerful sorting (price) and filtering (discounts)._ | ![search-ezgif com-optimize (1)](https://github.com/user-attachments/assets/372b01a4-8ecb-48d5-8cee-42dfbd86cd6b) | ![search-ezgif com-optimize](https://github.com/user-attachments/assets/109fdd48-862d-4653-a1e4-6390809b2cb5) |
| **Hotel Detail Page**<br/>_An immersive view of hotel specs, available rooms, and authentic guest reviews._ | ![hoteldetail-ezgif com-optimize (1)](https://github.com/user-attachments/assets/985ecc53-1f0a-4101-bcf9-2030b6437e5a) | ![hoteldetail-ezgif com-optimize](https://github.com/user-attachments/assets/85f2b7a9-ed25-403d-8371-9e64e781bede) |
| **Reservation Page**<br/>_A seamless, step-by-step flow to finalize the booking and complete a (simulated) payment._ | ![reservation-ezgif com-optimize (1)](https://github.com/user-attachments/assets/0bddd791-525c-4dbd-8816-4f81395c3c63) | ![reservation-ezgif com-optimize](https://github.com/user-attachments/assets/78ce936a-2fde-4ad6-972d-e9af3843c7b0) |
| **Profile Page**<br/>_Manage user info, favorites, view active/past bookings, and submit reviews. Includes a logout button._| ![guestprofile-ezgif com-optimize (1)](https://github.com/user-attachments/assets/21a6640e-8507-4b68-9880-396da559368f) | ![guestprofile-ezgif com-optimize](https://github.com/user-attachments/assets/04474460-cfb2-429c-b0a9-d9369daa53c8) |

---





### 👨‍💼 Hotel Manager Experience

A dedicated administrative panel for managers to control their properties and monitor performance.

| Feature | Web Preview | Mobile Preview |
| :--- | :---: | :---: |
| **Hotel Management Page**<br/>_A complete CRUD dashboard to add/edit/delete hotels, rooms, and apply discounts._ | ![hotelmanagment-ezgif com-optimize (1)](https://github.com/user-attachments/assets/acbaecae-123c-40b3-922d-54d5a26fb968)
 | `[GIF goes here]` |
| **Reports Page**<br/>_Analytics dashboard with charts for sales/bookings and a comparison mode for two date ranges._ | ![report-ezgif com-optimize (1)](https://github.com/user-attachments/assets/451c7e3e-bd5d-44d7-8851-4ff2151b5870) | ![report-ezgif com-optimize](https://github.com/user-attachments/assets/5d767d9f-6cb6-437a-b532-ba580ed0187c) |
| **Profile Page**<br/>_A centralized view of all reservations, plus profile editing and a secure logout option._ | ![managerprofile-ezgif com-optimize (1)](https://github.com/user-attachments/assets/492a8e77-2339-48c7-a0e2-0e8a6c91b2bb) | ![managerprofile-ezgif com-optimize](https://github.com/user-attachments/assets/e8154b1b-6806-4aad-9276-6dc3440c539a) |

---



## 🛠️ Key Skills & Technologies

This project demonstrates proficiency in the following areas:

-   **Framework:** **Flutter**
-   **Language:** **Dart**
-   **State Management:** **Provider** 

-   **UI Design & Implementation:**
    -   Building complex, custom user interfaces from scratch.
    -   Implementing a **fully responsive layout** that adapts to different screen sizes and platforms using `LayoutBuilder` and `MediaQuery`.
-   **Architecture:**
    -   Structuring the application with a clean, scalable, and maintainable folder structure.
    -   Implementing role-based logic to serve different UIs and functionalities to different user types.

---

## 🚀 Getting Started

To run this project locally, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SamiraAhmadnezhad/BookIt.git
    cd bookit
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    # To run on Web
    flutter run -d chrome

    # To run on an Android device or emulator
    flutter run
    ```

