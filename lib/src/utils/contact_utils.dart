import '../models/contact_picker_model.dart';

class ContactUtils {
  static List<ContactPickerModel> searchContacts(
      List<ContactPickerModel> contacts,
      String query,
      ) {
    if (query.isEmpty) {
      return contacts;
    }

    return contacts.where((contact) {
      return contact.displayName
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  }

  static List<ContactPickerModel> filterContacts(
      List<ContactPickerModel> contacts,
      String filter,
      ) {
    if (filter == 'All') {
      return contacts;
    }

    if (filter == 'Phone') {
      return contacts.where((contact) {
        return contact.phones.isNotEmpty;
      }).toList();
    }

    if (filter == 'Email') {
      return contacts.where((contact) {
        return contact.emails.isNotEmpty;
      }).toList();
    }

    return contacts;
  }

  static String getFirstLetter(String name) {
    if (name.isEmpty) {
      return '#';
    }

    return name[0].toUpperCase();
  }
}