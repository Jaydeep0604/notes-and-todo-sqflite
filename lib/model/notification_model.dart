class NotificationDataModel {
  final int? id;
  final int? notificationId;
  final int? parentId;
  final String? region;
  final String? title;

  NotificationDataModel({
    this.id,
    required this.notificationId,
    required this.parentId,
    required this.region,
    required this.title,
  });

  NotificationDataModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        notificationId = data['notification_id'],
        parentId = data['parent_id'],
        region = data['region'],
        title = data['title'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'title': title,
       'region': region,
      'notification_id': notificationId,
    };
  }
}
