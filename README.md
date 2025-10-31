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
| **Dependency Management**       | Swift Package Manager(SPM)          |
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
Subzillo/
│
├── App/
│   ├── SubzilloApp.swift            // Main entry point
│
├── Common/
│   ├── Models/                      // Shared models used across features
│   │   ├── GeneralResponseModel.swift
│   │   ├── RefreshTokenModel.swift
│   │
│   ├── TabBar/                      // Tab bar UI
│   │   └── MainTabView.swift
│   │
│   └── Views/                       // Reusable UI components
│       ├── CustomButton.swift
│       └── CustomTextField.swift
│
├── Features/
│   ├── Login/                        // Feature-based grouping
│   │   ├── LoginView.swift
│   │   ├── LoginViewModel.swift
│   │   ├── LoginModel.swift
│   │
│   ├── Signup/
│   │   ├── SignupView.swift
│   │   ├── SignupViewModel.swift
│   │   ├── SignupModel.swift
│   │
│   └── ForgotPassword/
│       ├── ForgotPasswordView.swift
│       ├── ForgotPasswordViewModel.swift
│       ├── ForgotPasswordModel.swift
│
├── Managers/                         // App-wide managers
│   ├── AlertManager.swift
│   └── ToastManager.swift
│
├── Network/                          // Networking layer
│   ├── APIEndpoints.swift
│   ├── APIError.swift
│   ├── MultipartRequest.swift
│   ├── NetworkRequest.swift
│   ├── NetworkResult.swift
│   └── ResponseContainer.swift
│
├── Utils/                            // Utilities and helpers
│   ├── Enums/
│   │   └── SomeEnum.swift
│   │
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   ├── Font+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   ├── Validations/
│   │   ├── AuthenticationValidations.swift
│   │   └── HomeValidations.swift
│   │
│   ├── Constants.swift
│   ├── LogType.swift
│   ├── KeychainHelper.swift
│   └── NetworkMonitor.swift
│
└── Resources/                        // App assets
    ├── Fonts/
    ├── Localization/
    ├── Lotties/
    ├── Assets.xcassets
    ├── Info.plist
    ├── LaunchScreen.storyboard
    └── PreviewContent/

```
# Setup & Installation

Follow these steps to set up and run the project locally:

### Prerequisites
- macOS 15.2 or later
- Xcode 16.2 or later
  
### Installation
1. Clone the repository
    ```bash
   git clone git@github.com:HasanOdeh84/Subzillo-IOS.git
   cd Subzillo
2. Open the project
   * open Subzillo.xcodeproj
3. Dependencies Setup (Swift Package Manager):
    * Subzillo uses Swift Package Manager (SPM) to manage third-party libraries.
    All dependencies are automatically resolved by SPM when you open the project in Xcode.
    * If packages don’t load automatically:
    * Go to File → Packages → Resolve Package Versions.
    * Wait until Xcode finishes fetching and updating all dependencies.
    * Once complete, you can build and run the project without any manual installation steps.
4. Certificates & Provisioning Profiles:
    * Select your app target → Signing & Capabilities tab.
    * Choose the correct Team (subzillo’s Apple Developer account).
    * You can find the certificates and profiles in Project folder (Certificates).
    * Double-click each certificate file and profiles to install it in Keychain Access on your Mac - it will automatically be added to Xcode.
    * Make sure correct profiles are selected.
5. Build and run
   - Select the target device or simulator in Xcode.
   - Press Cmd + R to build and run the project.

# Designs
All UI/UX designs for this project are available in Figma:  
[Figma Project Link](https://www.figma.com/design/pJQb6t4lm3Oe7BsBr7Ymbp/Subzillo-App?node-id=29-2530&p=f&t=gAmwpkvwUc7gWdqi-0)

# API Documentation
The project uses the following backend APIs:  
[API Documentation Link](https://devsubzillo.krify.com/api/docs/#/) 

# Contribution
This project is maintained by the iOS development team of **Hasan Odeh** and **Hasanien**.
Any contributions should be coordinated with the team lead before submitting changes.

# Changelog
For detailed updates, see the CHANGELOG.md

# License
This project is proprietary and confidential. Unauthorized use, copying, or distribution is prohibited. 
All code and content are the property of **Hasan Odeh** and **Hasanien**.

