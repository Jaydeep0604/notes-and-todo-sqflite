class NotificationModel {
  final int? id;
  final String? title;

  NotificationModel({
    this.id,
    required this.title,
  });

  NotificationModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'];
  
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}
