# Dependencies Used in Subzillo

This document lists all **dependencies** used in the project.

## 1. Lottie-iOS

- **Dependency**: 'lottie-ios'
- **Purpose**: Lottie-iOS is a library that allows you to easily add high-quality animations to your iOS app. It supports JSON-based animations exported from Adobe After Effects using the Bodymovin plugin.
- **Use Cases in Subzillo**:
  - Displaying animated loading indicators.
  - Showing success or error animations for user actions.
  - Making the app feel more interactive and engaging.
- **Resources**: [Lottie github project](https://github.com/airbnb/lottie-ios)  

## 2. SDWebImageSwiftUI

- **Dependency**: 'SDWebImageSwiftUI'
- **Purpose**: This library allows asynchronous downloading and caching of images in SwiftUI views. It automatically handles memory management, caching, and smooth image rendering.
- **Use Cases in Subzillo**:
  - Efficiently loading remote images without blocking the UI.
  - Automatic caching to improve performance and reduce network calls.
- **Resources**: [SDWebImageSwiftUI github project](https://github.com/SDWebImage/SDWebImageSwiftUI)

## 3. Google Sign-In

- **Dependency**: 'GoogleSignIn'
- **Purpose**: Google Sign-In enables users to authenticate using their Google accounts. It provides a secure and familiar login method.
- **Use Cases in Subzillo**:
  - Allowing users to quickly sign in without creating a separate account.
  - Accessing user profile information like name and email for personalized experience.
  - Simplifying authentication flows for iOS users.
- **Resources**: [Google Sign-In github project](https://github.com/google/GoogleSignIn-iOS)

## 4. FirebaseCrashlytics

- **Dependency**: 'FirebaseCrashlytics'
- **Purpose**: Firebase Crashlytics helps monitor app stability by capturing real-time crash reports. It enables developers to identify, prioritize, and fix issues that affect the user experience.
- **Use Cases in Subzillo**:
  - Tracking unexpected crashes and non-fatal errors occurring in the app.
  - Providing detailed insights such as stack traces, logs, and device information to speed up debugging.
  - Monitoring app stability trends and improving reliability across releases.
- **Resources**: [FirebaseCrashlytics github project](https://github.com/firebase/firebase-ios-sdk)

## 5. MSAL (microsoft-authentication-library-for-objc)

- **Dependency**: 'MSAL'
- **Purpose**: MSAL enables secure authentication using Microsoft accounts.
- **Use Cases in Subzillo**:
  - Allowing users to log in with their Microsoft accounts.
- **Resources**: [MSAL github project](https://github.com/AzureAD/microsoft-authentication-library-for-objc)


## 6. libPhoneNumber
- **Dependency**: libPhoneNumber
- **Purpose**: libPhoneNumber is used to parse, validate, and format phone numbers accurately. It ensures consistent and reliable phone number handling across different regions.
- **Use Cases in Subzillo**:
  - Automatically formatting phone numbers based on the selected country code.
- **Resources**: [PhoneNumberKit github project](https://github.com/iziz/libPhoneNumber-iOS)







