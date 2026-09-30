# 📱 Flutter Contacts Picker

A clean, customizable and easy-to-use **Contacts Picker widget for Flutter** that reads device contacts and provides search, filtering, alphabet navigation and contact selection.

Built for Flutter applications that need a simple and production-ready way to display and select contacts from the user's device.

## ✨ Features

* ✔ Device contacts integration
* ✔ Single contact selection
* ✔ Search contacts by name
* ✔ Filter contacts by **All / Phone / Email**
* ✔ Alphabetical contact sorting
* ✔ A-Z fast alphabet navigation
* ✔ Drag through alphabet to quickly navigate
* ✔ Phone number display
* ✔ Email fallback when phone number is unavailable
* ✔ Contact permission handling
* ✔ Empty contact state
* ✔ Loading state
* ✔ Clean and responsive UI
* ✔ Custom contact selection callback
* ✔ Android and iOS support through `flutter_contacts`

---

## 📸 Demo

![Flutter Contacts Picker Demo](assets/demo.gif)

The demo shows:

* Contact permission handling
* Contact list
* Search
* Phone/Email filters
* Alphabet navigation
* Contact selection

---

# 🚀 Installation

Add `flutter_contacts_picker` to your `pubspec.yaml`.

```yaml
dependencies:
  flutter_contacts_picker: ^VERSION
```

Then run:

```bash
flutter pub get
```

> Replace `VERSION` with the latest version available on pub.dev.

---

# 📦 Git Installation

You can also use the package directly from GitHub.

```yaml
dependencies:
  flutter_contacts_picker:
    git:
      url: https://github.com/sufiyanshaikh-1304/flutter_contacts_picker.git
```

Then run:

```bash
flutter pub get
```

---

# 🛠️ How to Use

## 1️⃣ Import the package

```dart
import 'package:flutter_contacts_picker/flutter_contacts_picker.dart';
```

---

## 2️⃣ Add `ContactsPicker`

The simplest implementation:

```dart
ContactsPicker(
  onContactSelected: (contact) {
    print(contact.displayName);
  },
)
```

---

## 3️⃣ Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts_picker/flutter_contacts_picker.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
      ),
      body: ContactsPicker(
        onContactSelected: (contact) {
          print('Name: ${contact.displayName}');
          print('Phone: ${contact.phones}');
          print('Email: ${contact.emails}');
        },
      ),
    );
  }
}
```

---

# 👤 Contact Selection

When the user taps a contact, the `onContactSelected` callback returns a `ContactPickerModel`.

```dart
ContactsPicker(
  onContactSelected: (contact) {
    print(contact.displayName);
  },
)
```

You can access:

```dart
contact.id
contact.displayName
contact.phones
contact.emails
contact.photo
```

---

# 🔎 Search Contacts

The widget includes built-in contact search.

Users can search contacts by typing in the search field.

The search works together with the available contact filters.

---

# 🏷️ Contact Filters

The widget provides three built-in filters:

```text
All
Phone
Email
```

### All

Displays all available contacts.

### Phone

Displays contacts that have phone information.

### Email

Displays contacts that have email information.

---

# 🔤 Alphabet Navigation

The contact list is automatically sorted alphabetically.

A vertical alphabet index is provided on the right side:

```text
#
A
B
C
D
...
X
Y
Z
```

Users can:

* Tap a letter
* Drag through the alphabet
* Quickly jump to contacts starting with that letter

The selected alphabet letter is highlighted automatically while scrolling through the contact list.

---

# 📞 Contact Information

The contact list displays the contact's name and available contact information.

If a phone number is available:

```text
John Smith
+91 9876543210
```

If a phone number is unavailable but an email exists:

```text
John Smith
john@example.com
```

If neither is available:

```text
John Smith
No contact information
```

---

# 🔐 Permissions

`flutter_contacts_picker` requires permission to read contacts from the device.

The package requests contact permission automatically when the widget loads.

The package supports:

* `PermissionStatus.granted`
* `PermissionStatus.limited`

If permission is not granted, the widget safely stops loading.

---

# 🤖 Android Configuration

For Android, make sure your application has contact permission.

Open:

```text
android/app/src/main/AndroidManifest.xml
```

Add:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

Place it outside the `<application>` tag.

Example:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.READ_CONTACTS"/>

    <application
        android:label="your_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        ...

    </application>

</manifest>
```

---

# 🍎 iOS Configuration

For iOS, add the contacts usage description to:

```text
ios/Runner/Info.plist
```

Add:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to let you select a contact.</string>
```

Without the required permission description, iOS may not allow the application to access contacts.

---

# ⚙️ Widget Properties

| Property            | Type                            | Description                                        |
| ------------------- | ------------------------------- | -------------------------------------------------- |
| `onContactSelected` | `Function(ContactPickerModel)?` | Called when the user selects a contact             |
| `multiSelect`       | `bool`                          | Configuration property for multi-selection support |

### `onContactSelected`

Returns the selected `ContactPickerModel`.

```dart
onContactSelected: (contact) {
  print(contact.displayName);
}
```

### `multiSelect`

```dart
ContactsPicker(
  multiSelect: false,
)
```

> Currently, contact selection is handled as a single-contact selection callback.

---

# 📋 ContactPickerModel

The selected contact is returned as a `ContactPickerModel`.

Example:

```dart
ContactPickerModel(
  id: 'contact-id',
  displayName: 'John Smith',
  phones: [
    '+91 9876543210',
  ],
  emails: [
    'john@example.com',
  ],
  photo: 'contact-id',
)
```

Available properties:

| Property      | Type           | Description              |
| ------------- | -------------- | ------------------------ |
| `id`          | `String`       | Device contact ID        |
| `displayName` | `String`       | Contact display name     |
| `phones`      | `List<String>` | Contact phone numbers    |
| `emails`      | `List<String>` | Contact email addresses  |
| `photo`       | `String?`      | Contact photo identifier |

---

# 🎨 UI

The widget provides a clean default interface with:

* Search field
* Filter chips
* Contact avatars
* Contact name
* Phone/email information
* Loading indicator
* Empty state
* Alphabet index
* Selected alphabet indicator

The widget is designed to work inside different Flutter screen layouts using:

```dart
Expanded(
  child: ContactsPicker(),
)
```

or other layouts where the widget receives a bounded height.

---

# 📱 Example Project

This package includes a complete example application inside the:

```text
example/
```

directory.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

The example application demonstrates the package functionality and contact selection flow.

---

# 🧪 Testing

Before using the package in production, run:

```bash
flutter analyze
```

Then:

```bash
flutter test
```

You can also test the example application:

```bash
cd example
flutter run
```

---

# 🐛 Troubleshooting

## Contacts are not showing

Make sure contact permission has been granted on the device.

### Android

Check:

```text
android/app/src/main/AndroidManifest.xml
```

for:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

### iOS

Check:

```text
ios/Runner/Info.plist
```

for:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to let you select a contact.</string>
```

---

## No contacts found

If the widget displays:

```text
No contacts found
```

check that:

* The device contains contacts.
* Contact permission is granted.
* The application has been restarted after changing permissions.

---

## Alphabet navigation

The alphabet index works with the currently filtered contact list.

Search and filters automatically update the available contact list and alphabet navigation.

---

# 📂 Package Structure

```text
flutter_contacts_picker/
│
├── android/
├── ios/
├── example/
│
├── lib/
│   ├── flutter_contacts_picker.dart
│   │
│   └── src/
│       ├── models/
│       │   └── contact_picker_model.dart
│       │
│       ├── utils/
│       │   └── contact_utils.dart
│       │
│       └── widgets/
│           └── contacts_picker.dart
│
├── assets/
│   └── demo.gif
│
├── test/
│
├── README.md
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml
```

---

# 🔧 Requirements

Make sure your Flutter project uses a supported Flutter/Dart version compatible with the package and its dependencies.

The package uses:

```text
Flutter
Dart
flutter_contacts
```

---

# 💡 Why Use Flutter Contacts Picker?

`flutter_contacts_picker` provides a ready-to-use contact selection interface without requiring you to build:

* Contact permission handling
* Contact loading
* Contact sorting
* Search UI
* Phone/email filtering
* Alphabet navigation
* Empty states
* Loading states

You can simply add the widget and handle the selected contact through the callback.

---

# 🌟 Example Use Cases

This package can be useful for:

* 💬 Chat applications
* 📞 Calling applications
* 👥 Invite/contact selection
* 💳 Payment applications
* 📤 Contact sharing
* 👨‍👩‍👧 Family and social applications
* 🏢 Business applications
* 📱 Communication applications
* 🔗 Contact-based workflows

---

# 🤝 Contributing

Contributions are welcome.

If you find a bug or have an idea for an improvement:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Run tests and analysis.
5. Commit your changes.
6. Push the branch.
7. Create a Pull Request.

Example:

```bash
git checkout -b feature/new-feature
```

```bash
git add .
```

```bash
git commit -m "Add new feature"
```

```bash
git push origin feature/new-feature
```

---

# 🐞 Issues

If you find a bug or have a feature request, please create an issue in the GitHub repository.

[Report an issue on GitHub](https://github.com/sufiyanshaikh-1304/flutter_contacts_picker/issues?utm_source=chatgpt.com)

When reporting a bug, include:

* Flutter version
* Dart version
* Android/iOS version
* Device information
* Error message
* Steps to reproduce the issue

---

# 📄 License

This package is released under the **MIT License**.

See the `LICENSE` file for the complete license text.

---

# 👨‍💻 Author

**Sufiyan Shaikh**

Flutter Developer

GitHub: [sufiyanshaikh-1304](https://github.com/sufiyanshaikh-1304?utm_source=chatgpt.com)

---

# ⭐ Support

If you find `flutter_contacts_picker` useful, consider giving the repository a ⭐ on GitHub.

Your support helps improve and maintain the package.

---

## 📌 Repository

[flutter_contacts_picker on GitHub](https://github.com/sufiyanshaikh-1304/flutter_contacts_picker?utm_source=chatgpt.com)
