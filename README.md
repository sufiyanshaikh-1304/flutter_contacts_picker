📇 Flutter Contacts Picker

A premium, production-ready contacts picker widget for Flutter, built on top of flutter_contacts.

Search your contacts, filter by phone or email, and jump through the list with an A–Z sidebar that shows a magnified letter bubble and tells the user when a letter has no contacts.

📸 Output Preview
<table> <tr> <td align="center"> <img src="screenshots/contact_list.png" width="200" alt="Contact list"/><br/> <sub><b>Contact list</b></sub> </td> <td align="center"> <img src="screenshots/alphabet_zoom.png" width="200" alt="Alphabet zoom bubble"/><br/> <sub><b>Alphabet zoom</b></sub> </td> <td align="center"> <img src="screenshots/no_contacts_letter.png" width="200" alt="No contacts for letter"/><br/> <sub><b>No contacts for a letter</b></sub> </td> <td align="center"> <img src="screenshots/search_filter.png" width="200" alt="Search and filter"/><br/> <sub><b>Search + Email filter</b></sub> </td> </tr> </table> <p align="center"> <video src="screenshots/output.mp4" width="200" controls muted></video> </p>

📝 Put your screenshots in a screenshots/ folder next to this file, or replace the paths with hosted URLs. On GitHub, drag output.mp4 into the README editor to get a hosted video URL.

✨ Features
Feature	Description
🔍 Live search	Search by name, phone number or email as you type, with a clear (✕) button
🎛 Filters	All, Phone and Email pills with a live contact count
🔤 A–Z sidebar	Tap or drag to jump to any letter
🔎 Zoom bubble	A large magnified letter follows your finger while scrubbing
🚫 Empty-letter message	Letters with no contacts are dimmed; tapping one shows "No contacts found" instead of jumping
📑 Section headers	Contacts are grouped under A–Z headers (# for numbers and symbols)
🎨 Gradient avatars	Colored initials avatar, stable per contact name
☑️ Multi-select	Optional multi-select mode with a check mark
🔐 Permission handling	Dedicated screen with an Allow access retry button
🌗 Light + dark mode	Colors come from your app's ColorScheme
⚡ Fast on large lists	Precomputed offsets and binary search, so thousands of contacts stay smooth
📋 Requirements
Requirement	Version
Flutter	3.27+ (uses Color.withValues, itemExtentBuilder)
Dart	3.0+ (uses sealed classes and pattern matching)
flutter_contacts	The version that provides FlutterContacts.permissions and ContactProperty
📦 Installation
Step 1 – Add the dependency

From a local path:

yaml
dependencies:
  flutter_contacts_picker:
    path: ../flutter_contacts_picker # your path

From Git:

yaml
dependencies:
  flutter_contacts_picker:
    git:
      url: https://github.com/yourusername/flutter_contacts_picker.git
Step 2 – Install packages
bash
flutter pub get
🔐 Platform Setup (required)

The picker reads the device contacts, so each platform needs a permission entry. Without it, the permission request fails or the app crashes.

Step 3 – Android

Open android/app/src/main/AndroidManifest.xml and add this above the <application> tag:

xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
Step 4 – iOS

Open ios/Runner/Info.plist and add:

xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts so you can pick a contact.</string>

⚠️ Write a clear reason in the description. Apple rejects apps with vague permission texts.

🛠 How to Use
Step 5 – Import
dart
import 'package:flutter_contacts_picker/flutter_contacts_picker.dart';
Step 6 – Add the widget

The picker fills the space it is given, so put it in a bounded area such as Scaffold.body or an Expanded.

dart
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: SafeArea(
        child: ContactsPicker(
          onContactSelected: (contact) {
            debugPrint('Selected: ${contact.displayName}');
          },
        ),
      ),
    );
  }
}

ℹ️ The picker already has 16 px horizontal padding of its own. Don't wrap it in extra horizontal padding.

Step 7 – Multi-select (optional)
dart
ContactsPicker(
  multiSelect: true,
  onContactSelected: (contact) {
    // Called every time a contact is tapped (selected or unselected).
    debugPrint('Tapped: ${contact.displayName}');
  },
)
Step 8 – Match your app theme (recommended)

The picker reads its colors from Theme.of(context).colorScheme. Use a Material 3 seed color and the picker follows automatically:

dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
    ),
  ),
  home: const ContactsPage(),
);
⚙️ API Reference
ContactsPicker
Property	Type	Default	Description
onContactSelected	Function(ContactPickerModel)?	null	Called when the user taps a contact
multiSelect	bool	false	Shows a check mark and toggles selection on tap
ContactPickerModel
Field	Type	Description
id	String	Contact ID (empty string if the device gives none)
displayName	String	Contact name ('Unknown' if missing)
phones	List<String>	All phone numbers
emails	List<String>	All email addresses
photo	String?	Set to the contact ID when the contact has a photo, otherwise null
🧭 How the Alphabet Sidebar Behaves
User action	Result
Tap / drag on a letter that has contacts	List jumps to that section, bubble shows the letter
Tap / drag on a letter with no contacts	List does not move, grey bubble appears, "No contacts found – No contacts start with “B”" card shows for about 1.5 s
Email filter is on and the letter has no contacts with an email	Same message, for example "No contacts with email start with “B”"
Scroll the list normally	The highlighted letter follows the list

Letters with no contacts under the current search or filter are shown dimmed in the sidebar.

📁 Project Structure
lib/
├── flutter_contacts_picker.dart      # Library export file
├── widgets/
│   └── contacts_picker.dart          # ContactsPicker widget
├── models/
│   └── contact_picker_model.dart     # ContactPickerModel
└── utils/
    └── contact_utils.dart            # searchContacts, filterContacts, getFirstLetter

Make sure flutter_contacts_picker.dart exports the widget and the model:

dart
export 'widgets/contacts_picker.dart';
export 'models/contact_picker_model.dart';
🧪 Pre-release Checklist

Run through this list before publishing or shipping:

 READ_CONTACTS added to AndroidManifest.xml
 NSContactsUsageDescription added to Info.plist
 Tested on a real device (emulators usually have few or no contacts)
 Tested with permission denied and tapped Allow access
 Tested with an empty contact list
 Tested with 1,000+ contacts for scroll performance
 Tested a letter with no contacts (message appears, list does not jump)
 Tested light and dark mode
 Tested on a small screen (about 320 dp wide)
 flutter analyze shows no issues
 flutter test passes
🩺 Troubleshooting
Problem	Fix
Permission dialog never appears (Android)	Check that READ_CONTACTS is in AndroidManifest.xml and do a full rebuild (flutter clean && flutter run)
App crashes on iOS when opening the picker	NSContactsUsageDescription is missing in Info.plist
withValues is not defined	Upgrade Flutter to 3.27+, or replace withValues(alpha: x) with withOpacity(x)
itemExtentBuilder is not defined	Upgrade Flutter to 3.20+
sealed or pattern-matching syntax errors	Set sdk: ">=3.0.0 <4.0.0" in pubspec.yaml (or higher)
Blank screen / "unbounded height" error	Put the picker in Scaffold.body or Expanded, not directly in a Column or ListView
List is empty even though the phone has contacts	The user chose limited access on iOS, so only the contacts they allowed are returned
Search bar blends into the background	Give your Scaffold a tinted scaffoldBackgroundColor; the search bar uses colorScheme.surface
⚠️ Known Limitations
Photos: ContactPickerModel.photo stores the contact ID, not the image bytes. Avatars show colored initials.
Multi-select callback: in multiSelect mode, onContactSelected fires on every tap and does not return the full selected list. Keep your own Set of selected IDs in your app if you need the list.
Theming: colors come from the app ColorScheme. There are no per-widget color properties yet.
Letters: only A–Z get their own section. Accented and non-Latin names (for example É, अ) are grouped under #.
🗺 Roadmap
 onSelectionChanged(List<ContactPickerModel>) for multi-select
 Real contact photos in avatars
 Custom colors and text styles via a ContactsPickerStyle object
 Localization for built-in texts
 Unit tests for ContactUtils
🤝 Contributing
Fork the repository
Create a branch: git checkout -b feature/my-feature
Commit your changes: git commit -m "Add my feature"
Push the branch: git push origin feature/my-feature
Open a Pull Request

Please run flutter analyze and flutter test before opening a PR.

📜 License

MIT License

Copyright (c) 2025 Excelsior Technologies

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
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
