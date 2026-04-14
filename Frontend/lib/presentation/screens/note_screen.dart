import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';
import 'package:todo_list_app/presentation/widgets/empty_state.dart';
import 'package:todo_list_app/presentation/widgets/note_card.dart';
import 'package:todo_list_app/presentation/widgets/edit_note_screen.dart';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm ghi chú...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              )
            : const Text('Ghi chú'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          // Lọc theo search query
          final filtered = _searchQuery.isEmpty
              ? notes
              : notes.where((n) {
                  return n.title.toLowerCase().contains(_searchQuery) ||
                      n.content.toLowerCase().contains(_searchQuery);
                }).toList();

          if (filtered.isEmpty) {
            return EmptyState(
              title: _searchQuery.isEmpty ? 'Chưa có ghi chú nào' : 'Không tìm thấy kết quả',
              subtitle: _searchQuery.isEmpty
                  ? 'Hãy nhấn nút + để tạo ghi chú đầu tiên.'
                  : 'Thử tìm với từ khoá khác.',
              icon: _searchQuery.isEmpty ? Icons.note_add : Icons.search_off,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return NoteCard(note: filtered[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
