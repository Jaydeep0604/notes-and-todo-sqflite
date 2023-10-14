class TodoModel {
  int? id;
  String todo;
  int finished;
  String dueDate;
  String dueTime;
  String category;

  TodoModel({
    this.id,
    required this.todo,
    required this.finished,
    required this.dueDate,
    required this.dueTime,
    required this.category,
  });

  TodoModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        todo = data['todo'],
        finished = data['finished'],
        dueDate = data['due_date'],
        dueTime = data['due_time'],
        category = data['category'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'todo': todo,
      'finished': finished,
      'due_date': dueDate,
      'due_time': dueTime,
      'category': category
    };
  }
}
