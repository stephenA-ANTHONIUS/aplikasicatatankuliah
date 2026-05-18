import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? noteToEdit;

  AddNoteScreen({this.noteToEdit});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;

  bool get isEdit => widget.noteToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
    }
    _loadCourses();
  }

  void _loadCourses() {
    _dbService.getCourses().listen((courses) {
      if (mounted) {
        setState(() {
          _courses = courses;
          if (isEdit && _selectedCourse == null) {
            try {
              _selectedCourse = courses.firstWhere(
                (c) => c.id == widget.noteToEdit!.courseId,
              );
            } catch (_) {}
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih mata kuliah terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (isEdit) {
      await _dbService.updateNote(
        widget.noteToEdit!.id,
        _titleController.text.trim(),
        _contentController.text.trim(),
      );
    } else {
      await _dbService.addNote(
        _selectedCourse!.id,
        _selectedCourse!.name,
        _titleController.text.trim(),
        _contentController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Catatan berhasil diperbarui' : 'Catatan berhasil disimpan'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mata Kuliah',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 6),
              DropdownButtonFormField<Course>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pilih mata kuliah',
                ),
                items: _courses.map((course) {
                  return DropdownMenuItem<Course>(
                    value: course,
                    child: Text(course.name),
                  );
                }).toList(),
                onChanged: isEdit
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCourse = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih mata kuliah';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Judul Catatan',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan judul catatan',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Isi Catatan',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tulis isi catatan di sini...',
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _simpan,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Perbarui Catatan' : 'Simpan Catatan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
