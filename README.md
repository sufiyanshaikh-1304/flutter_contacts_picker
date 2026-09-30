# 📱 Flutter Contacts Picker

A clean and customizable Contacts Picker widget for Flutter that reads device contacts and provides search, filtering, alphabet navigation and contact selection.

This widget supports:

* ✔ Device contact integration
* ✔ Single contact selection
* ✔ Contact search
* ✔ Phone & Email filters
* ✔ Alphabetical contact sorting
* ✔ A-Z alphabet navigation
* ✔ Alphabet drag navigation
* ✔ Phone number display
* ✔ Email fallback
* ✔ Contact permission handling
* ✔ Loading & empty states
* ✔ Clean and responsive UI

## 🚀 Features

🔹 Contact Picker

Display contacts from the user's device and select a contact with a simple callback.

🔹 Search Contacts

Search contacts by name using the built-in search field.

🔹 Contact Filters

Filter contacts using:

* All
* Phone
* Email

🔹 Alphabet Navigation

Quickly navigate through contacts using the A-Z alphabet index.

🔹 Alphabet Drag

Drag vertically through the alphabet to quickly jump to contacts.

🔹 Contact Information

Displays phone numbers when available and automatically uses email when a phone number is not available.

🔹 Permission Handling

Automatically requests contact read permission and handles permission states.

🔹 Clean UI

Includes search field, filter chips, contact avatars, loading state, empty state and alphabet navigation.

---


## 🎬 Output Preview


The demo shows:

* Contact permission
* Contact list
* Search
* All / Phone / Email filters
* Alphabet navigation
* Alphabet drag
* Contact selection

<div align="center">

<img
src="assets/contacts_demo.gif"
alt="Flutter Contacts Picker Demo"
width="200"
/>

</div>

<p align="center">
  <b>Flutter Contacts Picker Demo</b>
</p>


## 📦 Installation

Add dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_contacts_picker: ^VERSION
```

Then run:

```bash
flutter pub get
```

Replace `VERSION` with the latest version available on pub.dev.

### From Git

```yaml
dependencies:
  flutter_contacts_picker:
    git:
      url: https://github.com/sufiyanshaikh-1304/flutter_contacts_picker.git
```

---

## 🛠 How to Use

### 1️⃣ Import the library

```dart
import 'package:flutter_contacts_picker/flutter_contacts_picker.dart';
```

### 2️⃣ Example Usage

```dart
ContactsPicker(
  onContactSelected: (contact) {
    print('Name: ${contact.displayName}');
    print('Phone: ${contact.phones}');
    print('Email: ${contact.emails}');
  },
)
```

### 3️⃣ Complete Example

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

## 🎨 Customizable Properties

| **Property**        | **Description**                     |
| ------------------- | ----------------------------------- |
| `onContactSelected` | Callback when a contact is selected |
| `multiSelect`       | Selection configuration             |

### ContactPickerModel Properties

| **Property**  | **Description**                 |
| ------------- | ------------------------------- |
| `id`          | Device contact ID               |
| `displayName` | Contact display name            |
| `phones`      | List of contact phone numbers   |
| `emails`      | List of contact email addresses |
| `photo`       | Contact photo identifier        |

---

## 🔐 Permissions

The package automatically requests permission to read device contacts.

### Android

Add the following permission to:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

Place it outside the `<application>` tag.

### iOS

Add the following to:

`ios/Runner/Info.plist`

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to let you select a contact.</string>
```

---

## 📂 Package Structure

```text
flutter_contacts_picker/
│
├── example/
├── assets/
│   └── demo.gif
├── lib/
│   ├── flutter_contacts_picker.dart
│   └── src/
│       ├── models/
│       ├── utils/
│       └── widgets/
├── test/
├── CHANGELOG.md
├── LICENSE
├── README.md
└── pubspec.yaml
```

---

## 🧪 Testing

Run:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the example:

```bash
cd example
flutter pub get
flutter run
```

---

## 🐞 Issues

If you find a bug or have a feature request, please create an issue in the GitHub repository.

[Report an Issue](https://github.com/sufiyanshaikh-1304/flutter_contacts_picker/issues)

When reporting an issue, please include:

* Flutter version
* Dart version
* Android/iOS version
* Device information
* Error message
* Steps to reproduce the issue

---

## 🤝 Contributing

Contributions are welcome.

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Commit your changes.
7. Push your branch.
8. Create a Pull Request.

---

## 📜 License

MIT License

```text
Copyright (c) 2026 Excelsior Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

