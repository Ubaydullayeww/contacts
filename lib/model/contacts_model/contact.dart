class Contacts {
  int id;
  int number;
  String name;
  String image;

  Contacts({
    required this.id,
    required this.number,
    required this.name,
    required this.image,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      id: json['id'],
      number: json['number'],
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'image': image,
    };
  }

  

}
