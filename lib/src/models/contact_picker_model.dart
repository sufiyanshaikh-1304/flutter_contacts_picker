class ContactPickerModel {
  final String id;
  final String displayName;
  final List<String> phones;
  final List<String> emails;
  final String? photo;

  ContactPickerModel({
    required this.id,
    required this.displayName,
    required this.phones,
    required this.emails,
    this.photo,
  });
}