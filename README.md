# Subzillo-IOS
Smart subscription management at your fingertips.

# Description
Subzillo is a smart subscription management platform that helps users track, organize, and optimize their digital subscriptions in one place. It offers features like subscription reminders, expense insights, and centralized control over services such as Google Play, Apple Store, Netflix, Spotify, and more. With secure integration, users can easily manage renewals, cancellations, and payments while avoiding missed deadlines or unwanted charges. Designed with a simple and intuitive Android interface, Subzillo ensures transparency, convenience, and smarter control over recurring expenses.

# Technologies used

| Feature/Aspect                 | Details                                           |
|--------------------------------|--------------------------------------------------|
| **Language**                   | English                                          |
| **Supported Platforms**        | iOS 16.0 and above (up to iOS 18)               |
| **Integrated Development Environment (IDE)** | Xcode 16.2, the official Apple development environment                                    |
| **Device Type**                 | iPhone                                           |
| **Device Orientation**          | Portrait                                         |
| **Programming Language**        | Swift                                            |
| **UI Framework**                | SwiftUI + Combine                               |
| **Architecture Pattern**        | MVVM (Model–View–ViewModel)                     |
| **Dependency Management**       | CocoaPods          |
| **Networking**                  | Native URLSession for secure HTTP networking    |
| **Backend Communication**       | RESTful APIs with JSON                           |
| **Push Notifications**          | Apple Push Notification Service (APNs)          |
| **Crash Reporting**             | Firebase Crashlytics                             |
| **Payments**                    | In-app purchases                                 |


# Dependencies used
For the complete list of dependencies, see the [Dependencies Document](./Dependencies.md)

# Architecture
The app follows **MVVM (Model-View-ViewModel)** pattern to ensure separation of concerns and maintainability. [Architecture Document](./Architecure.md)

# Project structure

```text
Application/
└─ Core/                       
   ├─ Common/
   │  ├─ Enums.swift
   │  ├─ Models.swift
   │  └─ Views.swift
   ├─ Controllers/
   │  └─ MainApp.swift
   ├─ Extensions/
   │  ├─ ColorExtensions.swift
   │  ├─ FontExtension.swift
   │  └─ ViewExtensions.swift
   ├─ Services/
   │  └─ Network/
   │     ├─ APIEndPoints.swift
   │     ├─ APIError.swift
   │     ├─ MultipartRequest.swift
   │     ├─ NetworkRequest.swift
   │     ├─ NetworkResult.swift
   │     └─ ResponseContainer.swift
   ├─ Utils/
   │  ├─ ColorConstants.swift
   │  ├─ Constants.swift
   │  ├─ LogType.swift
   │  └─ NetworkMonitor.swift
   └─ Features/
      ├─ Login/
      │  ├─ Models/
      │  │  └─ LoginModel.swift
      │  ├─ ViewModels/
      │  │  └─ LoginViewModel.swift
      │  └─ Views/
      │     └─ LoginView.swift
      ├─ AddSubscription/
      │  ├─ Models/
      │  │  └─ AddSubscriptionModel.swift
      │  ├─ ViewModels/
      │  │  └─ AddSubscriptionViewModel.swift
      │  └─ Views/
      │     └─ AddSubscriptionView.swift
    Resources/
    ├─ Assets.xcassets
    ├─ Fonts
    ├─ Localization
    ├─ Lotties
    ├─ Info
    └─ LaunchScreen

```
# Setup & Installation

Follow these steps to set up and run the project locally:

### Prerequisites
- macOS 15.2 or later
- Xcode 16.2 or later
- CocoaPods 
  
### Installation
1. Clone the repository
    ```bash
   git clone git@github.com:HasanOdeh84/Subzillo-IOS.git
   cd Subzillo
2. Install dependencies
    ```bash
   sudo gem install cocoapods   # if CocoaPods is not installed
   pod install
3. Open the project
   * open Subzillo.xcworkspace
4. Build and run
   - Select the target device or simulator in Xcode.
   - Press Cmd + R to build and run the project.

# Contribution
This project is maintained by the iOS development team of **Hasan Odeh** and **Hasanien**.
Any contributions should be coordinated with the team lead before submitting changes.

# Changelog
For detailed updates, see the CHANGELOG.md

# License
This project is proprietary and confidential. Unauthorized use, copying, or distribution is prohibited. 
All code and content are the property of **Hasan Odeh** and **Hasanien**.

