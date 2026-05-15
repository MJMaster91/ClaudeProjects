class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? photoPath;
  final int sortOrder;

  const Contact({
    this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'photo_path': photoPath,
        'sort_order': sortOrder,
      };

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String,
        photoPath: map['photo_path'] as String?,
        sortOrder: map['sort_order'] as int? ?? 0,
      );

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? photoPath,
    int? sortOrder,
  }) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        photoPath: photoPath ?? this.photoPath,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
