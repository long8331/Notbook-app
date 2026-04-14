import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  late QuillController _controller;
  final _titleController = TextEditingController();
  late Color _selectedColor;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.note?.isPinned ?? false;
    _selectedColor = Color(widget.note?.color ?? 0xFFFFFFFF);
    _titleController.text = widget.note?.title ?? '';
    
    if (widget.note != null) {
      final doc = Document.fromJson(jsonDecode(widget.note!.content));
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.note == null ? 'Ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: _pickColor,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Tiêu đề',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _controller,
                config: const QuillEditorConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor() async {
    final Color newColor = await showColorPickerDialog(
      context,
      _selectedColor,
      title: const Text('Chọn màu ghi chú'),
      width: 40,
      height: 40,
      spacing: 10,
      runSpacing: 10,
      borderRadius: 20,
      wheelDiameter: 165,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
      ),
    );
    setState(() => _selectedColor = newColor);
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _controller.document.isEmpty()) {
      Navigator.pop(context);
      return;
    }

    final content = jsonEncode(_controller.document.toDelta().toJson());
    
    if (widget.note == null) {
      await ref.read(noteRepositoryProvider).addNote(
            NotesCompanion(
              title: drift.Value(_titleController.text.isEmpty ? 'Không tiêu đề' : _titleController.text),
              content: drift.Value(content),
              color: drift.Value(_selectedColor.toARGB32()),
              isPinned: drift.Value(_isPinned),
            ),
          );
    } else {
      await ref.read(noteRepositoryProvider).updateNote(
            widget.note!.copyWith(
              title: _titleController.text,
              content: content,
              color: _selectedColor.toARGB32(),
              isPinned: _isPinned,
              updatedAt: DateTime.now(),
            ),
          );
    }

    if (mounted) Navigator.pop(context);
  }
}
