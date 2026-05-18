import 'package:firebase_database/firebase_database.dart';
import '../models/course.dart';
import '../models/note.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> addCourse(String name, String lecturer) async {
    await _db.child('courses').push().set({
      'name': name,
      'lecturer': lecturer,
    });
  }

  Stream<List<Course>> getCourses() {
    return _db.child('courses').onValue.map((event) {
      List<Course> courses = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map;
        data.forEach((key, value) {
          courses.add(Course.fromMap(key, value));
        });
      }
      return courses;
    });
  }

  Future<void> addNote(
    String courseId,
    String courseName,
    String title,
    String content,
  ) async {
    await _db.child('notes').push().set({
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    await _db.child('notes/$id').update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteNote(String id) async {
    await _db.child('notes/$id').remove();
  }

  Stream<List<Note>> getNotes() {
    return _db.child('notes').onValue.map((event) {
      List<Note> notes = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map;
        data.forEach((key, value) {
          notes.add(Note.fromMap(key, value));
        });
      }
      notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notes;
    });
  }
}
