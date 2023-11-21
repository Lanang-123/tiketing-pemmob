class Ticket {
  int? id;
  final String title;
  final String category;
  final String image;
  final double price;
 
  Ticket({
    this.id,
    required this.title,
    required this.category,
    required this.image,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['category'] = category;
    map['image'] = image;
    map['price'] = price;
    return map;
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      image: map['image'],
      price: map['price'],
    );
  }
}