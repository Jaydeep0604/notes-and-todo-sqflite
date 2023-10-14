class NotesModel {
  final int? id;
  final String title;
  final int age;
  final String description;
  final String email;

  NotesModel(
      {this.id,
      required this.title,
      required this.age,
      required this.description,
      required this.email});

  NotesModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        age = data['age'],
        description = data['description'],
        email = data['email'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'age': age,
      'description': description,
      'email': email
    };
  }
}
