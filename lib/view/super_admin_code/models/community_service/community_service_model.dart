
class SuperAdminCommunityServiceModel {
  final String? id;
  final String title;
  final String icon;
  final List<String> descriptions;
  final Map<String, String> locationContacts;

  SuperAdminCommunityServiceModel({
    this.id,
    required this.title,
    required this.icon,
    required this.descriptions,
    required this.locationContacts,
  });

  factory SuperAdminCommunityServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return SuperAdminCommunityServiceModel(
      id: id,
      title: map['title'] ?? '',
      icon: map['icon'] ?? 'help_outline',
      descriptions: List<String>.from(map['descriptions'] ?? []),
      locationContacts: Map<String, String>.from(map['locationContacts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'descriptions': descriptions,
      'locationContacts': locationContacts,
    };
  }
}