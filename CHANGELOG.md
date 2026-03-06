# Changelog

All notable changes to this project will be documented in this file.

## [1.2.2(39)] (Alpha&Beta-Stage) - 2026-03-06

### Delivered
- Hide the S4 related features
- Three approaches of email sync to send the build to client.

## [1.2.1(38)] (Alpha-Stage) - 2026-03-06

### Delivered
- Three approaches of email sync to send the build to client.

## [1.4.0(37)] (Alpha-QA) - 2026-03-05

### Added
- All S4 functionalities are done except pending points.

## [2.1.0] (Alpha-Stage) - 2026-03-03

### Delivered
- Email sync issues resolved.

## [2.0.0] (Alpha-Stage) - 2026-03-03

### Delivered
- Added three approaches for email sync.

## [1.3.0] (Beta-Stage) - 2026-02-23

### Delivered
- Gmail account connection
- Gmail syncing
- View subscriptions detected from the connected Gmail account and add them
- Delete connected Gmail account

## [1.30.0] (Alpha-Stage) - 2026-02-19

### Modified
- Build shared with stage url
- Changed the connected emails list UI alignment.

## [1.29.0] (Alpha-Stage) - 2026-02-19

### Modified
- Build shared with stage url
- Changed the toast while deleting the email when it's syncing.
- Duplicate screen checkbox alignment issue fixed.

## [1.28.0] (Alpha-Stage) - 2026-02-18

### Modified
- Build shared with stage url
- Plan type modifications in preview screen.

## [1.27.0] (Alpha-Stage) - 2026-02-16

### Modified
- Build shared with stage url
- Redirection to the connected emails list once the email is connected.
- All S4 features and APIs are hidden except Gmail sync.

## [1.26.0] (Alpha-Dev) - 2026-02-14

### Modified
- changed the gmailOauthCallback api name to oauthCallback. 

## [1.25.0] (Alpha-Dev) - 2026-02-13

### Added
- Connect Email, connected emails list, no subscriptions bottom sheet UI's.
- Gmail connect, gmail sync, delete mail and email subscriptions list. 

## [1.24.0] (Beta-Stage) - 2026-01-24

### Delivered
- Next Renewal Date: The next renewal date is not being captured correctly for some subscriptions.
- Billing Cycle Selection: For certain subscriptions, the selected billing cycle (monthly or yearly) is not applied as expected.
- Currency Update Issue: When switching from a monthly plan to a yearly plan, the amount updates correctly; however, the currency changes to USD instead of remaining in AED, even though AED was initially detected correctly.
- Expired Subscription Detection:An expired subscription was identified. The system shows the user whether they want to replace the existing subscription or add it as a new one.
- Dark Theme Image Support:Data extraction from images in dark theme is now working correctly.

## [1.24.0] (Alpha-Stage) - 2026-01-24

### Fixed
- Bug fixes and modifications.

## [1.23.0] (Alpha-Stage) - 2026-01-23

### Fixed
- Client feedback points and modifications and build sent with stage url.

## [1.22.0] (Beta-Stage) - 2026-01-21

### Delivered
- Manual subscription data has been updated in the database.
- When a user enters an incorrect amount (for example, 609), a Hint will be displayed stating that the entered amount is not the original price. 
- If a subscription does not support Quarterly or Biannual plans, those billing cycles will not be displayed. Only the available billing cycles will be shown.
- In the Manual entry screen, the Monthly billing cycle will be selected by default.
- The Plan Type will now be displayed as a dropdown instead of an input field. If no plan types are available for a specific subscription, Basic and Free will be shown as default options.

## [1.20.0] (Alpha-Stage) - 2026-01-20

### Fixed
- Validation agent modifications and build sent with stage url.

## [1.19.0] (Alpha-Dev) - 2026-01-20

### Fixed
- Validation agent modifications and build sent with dev url.

## [1.18.0] (Alpha-Stage) - 2026-01-10

### Fixed
- New modifications and bug fixes.

## [1.17.0] (Alpha-Dev) - 2026-01-09

### Fixed
- Auto fill details changes in manual and preview screens and build shared with dev url.

## [1.16.0] (Alpha-Dev) - 2026-01-08

### Fixed
- Sprint3 new client feedback points and build shared with dev url.

## [1.15.0] (Alpha-Stage) - 2026-01-07

### Fixed
- Sprint3 new client feedback points.

## [1.2.0] (Beta-Stage) - 2025-12-29

### Delivered
- Sprint3 new client feedback points.

## [1.14.0] (Alpha-Stage) - 2025-12-29

### Fixed
- Sprint3 client feedback Bug fixes.

## [1.13.0] (Alpha-Stage) - 2025-12-26

### Updated
- Sprint3 client new feedback points.

## [1.1.0] (Beta-Stage) - 2025-12-23

### Fixed
- Sprint3 minor changes.

### Delivered
- Sprint3 client feedback points.

## [1.12.0] (Alpha-Stage) - 2025-12-22

### Fixed
- Sprint3 bug fixes.

### Updated
- Phone number formatting in signup screen.

## [1.11.0] (Alpha-Stage) - 2025-12-22

### Fixed
- Sprint3 bug fixes.

### Updated
- Voice flow.
- Phone number formatting library has been changed.

## [1.10.0] (Alpha-Dev) - 2025-12-18

### Added
- Voice missing details flow.

## [1.9.0] (Alpha-Dev) - 2025-12-17

### Updated
- Filter and sort separation for subscriptions.
- Welcome screen UI changes.
- Login screen UI changes.
- Onboardings screen UI changes.
- Add subscriptions UI changes.
- Calender view UI changes.
- Manual add subscriptions UI changes.
- Subscription preview UI changes

### Added
- Country based phone number formatting.
- List swipe edit and delete UI.
- Subscription preview Auto filling details.
- Redirection to subscriptions screen in appstore.

## [1.8.0] (Alpha-Dev) - 2025-12-13

### Added
- Manual entry auto filling details.

## [1.7.0] (Alpha) - 2025-12-09

### Updated
- Voice related UI changes.
- Siri redirection changes to subscription preview and manual if fails.

## [1.6.0] (Alpha) - 2025-12-04

### Updated
- Sprint3 client feedback points.

### Added
- Microsoft social login

### Pending
- Prefill details in Manual Add and Preview screens.

## [1.0.0] (Beta-Stage) - 2025-12-01

### Delivered
- Sprint 3 features

## [1.5.0] (Alpha-Stage) - 2025-12-01

### Fixed
- Sprint 3 bug fixes

## [1.4.0] (Alpha-Stage) - 2025-11-28

### Fixed
- Sprint 3 bug fixes
- Apple signin issue in release mode

## [1.2.0] (Alpha-Stage) - 2025-11-27

### Fixed
- Sprint 3 bug fixes

### Added 
- Kept alerts to check apple signin issue

## [1.1.0] (Alpha-Stage) - 2025-11-25

### Fixed
- Sprint 3 bug fixes

### Added
- Dark mode

### Changed
- Dev to staging server

## [1.0.0] (Alpha-Dev) - 2025-11-21

### Added
Sprint 3 features:
- Login screen
- Otp verification for email and mobile
- Registration screen
- Success screens for otp verification and registration
- Onboarding screens
- Social logins - Apple and Gmail
- Welcome screen
- Home screen
- Subscriptions List and calender view and filters
- Manual Entry subscription
- Voice subscription
- Siri
- Image subscription
- Paste subscription
- Subscriptions review screens
- Subscription details screen
- Duplicate subscriptions screens
- Logout

