# HealthKit and SQLite Demo

This is a simple SwiftUI application that uses HealthKit to fetch the user's step count data and SQLite to store and retrieve a random number.

## Features

- Fetch today's step count from HealthKit.
- Generate a random number and save it to a local SQLite database.
- Display the last saved random number when the app launches.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Setup

Follow these steps to get this project running on your machine:

### Step 1: Clone the repository

Clone the repository to your local machine.

### Step 2: Open the project in Xcode
Open the .xcodeproj file in Xcode.

### Step 3: Enable HealthKit
To enable HealthKit, go to your project in Xcode, select your app's target, then go to the Signing & Capabilities tab. Click "+" and add the "HealthKit" capability.

### Step 4: Set up privacy descriptions
Your app's Info.plist file must provide a usage description for any health data types it accesses. Add the NSHealthShareUsageDescription key to your Info.plist file with a string value describing why your app needs access to this data.

### Step 5: Run the application
Connect your device to run the application.
