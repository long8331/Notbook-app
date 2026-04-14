import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';
import 'package:todo_list_app/presentation/widgets/edit_note_screen.dart';

class NoteCard extends ConsumerWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = Color(note.color);
    // Chọn màu chữ tương phản với màu nền
    final textColor = bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
        );
      },
      onLongPress: () => _showDeleteDialog(context, ref),
      child: Card(
        color: bgColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: note.isPinned
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  _extractPlainText(note.content),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse Quill Delta JSON → plain text để hiện preview
  String _extractPlainText(String jsonContent) {
    try {
      final List<dynamic> ops = jsonDecode(jsonContent) as List<dynamic>;
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map && op['insert'] is String) {
          buffer.write(op['insert'] as String);
        }
      }
      final text = buffer.toString().trim();
      return text.isEmpty ? 'Không có nội dung' : text;
    } catch (_) {
      return jsonContent.isNotEmpty ? jsonContent : 'Không có nội dung';
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá ghi chú?'),
        content: Text('Bạn có chắc muốn xoá "${note.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(noteRepositoryProvider).deleteNote(note.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

