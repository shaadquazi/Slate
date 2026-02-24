import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/add_edit_screen.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),

      direction: DismissDirection.horizontal,

      /// 👉 RIGHT swipe (progress)
      background: Builder(
        builder: (_) {
          IconData icon;

          switch (todo.status) {
            case Status.pending:
              icon = Icons.play_arrow;
              break;
            case Status.inProgress:
              icon = Icons.check;
              break;
            case Status.completed:
              icon = Icons.lock;
              break;
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.green,
            child: Icon(icon, color: Colors.white),
          );
        },
      ),

      /// 👉 LEFT swipe (delete)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        final provider = context.read<TodoProvider>();

        print(direction); // 👈 debug once

        /// RIGHT swipe → progress
        if (direction == DismissDirection.startToEnd) {
          final next = todo.status.next;

          if (next != null) {
            provider.updateStatus(todo, next);
          }

          return false; // keep tile
        }

        /// LEFT swipe → delete
        if (direction == DismissDirection.endToStart) {
          return true;
        }

        return false;
      },

      onDismissed: (_) {
        context.read<TodoProvider>().deleteTodo(todo);
      },

      child: _TodoContent(todo: todo),
    );
  }
}

class _TodoContent extends StatefulWidget {
  final Todo todo;

  const _TodoContent({required this.todo});

  @override
  State<_TodoContent> createState() => _TodoContentState();
}

class _TodoContentState extends State<_TodoContent> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final desc = widget.todo.description;
    final maxDescriptionLength = 20;

    return ListTile(
      title: Text(widget.todo.title),
      subtitle: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: () => setState(() => expanded = false),
                  child: Text(
                    'less',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          /// ✅ Collapsed → inline layout
          : RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: desc.length > maxDescriptionLength
                        ? '${desc.substring(0, maxDescriptionLength)}... '
                        : desc,
                  ),

                  if (desc.length > maxDescriptionLength)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => setState(() => expanded = true),
                        child: Text(
                          'more',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditScreen(todo: widget.todo)),
        );
      },
    );
  }
}
