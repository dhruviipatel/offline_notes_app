import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../databases/hive_database.dart';
import '../models/note_model.dart';

final noteProvider = NotifierProvider<NoteController, List<NoteModel>>(
  NoteController.new,
);

class NoteController extends Notifier<List<NoteModel>> {
  final uuid = const Uuid();

  @override
  List<NoteModel> build() {
    return loadNotes();
  }

  // Load notes from Hive
  List<NoteModel> loadNotes() {
    final box = HiveDatabase.notesBox;

    final notes = box.values.map((item) {
      return NoteModel.fromMap(item);
    }).toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return notes;
  }

  // Refresh notes
  void refreshNotes() {
    state = loadNotes();
  }

  // Add new note
  Future<void> addNote(String title, String description) async {
    final now = DateTime.now();

    final note = NoteModel(
      id: uuid.v4(),
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
    );

    await HiveDatabase.notesBox.put(note.id, note.toMap());

    refreshNotes();
  }

  // Update existing note
  Future<void> updateNote(
    NoteModel note,
    String title,
    String description,
  ) async {
    final updatedNote = NoteModel(
      id: note.id,
      title: title,
      description: description,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    await HiveDatabase.notesBox.put(note.id, updatedNote.toMap());

    refreshNotes();
  }

  // Delete note
  Future<void> deleteNote(String id) async {
    await HiveDatabase.notesBox.delete(id);

    refreshNotes();
  }
}
