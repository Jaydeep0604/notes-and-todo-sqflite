import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_detail_screen.dart';

class OpenScheduleContainerWrapper extends StatelessWidget {
  const OpenScheduleContainerWrapper({
    required this.id,
    required this.onUpdate,
    required this.onDelete,
    required this.closedChild,
  });

  final int id;
  final void Function() onUpdate;
  final void Function() onDelete;
  final Widget closedChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return TodoDetailscreen(
          isUpdateTodo: true,
          id: id,
          onUpdate: onUpdate,
          onDelete: onDelete,
        );
      },
      openColor: theme.cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      closedElevation: 0,
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: () {
            openContainer();
          },
          child: closedChild,
        );
      },
    );
  }
}

// ignore: must_be_immutable
class OpenNoteContainerWrapper extends StatelessWidget {
  OpenNoteContainerWrapper({
    required this.id,
    required this.onUpdateComplete,
    required this.closedChild,
  });

  final int id;
  void Function() onUpdateComplete;
  final Widget closedChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return NoteDetailScreen(
          isUpdateNote: true,
          id: id,
        );
      },
      openColor: theme.cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      closedElevation: 0,
      closedColor: Colors.transparent,
      onClosed: (data) => onUpdateComplete(),
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: () {
            openContainer();
          },
          child: closedChild,
        );
      },
    );
  }
}
