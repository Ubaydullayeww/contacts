class Contacts {
  int id;
  int number;
  String name;
  String image;
  String? category;
  bool isImportant;

  Contacts({
    required this.id,
    required this.number,
    required this.name,
    required this.image,
    this.category,
    this.isImportant = false,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      id: json['id'],
      number: json['number'],
      name: json['name'],
      image: json['image'],
      category: json['category'],
      isImportant: json['isImportant'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'image': image,
      'category': category,
      'isImportant': isImportant,
    };
  }

  bool get isLocalImage => image.startsWith('/');
}
