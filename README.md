# E-Wallet — Ultimate Digital Wallet 

A modern, fast, and scalable financial management experience. **E-Wallet** is a Flutter application built with **Feature-First Clean Architecture** principles. It enables users to track expenses, set financial goals, and manage subscriptions seamlessly.

##  Key Features

* **Secure Authentication:** Reliable login/sign-up system powered by Supabase Auth.
* **Smart Expense Tracking:** Real-time tracking of income and expenses with category-based filtering.
* **Financial Goals:** Progress tracking and visualizations for your savings targets.
* **Subscription Management:** Control recurring payments (e.g., Netflix, Spotify) in one place.
* **Visual Analytics:** Dynamic financial charts and insights powered by `fl_chart`.
* **Modern UI:** Dark-mode oriented interface following Material 3 standards.

##  Tech Stack

* **Frontend:** [Flutter](https://flutter.dev) (SDK ^3.10.7)
* **State Management:** [Riverpod](https://riverpod.dev) (Notifier & Provider)
* **Backend & Auth:** [Supabase](https://supabase.com)
* **Local Database:** [Isar](https://isar.dev) (Planned)
* **Routing:** [GoRouter](https://pub.dev/packages/go_router)
* **Design:** Material 3 & Custom SVG Icons

##  Architecture

The project follows a **Feature-First Clean Architecture** for better maintainability and scalability:

```text
lib/
├── core/           # App-wide constants, network configurations, and shared models
├── shared/         # Common widgets used across multiple features
└── features/       # Feature-based modularization (auth, home, goals, subscriptions)
    ├── domain/     # Business logic and entity models
    ├── data/       # Repository implementations and data sources
    ├── providers/  # State management (Riverpod)
    └── presentation/# Screens and UI components
```

##  Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/e-wallet.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Supabase Configuration:**
    Create a `lib/core/constants/supabase_constants.dart` file and add your Supabase URL and Anon Key.
4.  **Run the app:**
    ```bash
    flutter run
    ```

## 📄 License & About

**Copyright (c) 2026 Ömer Asaf Dinç. All Rights Reserved.**

This project is developed as a graduation thesis. The source code is made public strictly for portfolio demonstration and peer review purposes.
