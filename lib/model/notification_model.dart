class NotificationDataModel {
  final int? id;
  final int? notificationId;
  final int? parentId;
  final String? title;

  NotificationDataModel({
    this.id,
    required this.notificationId,
    required this.parentId,
    required this.title,
  });

  NotificationDataModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        notificationId = data['notification_id'],
        parentId = data['parent_id'],
        title = data['title'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'title': title,
      'notification_id': notificationId,
    };
  }
}
