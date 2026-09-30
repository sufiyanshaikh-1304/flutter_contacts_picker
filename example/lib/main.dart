import 'package:flutter/material.dart';
import 'package:flutter_contacts_picker/flutter_contacts_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _seed = Color(0xFF6C63FF);

  ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(
      // White cards on a soft tinted background make the search bar pop.
      surface: isLight ? Colors.white : const Color(0xFF1E1E26),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
      isLight ? const Color(0xFFF6F5FB) : const Color(0xFF121218),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.primary,
        contentTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts Picker',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ContactsPage(),
    );
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  void _showSelected(BuildContext context, dynamic contact) {
    final phones = contact.phones as List;
    final details = phones.isNotEmpty ? ' • ${phones.first}' : '';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Selected: ${contact.displayName}$details')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: SafeArea(
        // The picker already has its own 16px horizontal padding.
        child: ContactsPicker(
          onContactSelected: (contact) => _showSelected(context, contact),
        ),
      ),
    );
  }
}