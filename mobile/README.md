# Omw Mobile Client

![Flutter & Dart](https://res.cloudinary.com/fghurayri/image/upload/v1637939799/faisal.sh/lab/omw/mobile/logo.png)

The main goal of this mobile application is to enable motorcyclists to live-share their trips.

There are no keyboard-based inputs. Instead, there are only **giant** colored buttons.

It is built using [Flutter](https://flutter.dev), which is Google's take on building cross-platform UIs using the [Dart language](https://dart.dev).

## Running Locally

If you have never run a Flutter application locally before, ensure you follow the [Get started](https://docs.flutter.dev/get-started/install) guide.

Then, use your IDE to launch the application into your emulator. 

## Mobile High-Level Design

This is my first time developing a Flutter application. I used my React Native background to build the required functionality with the bare minimum code.

**This mobile application does not have**:

- Global state management
- Navigation between screens

The used third-party libraries are:

- `phoenix_socket`: It is used as the websocket client to connect with the Phoenix API.
- `geolocator`: It helps to get the geolocation information like coordinates, speed, and heading using the native GPS module.
- `shared_preferences`: It helps to persist and read the tracking session key using the device's disk.
- `share_plus`: It helps the user share the link of their tracking session with others using the native sharing module.

The application mainly has two screens. The deciding factor to show one or the other is if there is already a persisted session key.

### Onboarding Screen

![Omw onboarding](https://res.cloudinary.com/fghurayri/image/upload/v1637300177/faisal.sh/lab/omw/mobile/onboarding.png) 

This screen is displayed if the user doesn't have an ongoing tracking session. The main goal is to show a suggested session name and allow the user to accept it or change it.

### Tracking Screen

![Omw tracking](https://res.cloudinary.com/fghurayri/image/upload/v1637300339/faisal.sh/lab/omw/mobile/speedometer.png)

This screen is displayed if the user already has an ongoing tracking session. The main goal is to listen for location changes and report back to the API through the websocket. Moreover, in addition to allow for sharing the live tracking URL and the ability to stop the tracking session, it also shows a digitally calculated speedometer. 
