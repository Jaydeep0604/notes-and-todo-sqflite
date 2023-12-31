class NotesModel {
  final int? id;
  final String? title;
  final String? note;
  final int? pin;
  final int? archive;
  final String? email;
  final int? deleted;
  final String? create_date;
  final String? edited_date;
  final List<String> image_list;


  NotesModel({
    this.id,
    this.title,
    this.note,
    this.pin,
    this.archive,
    this.email,
    this.deleted,
    this.create_date,
    this.edited_date,
    required this.image_list,
  });

  NotesModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        note = data['note'],
        pin = data['pin'],
        archive = data['archive'],
        email = data['email'],
        deleted = data['deleted'],
        create_date = data['create_date'],
        edited_date = data['edited_date'],
        image_list = (data['image_list']as String).split(',');

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'pin': pin,
      'archive': archive,
      'email': email,
      'deleted': deleted,
      'create_date': create_date,
      'edited_date': edited_date,
      'image_list': image_list.join(',')
    };
  }
}
