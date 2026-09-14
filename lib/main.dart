import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jay Shree Ram Computer Center',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
      ),
      home: const AdminLoginPage(),
    );
  }
}

class StudyMaterialManagementPage extends StatefulWidget {
  const StudyMaterialManagementPage({super.key});

  @override
  State<StudyMaterialManagementPage> createState() =>
      _StudyMaterialManagementPageState();
}

class _StudyMaterialManagementPageState
    extends State<StudyMaterialManagementPage> {
  static const String _storageKey = 'jsrc_study_material_records';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  List<Map<String, dynamic>> _materials = [];

  String _searchText = '';
  String _selectedFilter = 'All';
  String _selectedType = 'Video';

  final List<String> _types = ['Video', 'Audio', 'PDF', 'Online Link'];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved == null || saved.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(saved);

      if (decoded is List) {
        setState(() {
          _materials = decoded
              .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        });
      }
    } catch (_) {
      // Ignore corrupted old data.
    }
  }

  Future<void> _saveMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_materials));
  }

  void _clearForm() {
    _titleController.clear();
    _courseController.clear();
    _descriptionController.clear();
    _urlController.clear();

    setState(() {
      _selectedType = 'Video';
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final record = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text.trim(),
      'course': _courseController.text.trim(),
      'description': _descriptionController.text.trim(),
      'url': _urlController.text.trim(),
      'type': _selectedType,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _materials.insert(0, record);
    });

    await _saveMaterials();
    _clearForm();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study Material saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _editRecord(Map<String, dynamic> material) async {
    _titleController.text = material['title']?.toString() ?? '';
    _courseController.text = material['course']?.toString() ?? '';
    _descriptionController.text = material['description']?.toString() ?? '';
    _urlController.text = material['url']?.toString() ?? '';

    final oldType = material['type']?.toString() ?? 'Video';

    setState(() {
      _selectedType = _types.contains(oldType) ? oldType : 'Video';
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildEditSheet(material),
        );
      },
    );
  }

  Widget _buildEditSheet(Map<String, dynamic> material) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: SingleChildScrollView(
        child: Form(
          key: GlobalKey<FormState>(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Edit Study Material',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              _inputField(
                controller: _titleController,
                label: 'Material Title',
                icon: Icons.title,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _courseController,
                label: 'Course Name',
                icon: Icons.school,
              ),

              const SizedBox(height: 12),

              _typeDropdown(),

              const SizedBox(height: 12),

              _inputField(
                controller: _urlController,
                label: _urlLabel(),
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                required: false,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty ||
                        _courseController.text.trim().isEmpty ||
                        _urlController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }

                    final index = _materials.indexWhere(
                      (item) =>
                          item['id'].toString() == material['id'].toString(),
                    );

                    if (index != -1) {
                      setState(() {
                        _materials[index] = {
                          ..._materials[index],
                          'title': _titleController.text.trim(),
                          'course': _courseController.text.trim(),
                          'description': _descriptionController.text.trim(),
                          'url': _urlController.text.trim(),
                          'type': _selectedType,
                        };
                      });

                      await _saveMaterials();
                    }

                    if (!mounted) return;

                    Navigator.pop(context);
                    _clearForm();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Study Material updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Update Record',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(int index) async {
    final material = _filteredMaterials[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Material?'),
          content: Text(
            'Are you sure you want to delete "${material['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final actualIndex = _materials.indexWhere(
      (item) => item['id'].toString() == material['id'].toString(),
    );

    if (actualIndex != -1) {
      setState(() {
        _materials.removeAt(actualIndex);
      });

      await _saveMaterials();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openMaterial(Map<String, dynamic> material) async {
    final urlText = material['url']?.toString().trim() ?? '';

    if (urlText.isEmpty) {
      return;
    }

    Uri? uri;

    try {
      uri = Uri.parse(urlText);
    } catch (_) {
      uri = null;
    }

    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid http/https link'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyLink(Map<String, dynamic> material) async {
    final url = material['url']?.toString() ?? '';

    if (url.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredMaterials {
    return _materials.where((material) {
      final title = material['title']?.toString().toLowerCase() ?? '';
      final course = material['course']?.toString().toLowerCase() ?? '';
      final type = material['type']?.toString() ?? '';

      final matchesSearch =
          title.contains(_searchText.toLowerCase()) ||
          course.contains(_searchText.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' || type == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _urlLabel() {
    switch (_selectedType) {
      case 'Video':
        return 'Video URL / YouTube Link';
      case 'Audio':
        return 'Audio URL / MP3 Link';
      case 'PDF':
        return 'PDF URL';
      default:
        return 'Online Study URL';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Video':
        return Icons.play_circle_fill;
      case 'Audio':
        return Icons.headphones;
      case 'PDF':
        return Icons.picture_as_pdf;
      default:
        return Icons.language;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Video':
        return Colors.red;
      case 'Audio':
        return Colors.deepPurple;
      case 'PDF':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _typeHindi(String type) {
    switch (type) {
      case 'Video':
        return 'वीडियो';
      case 'Audio':
        return 'ऑडियो';
      case 'PDF':
        return 'PDF नोट्स';
      default:
        return 'ऑनलाइन लिंक';
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.orange.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.orange.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: _inputDecoration('Material Type', Icons.category),
      items: _types.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(_typeIcon(type), color: _typeColor(type), size: 21),
              const SizedBox(width: 10),
              Text('$type (${_typeHindi(type)})'),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  Widget _buildAddMaterialForm() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Add Study Material',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: _titleController,
                label: 'Material Title',
                icon: Icons.title,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _courseController,
                label: 'Course Name',
                icon: Icons.school,
              ),

              const SizedBox(height: 12),

              _typeDropdown(),

              const SizedBox(height: 12),

              _inputField(
                controller: _urlController,
                label: _urlLabel(),
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                required: false,
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveRecord,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Record',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search material or course...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchText = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Video', 'Audio', 'PDF', 'Online Link'].map((
                filter,
              ) {
                final selected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      filter == 'All'
                          ? 'All'
                          : '$filter (${_materials.where((m) => m['type'] == filter).length})',
                    ),
                    selected: selected,
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material, int index) {
    final title = material['title']?.toString() ?? '';
    final course = material['course']?.toString() ?? '';
    final type = material['type']?.toString() ?? 'Online Link';
    final description = material['description']?.toString() ?? '';
    final url = material['url']?.toString() ?? '';

    final typeColor = _typeColor(type);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_typeIcon(type), color: typeColor, size: 30),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editRecord(material);
                    } else if (value == 'delete') {
                      _deleteRecord(index);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$type • ${_typeHindi(type)}',
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openMaterial(material),
                    icon: Icon(
                      type == 'Video'
                          ? Icons.play_arrow
                          : type == 'Audio'
                          ? Icons.headphones
                          : type == 'PDF'
                          ? Icons.picture_as_pdf
                          : Icons.open_in_new,
                    ),
                    label: Text(
                      type == 'Video'
                          ? 'Watch Video'
                          : type == 'Audio'
                          ? 'Play Audio'
                          : type == 'PDF'
                          ? 'Open PDF'
                          : 'Open Link',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Copy Link',
                  onPressed: () => _copyLink(material),
                  icon: const Icon(Icons.copy),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 15),
          const Text(
            'No Study Material Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Video, Audio, PDF या Online Study Link',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMaterials;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,

      appBar: AppBar(
        title: const Text(
          'Study Material',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 3,
      ),

      body: SafeArea(
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.white, size: 42),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JSRC Digital Study Material',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Video • Audio • PDF • Online Learning',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildAddMaterialForm(),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Saved Materials: ${_materials.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            _buildSearchAndFilter(),

            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ...filtered.asMap().entries.map((entry) {
                return _buildMaterialCard(entry.value, entry.key);
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: () {
          _clearForm();

          Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 400),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  static const String adminUsernameKey = 'jsrc_admin_username';
  static const String adminPasswordKey = 'jsrc_admin_password';

  static const String loginAttemptsKey = 'jsrc_login_attempts';
  static const String lockUntilKey = 'jsrc_login_lock_until';

  static const String defaultAdminUsername = 'admin';
  static const String defaultAdminPassword = '123456';

  static const FlutterSecureStorage secureStorage =
      FlutterSecureStorage();

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final secure = AdminLoginPage.secureStorage;

      final lockValue = await secure.read(
        key: AdminLoginPage.lockUntilKey,
      );

      final lockUntil =
          int.tryParse(lockValue ?? '') ?? 0;

      if (lockUntil > DateTime.now().millisecondsSinceEpoch) {
        final seconds = ((lockUntil -
                    DateTime.now().millisecondsSinceEpoch) /
                1000)
            .ceil();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Too many failed attempts. Try again in $seconds seconds.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? savedUsername = await secure.read(
        key: AdminLoginPage.adminUsernameKey,
      );

      String? savedPassword = await secure.read(
        key: AdminLoginPage.adminPasswordKey,
      );

      // Automatic migration from old SharedPreferences storage.
      if (savedUsername == null || savedPassword == null) {
        final prefs = await SharedPreferences.getInstance();

        savedUsername =
            prefs.getString(AdminLoginPage.adminUsernameKey) ??
                AdminLoginPage.defaultAdminUsername;

        savedPassword =
            prefs.getString(AdminLoginPage.adminPasswordKey) ??
                AdminLoginPage.defaultAdminPassword;

        await secure.write(
          key: AdminLoginPage.adminUsernameKey,
          value: savedUsername,
        );

        await secure.write(
          key: AdminLoginPage.adminPasswordKey,
          value: savedPassword,
        );

        await prefs.remove(AdminLoginPage.adminUsernameKey);
        await prefs.remove(AdminLoginPage.adminPasswordKey);
      }

      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      if (username == savedUsername && password == savedPassword) {
        await secure.delete(key: AdminLoginPage.loginAttemptsKey);
        await secure.delete(key: AdminLoginPage.lockUntilKey);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardPage(),
          ),
        );
      } else {
        final attemptsValue = await secure.read(
          key: AdminLoginPage.loginAttemptsKey,
        );

        final attempts =
            (int.tryParse(attemptsValue ?? '') ?? 0) + 1;

        if (attempts >= 5) {
          final lockTime =
              DateTime.now()
                  .add(const Duration(seconds: 30))
                  .millisecondsSinceEpoch;

          await secure.write(
            key: AdminLoginPage.lockUntilKey,
            value: lockTime.toString(),
          );

          await secure.delete(
            key: AdminLoginPage.loginAttemptsKey,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '5 failed attempts. Login locked for 30 seconds.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          await secure.write(
            key: AdminLoginPage.loginAttemptsKey,
            value: attempts.toString(),
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid Admin ID or Password. '
                'Attempt $attempts of 5.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Secure login error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange, Color(0xFFFF8F00), Colors.white],
            stops: [0.0, 0.45, 0.9],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 55,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'ADMIN LOGIN',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Jay Shree Ram Computer Center',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                        const SizedBox(height: 28),

                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Admin ID',
                            hintText: 'Enter Admin ID',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter Admin ID';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _login,
                            icon: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              _loading ? 'Logging in...' : 'ADMIN LOGIN',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Secure Administration Panel',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}



class DocumentManagementPage extends StatefulWidget {
  const DocumentManagementPage({super.key});

  @override
  State<DocumentManagementPage> createState() =>
      _DocumentManagementPageState();
}

class _DocumentManagementPageState extends State<DocumentManagementPage> {
  final List<Map<String, dynamic>> _documents = [];
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('jsrc_documents') ?? [];

    if (!mounted) return;

    setState(() {
      _documents.clear();

      for (final item in saved) {
        try {
          final parts = item.split('|||');

          if (parts.length >= 5) {
            _documents.add({
              'name': parts[0],
              'path': parts[1],
              'size': int.tryParse(parts[2]) ?? 0,
              'extension': parts[3],
              'date': parts[4],
            });
          }
        } catch (_) {}
      }
    });
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _documents.map((doc) {
      return [
        doc['name'] ?? '',
        doc['path'] ?? '',
        doc['size'] ?? 0,
        doc['extension'] ?? '',
        doc['date'] ?? '',
      ].join('|||');
    }).toList();

    await prefs.setStringList('jsrc_documents', data);
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx',
          'xls',
          'xlsx',
        ],
      );

      if (!mounted || result == null) return;

      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';

      setState(() {
        for (final file in result.files) {
          _documents.insert(0, {
            'name': file.name,
            'path': file.path ?? '',
            'size': file.size,
            'extension': file.extension ?? '',
            'date': date,
          });
        }
      });

      await _saveDocuments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.files.length} document(s) added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDocument(int index) async {
    final name = _documents[index]['name'] ?? 'Document';

    setState(() {
      _documents.removeAt(index);
    });

    await _saveDocuments();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatSize(dynamic value) {
    final size = value is int ? value : 0;

    if (size < 1024) {
      return '$size B';
    }

    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }

    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _documentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  List<Map<String, dynamic>> get _filteredDocuments {
    if (_searchQuery.isEmpty) {
      return _documents;
    }

    return _documents.where((doc) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      final extension =
          (doc['extension'] ?? '').toString().toLowerCase();

      return name.contains(_searchQuery) ||
          extension.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final documents = _filteredDocuments;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _pickDocuments,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Add Document',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDocuments,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.orange.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade700,
                  Colors.orange.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_copy,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Documents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_documents.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: documents.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_copy,
                            size: 85,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _documents.isEmpty
                                ? 'No Documents Added'
                                : 'No Documents Found',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PDF, Word, Excel और image documents यहाँ manage करें.',
                            textAlign: TextAlign.center,
                          ),
                          if (_documents.isEmpty) ...[
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              onPressed: _pickDocuments,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Select Documents'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      90,
                    ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];

                      final name =
                          document['name'] ?? 'Document';

                      final extension =
                          (document['extension'] ?? '').toString();

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Colors.orange.shade50,
                            child: Icon(
                              _documentIcon(extension),
                              color: Colors.orange,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${extension.toUpperCase()} • '
                            '${_formatSize(document['size'])}\n'
                            'Added: ${document['date'] ?? '-'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              final actualIndex =
                                  _documents.indexOf(document);

                              if (actualIndex != -1) {
                                _deleteDocument(actualIndex);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<DashboardItem> items = const [
    DashboardItem(
      title: 'Students',
      subtitle: 'Student Management',
      icon: Icons.people_alt,
    ),
    DashboardItem(
      title: 'Admission',
      subtitle: 'New Admission',
      icon: Icons.person_add,
    ),
    DashboardItem(
      title: 'Fees',
      subtitle: 'Fees Management',
      icon: Icons.currency_rupee,
    ),
    DashboardItem(
      title: 'Courses',
      subtitle: 'All Courses',
      icon: Icons.menu_book,
    ),
    DashboardItem(
      title: 'Staff',
      subtitle: 'Staff Management',
      icon: Icons.badge,
    ),
    DashboardItem(
      title: 'Study Material',
      subtitle: 'Notes & Materials',
      icon: Icons.library_books,
    ),
    DashboardItem(
      title: 'Document',
      subtitle: 'Document Management',
      icon: Icons.folder_copy,
    ),
    DashboardItem(
      title: 'Certificates',
      subtitle: 'Student Certificates',
      icon: Icons.workspace_premium,
    ),
    DashboardItem(
      title: 'QR Scanner',
      subtitle: 'Scan QR Code',
      icon: Icons.qr_code_scanner,
    ),
    DashboardItem(
      title: 'Location',
      subtitle: 'Center Location',
      icon: Icons.location_on,
    ),
    DashboardItem(
      title: 'Biometric Attendance',
      subtitle: 'Face + Eye Blink',
      icon: Icons.face_retouching_natural,
    ),
    DashboardItem(
      title: 'Receipt Management',
      subtitle: 'Create & Manage Receipts',
      icon: Icons.receipt_long,
    ),
    DashboardItem(
      title: 'Reports',
      subtitle: 'View Reports',
      icon: Icons.bar_chart,
    ),
    DashboardItem(
      title: 'Settings',
      subtitle: 'Application Settings',
      icon: Icons.settings,
    ),
  ];
  void openFeature(DashboardItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (item.title == 'Students') {
            return const StudentListPage();
          }

          if (item.title == 'Admission') {
            return const StudentProfilePage();
          }

          if (item.title == 'Biometric Attendance') {
            return const AttendancePage();
          }

          if (item.title == 'Fees') {
            return const FeesManagementPage();
          }

          if (item.title == 'Staff') {
            return const StaffManagementPage();
          }

          if (item.title == 'Study Material') {
            return const StudyMaterialManagementPage();
          }

          if (item.title == 'Receipt Management') {
            return const ReceiptManagementPage();
          }

        if (item.title == 'Document') {
          return const DocumentManagementPage();
        }

          if (item.title == 'Reports') {
            return const ReportsManagementPage();
          }

          if (item.title == 'Admin Profile') {
            return const AdminProfilePage();
          }

          if (item.title == 'Settings') {
            return const SettingsPage();
          }

          if (item.title == 'Courses') {
            return const CoursesManagementPage();
          }

          if (item.title == 'Certificates') {
            return const CertificatesManagementPage();
          }

          if (item.title == 'QR Scanner') {
            return const QrScannerPage();
          }

          if (item.title == 'Location') {
            return const CenterLocationPage();
          }

          return FeaturePage(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/icon/jay_shree_ram_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          'Jay Shree Ram Computer Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              openFeature(
                const DashboardItem(
                  title: 'Admin Profile',
                  subtitle: 'Administrator Account',
                  icon: Icons.account_circle,
                ),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              setState(() {});
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _welcomeCard(),
              const SizedBox(height: 18),
              _statistics(),
              const SizedBox(height: 22),
              const Text(
                'Quick Access',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _featureGrid(),
              const SizedBox(height: 22),
              _recentActivity(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            openFeature(
              const DashboardItem(
                title: 'Students',
                subtitle: 'Student Management',
                icon: Icons.people_alt,
              ),
            );
          }

          if (index == 2) {
            openFeature(
              const DashboardItem(
                title: 'Reports',
                subtitle: 'View Reports',
                icon: Icons.bar_chart,
              ),
            );
          }

          if (index == 3) {
            openFeature(
              const DashboardItem(
                title: 'Settings',
                subtitle: 'Application Settings',
                icon: Icons.settings,
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Colors.orange, Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.computer, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Admin 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Jay Shree Ram Computer Center',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage your center from one place',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistics() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _statCard('Total Students', '248', Icons.people, Colors.blue),
        _statCard('Present Today', '186', Icons.how_to_reg, Colors.green),
        _statCard(
          'Pending Fees',
          '₹24,500',
          Icons.account_balance_wallet,
          Colors.red,
        ),
        _statCard('Courses', '12', Icons.menu_book, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openFeature(item),
          child: Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(item.icon, color: Colors.orange.shade800, size: 23),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _recentActivity() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _activity(
              Icons.person_add,
              'New student admitted',
              'Today, 10:30 AM',
            ),
            _activity(
              Icons.currency_rupee,
              'Fee payment received',
              'Today, 11:15 AM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _activity(IconData icon, String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withValues(alpha: 0.12),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Color(0xFFFF8F00)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.computer, color: Colors.orange, size: 38),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'JAY SHREE RAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Computer Center',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Students'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[0]);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Admission'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[1]);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.currency_rupee),
                  title: const Text('Fees'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[3]);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('Courses'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[4]);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[11]);
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Jay Shree Ram Computer Center\nAdmin Dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const FeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(icon, size: 44, color: Colors.orange),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _actionCard(
            context,
            'Add New',
            'Create a new record',
            Icons.add_circle,
          ),
          _actionCard(context, 'View List', 'View all records', Icons.list_alt),
          _actionCard(context, 'Search', 'Search records', Icons.search),
          _actionCard(context, 'Reports', 'Generate reports', Icons.analytics),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData actionIcon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.12),
          child: Icon(actionIcon, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title option opened'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class Student {
  String studentName;
  String fatherName;
  String motherName;
  String mobile;
  String email;
  String dob;
  String gender;
  String address;
  String city;
  String state;
  String? signaturePath;
  String pincode;
  String course;
  String admissionNo;
  String rollNo;
  String? photoPath;

  Student({
    required this.studentName,
    required this.fatherName,
    required this.motherName,
    required this.mobile,
    required this.email,
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    this.signaturePath,
    required this.pincode,
    required this.course,
    required this.admissionNo,
    required this.rollNo,
    this.photoPath,
  });
}

final List<Student> students = [];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class StudentProfilePage extends StatefulWidget {
  final Student? student;
  final int? index;

  const StudentProfilePage({super.key, this.student, this.index});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class ReceiptManagementPage extends StatefulWidget {
  const ReceiptManagementPage({super.key});

  @override
  State<ReceiptManagementPage> createState() => _ReceiptManagementPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool biometricAttendance = true;
  bool autoBackup = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.settings, color: Colors.orange, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Jay Shree Ram Computer Center',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle('General Settings'),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Enable application notifications'),
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Attendance'),
              subtitle: const Text('Face & eye blink verification'),
              value: biometricAttendance,
              onChanged: (value) {
                setState(() {
                  biometricAttendance = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.backup_outlined),
              title: const Text('Automatic Backup'),
              subtitle: const Text('Automatically backup application data'),
              value: autoBackup,
              onChanged: (value) {
                setState(() {
                  autoBackup = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark appearance'),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Dark Mode enabled' : 'Dark Mode disabled',
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 18),

          _sectionTitle('Center Information'),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Center Name'),
                  subtitle: Text('Jay Shree Ram Computer Center'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Location'),
                  subtitle: Text('Chhindwara, Madhya Pradesh'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Computer Center'),
                  subtitle: Text('Computer Education & Training Center'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _sectionTitle('Data Management'),

          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data'),
              subtitle: const Text('Create a backup of application data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup feature ready')),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Data'),
              subtitle: const Text('Restore previously saved data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore feature ready')),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          _sectionTitle('About'),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About JSRC'),
                  subtitle: const Text('Jay Shree Ram Computer Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Jay Shree Ram Computer Center',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          'Computer Education & Training Center',
                    );
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.verified),
                  title: Text('Application Version'),
                  subtitle: Text('Version 1.0.0'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'Back to Dashboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final formKey = GlobalKey<FormState>();

  final studentName = TextEditingController();
  final fatherName = TextEditingController();
  final motherName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final dob = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  String? signaturePath;
  final course = TextEditingController();
  final admissionNo = TextEditingController();
  final rollNo = TextEditingController();
  String gender = 'Male';

  File? selectedPhoto;
  File? selectedSignature;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickSignature() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      setState(() {
        selectedSignature = File(image.path);
        signaturePath = image.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final s = widget.student;

    if (s != null) {
      studentName.text = s.studentName;
      fatherName.text = s.fatherName;
      motherName.text = s.motherName;
      mobile.text = s.mobile;
      email.text = s.email;
      dob.text = s.dob;
      address.text = s.address;
      city.text = s.city;
      state.text = s.state;
      pincode.text = s.pincode;
      course.text = s.course;
      admissionNo.text = s.admissionNo;
      rollNo.text = s.rollNo;
      gender = s.gender;
      signaturePath = s.signaturePath;

      if (s.photoPath != null && s.photoPath!.isNotEmpty) {
        selectedPhoto = File(s.photoPath!);
      }
    }
  }

  @override
  void dispose() {
    studentName.dispose();
    fatherName.dispose();
    motherName.dispose();
    mobile.dispose();
    email.dispose();
    dob.dispose();
    address.dispose();
    city.dispose();
    state.dispose();
    pincode.dispose();
    course.dispose();
    admissionNo.dispose();
    rollNo.dispose();
    super.dispose();
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: decoration(label, icon),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> pickStudentPhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null && mounted) {
      setState(() {
        selectedPhoto = File(picked.path);
      });
    }
  }

  void saveStudent() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final newStudent = Student(
      studentName: studentName.text.trim(),
      fatherName: fatherName.text.trim(),
      motherName: motherName.text.trim(),
      mobile: mobile.text.trim(),
      email: email.text.trim(),
      dob: dob.text.trim(),
      gender: gender,
      address: address.text.trim(),
      city: city.text.trim(),
      state: state.text.trim(),
      pincode: pincode.text.trim(),
      course: course.text.trim(),
      admissionNo: admissionNo.text.trim(),
      rollNo: rollNo.text.trim(),
      photoPath: selectedPhoto?.path,
      signaturePath: signaturePath,
    );

    if (widget.index != null) {
      students[widget.index!] = newStudent;
    } else {
      students.add(newStudent);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.index != null
              ? 'Student updated successfully'
              : 'Student added successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  void deleteStudent() {
    final index = widget.index;

    if (index == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: const Text(
            'Kya aap is student ko delete karna chahte hain?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                students.removeAt(index);

                Navigator.pop(dialogContext);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student deleted successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  void clearForm() {
    studentName.clear();
    fatherName.clear();
    motherName.clear();
    mobile.clear();
    email.clear();
    dob.clear();
    address.clear();
    city.clear();
    state.clear();
    pincode.clear();
    course.clear();
    admissionNo.clear();
    rollNo.clear();

    setState(() {
      gender = 'Male';
      selectedPhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Student' : 'Add Student'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickStudentPhoto,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: selectedPhoto != null
                          ? FileImage(selectedPhoto!)
                          : null,
                      child: selectedPhoto == null
                          ? const Icon(
                              Icons.person,
                              size: 52,
                              color: Colors.orange,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: pickStudentPhoto,
                    icon: const Icon(Icons.photo_camera, color: Colors.white),
                    label: const Text(
                      'SELECT PHOTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'Student Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Jay Shree Ram Computer Center',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            field('Student Name', studentName, Icons.person),

            field('Father Name', fatherName, Icons.man),

            field('Mother Name', motherName, Icons.woman),

            field(
              'Mobile Number',
              mobile,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            field(
              'Email',
              email,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              requiredField: false,
            ),

            field('Date of Birth', dob, Icons.calendar_month),

            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: decoration('Gender', Icons.wc),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    gender = value;
                  });
                }
              },
            ),

            const SizedBox(height: 22),

            const Text(
              'Address Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            field('Address', address, Icons.home),

            field('City', city, Icons.location_city),

            field('State', state, Icons.map),

            field(
              'PIN Code',
              pincode,
              Icons.pin_drop,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 22),

            const Text(
              'Course & Admission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            field('Course', course, Icons.menu_book),

            field('Admission Number', admissionNo, Icons.confirmation_number),

            field('Roll Number', rollNo, Icons.badge),

            const SizedBox(height: 10),

            SizedBox(
              height: 54,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveStudent,
                icon: Icon(editing ? Icons.update : Icons.save),
                label: Text(
                  editing ? 'UPDATE STUDENT' : 'SAVE STUDENT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (editing) ...[
              const SizedBox(height: 12),

              SizedBox(
                height: 54,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You can edit the student details above'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'EDIT DETAILS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: deleteStudent,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'DELETE STUDENT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: clearForm,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Form'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentListPageState extends State<StudentListPage> {
  String search = '';

  List<Student> get filteredStudents {
    if (search.trim().isEmpty) {
      return students;
    }

    final q = search.toLowerCase();

    return students.where((student) {
      return student.studentName.toLowerCase().contains(q) ||
          student.mobile.toLowerCase().contains(q) ||
          student.admissionNo.toLowerCase().contains(q) ||
          student.course.toLowerCase().contains(q);
    }).toList();
  }

  void addStudent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentProfilePage()),
    );

    setState(() {});
  }

  void editStudent(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentProfilePage(student: students[index], index: index),
      ),
    );

    setState(() {});
  }

  void deleteStudent(int index) {
    final student = students[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student?'),
          content: Text('Delete ${student.studentName} from student list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  students.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted')),
                );
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  void viewStudent(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: ListView(
            shrinkWrap: true,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 45),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  student.studentName,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _detail('Father Name', student.fatherName),
              _detail('Mother Name', student.motherName),
              _detail('Mobile', student.mobile),
              _detail('Email', student.email),
              _detail('Date of Birth', student.dob),
              _detail('Gender', student.gender),
              _detail('Address', student.address),
              _detail('City', student.city),
              _detail('State', student.state),
              _detail('PIN Code', student.pincode),
              _detail('Course', student.course),
              _detail('Admission Number', student.admissionNo),
              _detail('Roll Number', student.rollNo),
            ],
          ),
        );
      },
    );
  }

  Widget _detail(String title, String value) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addStudent,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search name, mobile, admission no...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            search = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${students.length} Students',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          students.isEmpty
                              ? 'No students added yet'
                              : 'No student found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tap Add Student to create a profile'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: list.length,
                    itemBuilder: (context, position) {
                      final student = list[position];

                      final realIndex = students.indexOf(student);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          leading: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFFFE0B2),
                            child: Icon(Icons.person, color: Colors.orange),
                          ),

                          title: Text(
                            student.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(student.course),
                              Text('Admission: ${student.admissionNo}'),
                              Text('Mobile: ${student.mobile}'),
                            ],
                          ),

                          isThreeLine: true,

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'view') {
                                viewStudent(student);
                              }

                              if (value == 'edit') {
                                editStudent(realIndex);
                              }

                              if (value == 'delete') {
                                deleteStudent(realIndex);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: ListTile(
                                  leading: Icon(Icons.visibility),
                                  title: Text('View Profile'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),

                          onTap: () {
                            viewStudent(student);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  final List<Map<String, dynamic>> records = [];

  final nameController = TextEditingController();
  final idController = TextEditingController();
  final courseController = TextEditingController();
  final totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('jsrc_fee_records');

    if (data != null && data.isNotEmpty) {
      final decoded = jsonDecode(data);

      setState(() {
        records.clear();
        records.addAll(List<Map<String, dynamic>>.from(decoded));
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jsrc_fee_records', jsonEncode(records));
  }

  void _addStudent() {
    final name = nameController.text.trim();
    final studentId = idController.text.trim();
    final course = courseController.text.trim();
    final total = double.tryParse(totalController.text.trim());

    if (name.isEmpty ||
        studentId.isEmpty ||
        course.isEmpty ||
        total == null ||
        total <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('सभी जानकारी सही भरें')));
      return;
    }

    final installment = total / 12;

    final installments = List.generate(12, (index) {
      return {
        'month': 'Month ${index + 1}',
        'amount': installment,
        'paidAmount': 0.0,
        'status': 'Pending',
        'paidDate': '',
        'receiptNo': '',
      };
    });

    setState(() {
      records.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'studentName': name,
        'studentId': studentId,
        'course': course,
        'totalFees': total,
        'installmentAmount': installment,
        'admissionDate': DateTime.now().toIso8601String(),
        'installments': installments,
      });
    });

    _saveRecords();

    nameController.clear();
    idController.clear();
    courseController.clear();
    totalController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student Fees Record Save हो गया')),
    );
  }

  double _totalPaid(Map<String, dynamic> student) {
    final list = List<Map<String, dynamic>>.from(student['installments']);

    return list.fold<double>(
      0,
      (sum, item) => sum + ((item['paidAmount'] ?? 0) as num).toDouble(),
    );
  }

  Future<void> _payInstallment(Map<String, dynamic> student, int index) async {
    final amountController = TextEditingController();
    final receiptController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment - ${index + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Installment: ₹${(student['installments'][index]['amount'] as num).toStringAsFixed(0)}',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Paid Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiptController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final paid = double.tryParse(amountController.text.trim());

                if (paid == null || paid <= 0) {
                  return;
                }

                final installment =
                    (student['installments'][index]['amount'] as num)
                        .toDouble();

                setState(() {
                  student['installments'][index]['paidAmount'] = paid;
                  student['installments'][index]['status'] = paid >= installment
                      ? 'Paid'
                      : 'Partial';
                  student['installments'][index]['paidDate'] = DateTime.now()
                      .toIso8601String();
                  student['installments'][index]['receiptNo'] =
                      receiptController.text.trim();
                });

                _saveRecords();
                Navigator.pop(context);
              },
              child: const Text('Save Payment'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(int index) {
    setState(() {
      records.removeAt(index);
    });

    _saveRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text(
                    'Add Student Fees',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Fees',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _addStudent,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Fees Record'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('अभी कोई Fees Record नहीं है')),
              ),
            ),

          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;

            final total = (student['totalFees'] as num).toDouble();
            final paid = _totalPaid(student);
            final pending = total - paid;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  student['studentName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${student['course']} • ${student['studentId']}',
                ),
                children: [
                  ListTile(
                    title: const Text('Total Fees'),
                    trailing: Text('₹${total.toStringAsFixed(0)}'),
                  ),
                  ListTile(
                    title: const Text('Total Paid'),
                    trailing: Text('₹${paid.toStringAsFixed(0)}'),
                  ),
                  ListTile(
                    title: const Text('Pending'),
                    trailing: Text('₹${pending.toStringAsFixed(0)}'),
                  ),

                  const Divider(),

                  ...List.generate(12, (monthIndex) {
                    final installment = student['installments'][monthIndex];

                    final amount = (installment['amount'] as num).toDouble();

                    final paidAmount = (installment['paidAmount'] as num)
                        .toDouble();

                    final status = installment['status'] ?? 'Pending';

                    return ListTile(
                      leading: CircleAvatar(child: Text('${monthIndex + 1}')),
                      title: Text(
                        '${installment['month']} - ₹${amount.toStringAsFixed(0)}',
                      ),
                      subtitle: Text(
                        'Paid: ₹${paidAmount.toStringAsFixed(0)} • $status',
                      ),
                      trailing: status == 'Paid'
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(
                                Icons.payment,
                                color: Colors.orange,
                              ),
                              onPressed: () =>
                                  _payInstallment(student, monthIndex),
                            ),
                    );
                  }),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteStudent(index),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Record'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    courseController.dispose();
    totalController.dispose();
    super.dispose();
  }
}

class _ReceiptManagementPageState extends State<ReceiptManagementPage> {
  final studentController = TextEditingController();
  final courseController = TextEditingController();
  final amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  final List<Map<String, String>> receipts = [];

  void saveReceipt() {
    if (studentController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final receiptNumber =
        'RCP-${(receipts.length + 1).toString().padLeft(3, '0')}';

    setState(() {
      receipts.add({
        'receipt': receiptNumber,
        'student': studentController.text.trim(),
        'course': courseController.text.trim(),
        'amount': amountController.text.trim(),
        'date':
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      });
    });

    studentController.clear();
    courseController.clear();
    amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$receiptNumber saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Create New Receipt',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: studentController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Colors.orange,
                    ),
                    title: const Text('Receipt Date'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    onTap: selectDate,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: saveReceipt,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'SAVE RECEIPT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Receipt History',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (receipts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No receipts created yet')),
              ),
            ),

          ...receipts.map(
            (receipt) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.receipt, color: Colors.white),
                ),
                title: Text(
                  receipt['receipt']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${receipt['student']}\n'
                  '${receipt['course']} • ${receipt['date']}',
                ),
                trailing: Text(
                  '₹${receipt['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    studentController.dispose();
    courseController.dispose();
    amountController.dispose();
    super.dispose();
  }
}

class ReportsManagementPage extends StatefulWidget {
  const ReportsManagementPage({super.key});

  @override
  State<ReportsManagementPage> createState() => _ReportsManagementPageState();
}

class _ReportsManagementPageState extends State<ReportsManagementPage> {
  static const String _feesKey = 'jsrc_fee_records';
  static const String _staffKey = 'jsrc_staff_records';

  bool _loading = true;

  int _studentCount = 0;
  final int _attendanceCount = 0;
  int _staffCount = 0;
  int _courseCount = 0;

  double _totalFees = 0;
  double _totalPaid = 0;
  double _totalPending = 0;

  List<Map<String, dynamic>> _attendanceRecords = [];
  List<Map<String, dynamic>> _feeRecords = [];
  List<Map<String, dynamic>> _staffRecords = [];
  List<String> _courses = [];

  String _selectedReport = 'Overview';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ---------------- STUDENTS ----------------
      _studentCount = students.length;

      final courseSet = <String>{};

      for (final student in students) {
        final course = student.course.trim();
        if (course.isNotEmpty) {
          courseSet.add(course);
        }
      }

      _courses = courseSet.toList()..sort();
      _courseCount = _courses.length;

      // ---------------- FEES ----------------
      _feeRecords = [];

      final feeData = prefs.getString(_feesKey);

      if (feeData != null && feeData.isNotEmpty) {
        try {
          final decoded = jsonDecode(feeData);

          if (decoded is List) {
            _feeRecords = decoded
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        } catch (_) {
          _feeRecords = [];
        }
      }

      _totalFees = 0;
      _totalPaid = 0;

      for (final student in _feeRecords) {
        final total = double.tryParse('${student['totalFees'] ?? 0}') ?? 0;

        _totalFees += total;

        final installments = student['installments'];

        if (installments is List) {
          for (final item in installments) {
            if (item is Map) {
              _totalPaid += double.tryParse('${item['paidAmount'] ?? 0}') ?? 0;
            }
          }
        }
      }

      _totalPending = _totalFees - _totalPaid;

      if (_totalPending < 0) {
        _totalPending = 0;
      }

      // ---------------- STAFF ----------------
      _staffRecords = [];

      final staffData = prefs.getString(_staffKey);

      if (staffData != null && staffData.isNotEmpty) {
        try {
          final decoded = jsonDecode(staffData);

          if (decoded is List) {
            _staffRecords = decoded
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        } catch (_) {
          _staffRecords = [];
        }
      }

      _staffCount = _staffRecords.length;

      // ---------------- ATTENDANCE ----------------
      _attendanceRecords = [];

      final keys = prefs.getKeys();

      for (final key in keys) {
        if (!key.startsWith('attendance_')) {
          continue;
        }

        // केवल main boolean attendance key को record मानें।
        // _name, _course, _date आदि को अलग record नहीं मानना है।
        if (prefs.get(key) is! bool) {
          continue;
        }

        if (prefs.getBool(key) != true) {
          continue;
        }

        final name = prefs.getString('${key}_name') ?? '';

        final studentId = prefs.getString('${key}_studentId') ?? '';

        final course = prefs.getString('${key}_course') ?? '';

        final date = prefs.getString('${key}_date') ?? '';

        final time = prefs.getString('${key}_time') ?? '';

        final verification =
            prefs.getString('${key}_verification') ??
            'Face + Eye Blink Verified';

        _attendanceRecords.add({
          'key': key,
          'name': name,
          'studentId': studentId,
          'course': course,
          'date': date,
          'time': time,
          'verification': verification,
        });
      }

      _attendanceRecords.sort((a, b) {
        final aTime = '${a['date']} ${a['time']}';
        final bTime = '${b['date']} ${b['time']}';
        return bTime.compareTo(aTime);
      });
    } catch (_) {
      // Safe fallback
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(icon, color: Colors.orange.shade800),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _overview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            _statCard(
              title: 'Total Students',
              value: '$_studentCount',
              icon: Icons.people,
            ),
            _statCard(
              title: 'Attendance Records',
              value: '$_attendanceCount',
              icon: Icons.fingerprint,
            ),
            _statCard(title: 'Staff', value: '$_staffCount', icon: Icons.badge),
            _statCard(
              title: 'Courses',
              value: '$_courseCount',
              icon: Icons.school,
            ),
          ],
        ),

        _sectionTitle('Fees Summary', Icons.account_balance_wallet),

        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _feeRow('Total Fees', _money(_totalFees)),
                const Divider(),
                _feeRow('Total Paid', _money(_totalPaid)),
                const Divider(),
                _feeRow('Pending Fees', _money(_totalPending)),
              ],
            ),
          ),
        ),

        _sectionTitle('Course Summary', Icons.menu_book),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _courses.isEmpty
                ? const Text('अभी कोई course data उपलब्ध नहीं है।')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _courses
                        .map(
                          (course) => Chip(
                            avatar: const Icon(Icons.school, size: 18),
                            label: Text(course),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _feeRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ],
    );
  }

  Widget _attendanceReport() {
    if (_attendanceRecords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('अभी कोई biometric attendance record नहीं मिला।'),
          ),
        ),
      );
    }

    return Column(
      children: _attendanceRecords.map((record) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.verified, color: Colors.green),
            ),
            title: Text(
              record['name'].toString().isEmpty
                  ? 'Student'
                  : record['name'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'ID: ${record['studentId']}\n'
              'Course: ${record['course']}\n'
              'Date: ${record['date']}   '
              'Time: ${record['time']}\n'
              '✓ ${record['verification']}',
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _feesReport() {
    if (_feeRecords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('अभी कोई fees record नहीं मिला।')),
        ),
      );
    }

    return Column(
      children: _feeRecords.map((student) {
        final total = double.tryParse('${student['totalFees'] ?? 0}') ?? 0;

        double paid = 0;

        final installments = student['installments'];

        if (installments is List) {
          for (final item in installments) {
            if (item is Map) {
              paid += double.tryParse('${item['paidAmount'] ?? 0}') ?? 0;
            }
          }
        }

        final pending = total - paid;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.currency_rupee)),
            title: Text(
              '${student['studentName'] ?? 'Student'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'ID: ${student['studentId'] ?? ''}\n'
              'Course: ${student['course'] ?? ''}\n'
              'Total: ${_money(total)}\n'
              'Paid: ${_money(paid)}\n'
              'Pending: ${_money(pending < 0 ? 0 : pending)}',
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _studentsReport() {
    if (students.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('अभी कोई student data उपलब्ध नहीं है।')),
        ),
      );
    }

    return Column(
      children: students.map((student) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                student.studentName.isNotEmpty
                    ? student.studentName[0].toUpperCase()
                    : 'S',
              ),
            ),
            title: Text(
              student.studentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Admission No: ${student.admissionNo}\n'
              'Roll No: ${student.rollNo}\n'
              'Mobile: ${student.mobile}\n'
              'Course: ${student.course}',
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _staffReport() {
    if (_staffRecords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('अभी कोई staff record नहीं मिला।')),
        ),
      );
    }

    return Column(
      children: _staffRecords.map((staff) {
        final name = staff['name'] ?? staff['staffName'] ?? 'Staff';

        final id = staff['staffId'] ?? staff['id'] ?? '';

        final designation = staff['designation'] ?? '';

        final subject = staff['subject'] ?? '';

        final mobile = staff['mobile'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.badge)),
            title: Text(
              name.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Staff ID: $id\n'
              'Designation: $designation\n'
              'Subject: $subject\n'
              'Mobile: $mobile',
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _selectedReportWidget() {
    switch (_selectedReport) {
      case 'Students':
        return _studentsReport();

      case 'Attendance':
        return _attendanceReport();

      case 'Fees':
        return _feesReport();

      case 'Staff':
        return _staffReport();

      default:
        return _overview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh Reports',
            onPressed: _loading ? null : _loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedReport,
                          decoration: const InputDecoration(
                            labelText: 'Report Type',
                            prefixIcon: Icon(Icons.analytics),
                            border: OutlineInputBorder(),
                          ),
                          items:
                              const [
                                'Overview',
                                'Students',
                                'Attendance',
                                'Fees',
                                'Staff',
                              ].map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedReport = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _selectedReportWidget(),
                  ],
                ),
              ),
            ),
    );
  }
}

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  static const String _storageKey = 'jsrc_staff_records';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _staffList = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _subjectController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          setState(() {
            _staffList = decoded
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList();
          });
        }
      } catch (_) {
        setState(() {
          _staffList = [];
        });
      }
    }
  }

  Future<void> _saveStaffRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_staffList));
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final record = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text.trim(),
      'staffId': _staffIdController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'designation': _designationController.text.trim(),
      'subject': _subjectController.text.trim(),
      'salary': _salaryController.text.trim(),
      'address': _addressController.text.trim(),
      'joiningDate':
          '${DateTime.now().day.toString().padLeft(2, '0')}/'
          '${DateTime.now().month.toString().padLeft(2, '0')}/'
          '${DateTime.now().year}',
      'status': 'Active',
    };

    setState(() {
      _staffList.insert(0, record);
    });

    await _saveStaffRecords();
    _clearForm();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff Record Saved Successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _staffIdController.clear();
    _mobileController.clear();
    _designationController.clear();
    _subjectController.clear();
    _salaryController.clear();
    _addressController.clear();
  }

  Future<void> _deleteStaff(int index) async {
    final staff = _filteredStaff[index];

    final actualIndex = _staffList.indexWhere(
      (item) => item['id'] == staff['id'],
    );

    if (actualIndex == -1) return;

    setState(() {
      _staffList.removeAt(actualIndex);
    });

    await _saveStaffRecords();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Staff Record Deleted')));
  }

  Future<void> _toggleStatus(int index) async {
    final staff = _filteredStaff[index];

    final actualIndex = _staffList.indexWhere(
      (item) => item['id'] == staff['id'],
    );

    if (actualIndex == -1) return;

    setState(() {
      _staffList[actualIndex]['status'] =
          _staffList[actualIndex]['status'] == 'Active' ? 'Inactive' : 'Active';
    });

    await _saveStaffRecords();
  }

  void _showStaffDetails(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.badge, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(child: Text(staff['name']?.toString() ?? 'Staff')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Staff ID', staff['staffId']),
                _detailRow('Mobile', staff['mobile']),
                _detailRow('Designation', staff['designation']),
                _detailRow('Subject/Course', staff['subject']),
                _detailRow('Salary', staff['salary']),
                _detailRow('Joining Date', staff['joiningDate']),
                _detailRow('Status', staff['status']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredStaff {
    if (_searchText.trim().isEmpty) {
      return _staffList;
    }

    final query = _searchText.toLowerCase();

    return _staffList.where((staff) {
      return (staff['name']?.toString().toLowerCase().contains(query) ??
              false) ||
          (staff['staffId']?.toString().toLowerCase().contains(query) ??
              false) ||
          (staff['mobile']?.toString().toLowerCase().contains(query) ??
              false) ||
          (staff['designation']?.toString().toLowerCase().contains(query) ??
              false);
    }).toList();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _clearForm();
          Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 400),
          );
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStaff,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_add_alt_1, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Add New Staff',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          'Staff Name',
                          Icons.person,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Staff name required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _staffIdController,
                        decoration: _inputDecoration('Staff ID', Icons.badge),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Staff ID required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          'Mobile Number',
                          Icons.phone,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number required';
                          }

                          if (value.trim().length < 10) {
                            return 'Enter valid mobile number';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _designationController,
                        decoration: _inputDecoration('Designation', Icons.work),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Designation required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _subjectController,
                        decoration: _inputDecoration(
                          'Subject / Course',
                          Icons.menu_book,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Monthly Salary',
                          Icons.currency_rupee,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Staff Address',
                          Icons.home,
                        ),
                      ),

                      const SizedBox(height: 18),
                      const SizedBox(height: 18),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveRecord,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Record',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Staff...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Staff Records',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    '${_staffList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (_filteredStaff.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _staffList.isEmpty
                            ? 'No Staff Records'
                            : 'No matching staff found',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_filteredStaff.length, (index) {
                final staff = _filteredStaff[index];
                final isActive = staff['status'] == 'Active';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive ? Colors.orange : Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      staff['name']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${staff['staffId']} • '
                      '${staff['designation']}\n'
                      '${staff['mobile']}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'view') {
                          _showStaffDetails(staff);
                        } else if (value == 'status') {
                          await _toggleStatus(index);
                        } else if (value == 'delete') {
                          await _deleteStaff(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            leading: Icon(Icons.visibility),
                            title: Text('View Profile'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'status',
                          child: ListTile(
                            leading: Icon(
                              isActive ? Icons.person_off : Icons.person,
                            ),
                            title: Text(
                              isActive ? 'Set Inactive' : 'Set Active',
                            ),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// COURSES MANAGEMENT
// =========================================================

class CoursesManagementPage extends StatefulWidget {
  const CoursesManagementPage({super.key});

  @override
  State<CoursesManagementPage> createState() => _CoursesManagementPageState();
}

class _CoursesManagementPageState extends State<CoursesManagementPage> {
  static const String _storageKey = 'jsrc_courses';

  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];

    setState(() {
      _courses = data
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _storageKey,
      _courses.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> _showCourseDialog({int? index}) async {
    final existing = index == null ? null : _courses[index];

    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final durationController = TextEditingController(
      text: existing?['duration'] ?? '',
    );
    final feeController = TextEditingController(text: existing?['fee'] ?? '');
    final descriptionController = TextEditingController(
      text: existing?['description'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.menu_book),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'Example: 6 Months',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Course Fee',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Course name required')),
                  );
                  return;
                }

                final course = {
                  'name': nameController.text.trim(),
                  'duration': durationController.text.trim(),
                  'fee': feeController.text.trim(),
                  'description': descriptionController.text.trim(),
                };

                setState(() {
                  if (index == null) {
                    _courses.add(course);
                  } else {
                    _courses[index] = course;
                  }
                });

                await _saveCourses();

                if (!mounted) return;
    Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCourse(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: const Text('क्या आप इस course को delete करना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _courses.removeAt(index);
      });

      await _saveCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: _courses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 80,
                      color: Colors.orange.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Courses Added',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first course using the + button.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.menu_book, color: Colors.white),
                    ),
                    title: Text(
                      course['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Duration: ${course['duration'] ?? '-'}\n'
                        'Fee: ₹${course['fee'] ?? '-'}\n'
                        '${course['description'] ?? ''}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showCourseDialog(index: index);
                        } else if (value == 'delete') {
                          _deleteCourse(index);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================
// CERTIFICATE MANAGEMENT
// =========================================================

class CertificatesManagementPage extends StatefulWidget {
  const CertificatesManagementPage({super.key});

  @override
  State<CertificatesManagementPage> createState() =>
      _CertificatesManagementPageState();
}

class _CertificatesManagementPageState
    extends State<CertificatesManagementPage> {
  static const String _storageKey = 'jsrc_certificates';

  List<Map<String, dynamic>> _certificates = [];

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];

    if (!mounted) return;

    setState(() {
      _certificates = data
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _saveCertificates() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _storageKey,
      _certificates.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> _deleteAttachmentFile(String? path) async {
    if (path == null || path.trim().isEmpty) return;

    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // File delete failure should not break certificate deletion.
    }
  }

  Future<Map<String, String>?> _pickCertificateFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final selected = result.files.single;
      final sourcePath = selected.path;

      if (sourcePath == null || sourcePath.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected file path नहीं मिला'),
            ),
          );
        }
        return null;
      }

      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected file उपलब्ध नहीं है'),
            ),
          );
        }
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();

      final certificateDir = Directory(
        '${appDir.path}/certificates',
      );

      if (!await certificateDir.exists()) {
        await certificateDir.create(recursive: true);
      }

      final originalName = selected.name.isNotEmpty
          ? selected.name
          : sourcePath.split('/').last;

      final safeName = originalName
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final destinationPath =
          '${certificateDir.path}/${timestamp}_$safeName';

      final copiedFile = await sourceFile.copy(destinationPath);

      return {
        'path': copiedFile.path,
        'name': originalName,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Certificate attach नहीं हो पाया: $e'),
          ),
        );
      }

      return null;
    }
  }

  Future<void> _openCertificate(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate file नहीं मिली'),
            ),
          );
        }
        return;
      }

      final opened = await launchUrl(
        Uri.file(path),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Certificate खोलने के लिए suitable app नहीं मिला',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate open नहीं हो पाया'),
          ),
        );
      }
    }
  }

  Future<void> _showCertificateDialog({int? index}) async {
    final existing =
        index == null ? null : _certificates[index];

    final studentController = TextEditingController(
      text: existing?['student'] ?? '',
    );

    final courseController = TextEditingController(
      text: existing?['course'] ?? '',
    );

    final numberController = TextEditingController(
      text: existing?['number'] ?? '',
    );

    final dateController = TextEditingController(
      text: existing?['date'] ?? '',
    );

    String? attachmentPath =
        existing?['attachmentPath']?.toString();

    String? attachmentName =
        existing?['attachmentName']?.toString();

    bool removeAttachment = false;

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  index == null
                      ? 'Add Certificate'
                      : 'Edit Certificate',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: studentController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: courseController,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          prefixIcon: Icon(Icons.menu_book),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: numberController,
                        decoration: const InputDecoration(
                          labelText: 'Certificate Number',
                          prefixIcon:
                              Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Issue Date',
                          hintText: 'DD/MM/YYYY',
                          prefixIcon:
                              Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange.shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Attached Certificate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            if (attachmentName != null &&
                                attachmentName!.isNotEmpty &&
                                !removeAttachment)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      attachmentName!,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: 'Remove',
                                    onPressed: () {
                                      setDialogState(() {
                                        removeAttachment = true;
                                        attachmentPath = null;
                                        attachmentName = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                            if (removeAttachment ||
                                attachmentName == null ||
                                attachmentName!.isEmpty)
                              const Padding(
                                padding:
                                    EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'No certificate attached',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 4),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked =
                                      await _pickCertificateFile();

                                  if (picked == null) return;

                                  setDialogState(() {
                                    attachmentPath =
                                        picked['path'];
                                    attachmentName =
                                        picked['name'];
                                    removeAttachment = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.upload_file,
                                ),
                                label: Text(
                                  attachmentName != null &&
                                          attachmentName!.isNotEmpty
                                      ? 'Replace Certificate'
                                      : 'Attach Certificate',
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Allowed: PDF, JPG, JPEG, PNG',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),

                  FilledButton.icon(
                    onPressed: () async {
                      if (studentController.text
                          .trim()
                          .isEmpty) {
                        ScaffoldMessenger.of(this.context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Student name required'),
                          ),
                        );
                        return;
                      }

                      final oldAttachmentPath =
                          existing?['attachmentPath']
                              ?.toString();

                      final certificate = {
                        'student':
                            studentController.text.trim(),
                        'course':
                            courseController.text.trim(),
                        'number':
                            numberController.text.trim(),
                        'date':
                            dateController.text.trim(),
                        'attachmentPath':
                            removeAttachment
                                ? ''
                                : (attachmentPath ?? ''),
                        'attachmentName':
                            removeAttachment
                                ? ''
                                : (attachmentName ?? ''),
                      };

                      if (!mounted) return;

                      setState(() {
                        if (index == null) {
                          _certificates.add(certificate);
                        } else {
                          _certificates[index] =
                              certificate;
                        }
                      });

                      await _saveCertificates();

                      if (!mounted) return;

                      // Delete old file only after new record
                      // has been successfully saved.
                      final newAttachmentPath =
                          certificate['attachmentPath']
                              ?.toString();

                      if (oldAttachmentPath != null &&
                          oldAttachmentPath.isNotEmpty &&
                          oldAttachmentPath !=
                              newAttachmentPath) {
                        await _deleteAttachmentFile(
                          oldAttachmentPath,
                        );
                      }

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text('Certificate record saved'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Record'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      studentController.dispose();
      courseController.dispose();
      numberController.dispose();
      dateController.dispose();
    }
  }

  Future<void> _deleteCertificate(int index) async {
    final certificate = _certificates[index];

    final attachmentPath =
        certificate['attachmentPath']?.toString();

    setState(() {
      _certificates.removeAt(index);
    });

    await _saveCertificates();

    await _deleteAttachmentFile(attachmentPath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _showCertificateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Certificate'),
      ),

      body: _certificates.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 80,
                      color: Colors.orange.shade300,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'No Certificates Added',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add certificate details and attach PDF/JPG/PNG.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final certificate =
                    _certificates[index];

                final attachmentPath =
                    certificate['attachmentPath']
                        ?.toString();

                final attachmentName =
                    certificate['attachmentName']
                        ?.toString();

                final hasAttachment =
                    attachmentPath != null &&
                    attachmentPath.isNotEmpty;

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 12),

                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                            ),
                          ),

                          title: Text(
                            certificate['student'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            'Course: ${certificate['course'] ?? '-'}\n'
                            'Certificate No.: ${certificate['number'] ?? '-'}\n'
                            'Issue Date: ${certificate['date'] ?? '-'}',
                          ),

                          isThreeLine: true,

                          trailing:
                              PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showCertificateDialog(
                                  index: index,
                                );
                              } else if (value ==
                                  'delete') {
                                _deleteCertificate(index);
                              }
                            },

                            itemBuilder: (context) =>
                                const [
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),

                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (hasAttachment)
                          Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.fromLTRB(
                              8,
                              0,
                              8,
                              8,
                            ),
                            padding:
                                const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange
                                  .withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.orange,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    attachmentName ??
                                        'Certificate File',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _openCertificate(
                                    attachmentPath,
                                  ),
                                  icon: const Icon(
                                    Icons.open_in_new,
                                    size: 18,
                                  ),
                                  label:
                                      const Text('Open'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================
// QR SCANNER
// =========================================================

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String _result = 'QR Code scan करें';
  bool _scanned = false;

  final TextEditingController _amountController =
      TextEditingController();

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value != null && value.trim().isNotEmpty) {
        setState(() {
          _result = value.trim();
          _scanned = true;
        });
        break;
      }
    }
  }

  void _scanAgain() {
    setState(() {
      _result = 'QR Code scan करें';
      _scanned = false;
    });
  }

  Future<void> _makeUpiPayment() async {
    final amount = _amountController.text.trim();

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पहले payment amount डालें'),
        ),
      );
      return;
    }

    final parsedAmount = double.tryParse(amount);

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सही amount डालें'),
        ),
      );
      return;
    }

    final qrValue = _result.trim();

    if (qrValue.isEmpty ||
        qrValue == 'QR Code scan करें') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पहले QR Code scan करें'),
        ),
      );
      return;
    }

    Uri? paymentUri;

    // अगर scanned QR UPI payment URI है,
    // तो उसी UPI ID/payment data का उपयोग करें।
    if (qrValue.toLowerCase().startsWith('upi://')) {
      try {
        final original = Uri.parse(qrValue);

        final params = Map<String, String>.from(
          original.queryParameters,
        );

        params['am'] = parsedAmount.toStringAsFixed(2);
        params['cu'] = 'INR';

        paymentUri = original.replace(
          queryParameters: params,
        );
      } catch (_) {
        paymentUri = null;
      }
    }

    // अगर QR में केवल UPI ID है, तो UPI payment URI बनाएं।
    if (paymentUri == null &&
        RegExp(
          r'^[\w.\-]+@[\w.\-]+$',
          caseSensitive: false,
        ).hasMatch(qrValue)) {
      paymentUri = Uri(
        scheme: 'upi',
        host: 'pay',
        queryParameters: {
          'pa': qrValue,
          'pn': 'Jay Shree Ram Computer Center',
          'am': parsedAmount.toStringAsFixed(2),
          'cu': 'INR',
        },
      );
    }

    if (paymentUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Scanned QR में valid UPI ID नहीं मिली',
          ),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        paymentUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'कोई UPI payment app उपलब्ध नहीं है',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment app open नहीं हो पाया',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPay = _scanned &&
        _result.trim().isNotEmpty &&
        _result != 'QR Code scan करें';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner & Payment'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  onDetect: _onDetect,
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'QR Code को box के अंदर रखें',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Scan Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                      ),
                    ),
                    child: SelectableText(
                      _result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Payment Amount',
                      hintText: 'उदाहरण: 500',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.currency_rupee,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          canPay ? _makeUpiPayment : null,
                      icon: const Icon(
                        Icons.payment,
                      ),
                      label: const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Colors.green.shade700,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _scanAgain,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                      ),
                      label: const Text(
                        'Scan Again',
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Payment आपके फोन की UPI app में खुलेगा।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// CENTER LOCATION
// =========================================================

class CenterLocationPage extends StatelessWidget {
  const CenterLocationPage({super.key});

  static const String address =
      'Jay Shree Ram Computer Center, '
      'Mansarovar Complex, 2nd Floor, '
      'Prashant Medical, Chhindwara, Madhya Pradesh';

  Future<void> _openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(address);

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Maps open नहीं हो पाया')),
      );
    }
  }

  Future<void> _callCenter(BuildContext context) async {
    const phone = '';

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Center mobile number अभी add नहीं किया गया है'),
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Center Location'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.orange.shade100,
              child: Icon(
                Icons.location_on,
                size: 65,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jay Shree Ram Computer Center',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        address,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _callCenter(context),
                icon: const Icon(Icons.call),
                label: const Text('Call Center'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String _currentUsername = 'admin';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    try {
      final secure = AdminLoginPage.secureStorage;

      String? username = await secure.read(
        key: AdminLoginPage.adminUsernameKey,
      );

      // Migration fallback for an older installation.
      if (username == null) {
        final prefs = await SharedPreferences.getInstance();

        username =
            prefs.getString(AdminLoginPage.adminUsernameKey) ??
                AdminLoginPage.defaultAdminUsername;

        final oldPassword =
            prefs.getString(AdminLoginPage.adminPasswordKey);

        await secure.write(
          key: AdminLoginPage.adminUsernameKey,
          value: username,
        );

        if (oldPassword != null) {
          await secure.write(
            key: AdminLoginPage.adminPasswordKey,
            value: oldPassword,
          );
        }

        await prefs.remove(AdminLoginPage.adminUsernameKey);
        await prefs.remove(AdminLoginPage.adminPasswordKey);
      }

      if (!mounted) return;

      setState(() {
        _currentUsername = username ?? AdminLoginPage.defaultAdminUsername;
        _usernameController.text = username ?? AdminLoginPage.defaultAdminUsername;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load secure admin data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameController.text.trim();
    final newPassword = _newPasswordController.text;

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin username cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'New password must contain at least 8 characters.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final secure = AdminLoginPage.secureStorage;

      final savedPassword =
          await secure.read(
            key: AdminLoginPage.adminPasswordKey,
          ) ??
          AdminLoginPage.defaultAdminPassword;

      final currentPassword =
          _currentPasswordController.text;

      if (currentPassword != savedPassword) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current password is incorrect.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await secure.write(
        key: AdminLoginPage.adminUsernameKey,
        value: newUsername,
      );

      await secure.write(
        key: AdminLoginPage.adminPasswordKey,
        value: newPassword,
      );

      // Clear old insecure copies if they still exist.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AdminLoginPage.adminUsernameKey);
      await prefs.remove(AdminLoginPage.adminPasswordKey);

      if (!mounted) return;

      setState(() {
        _currentUsername = newUsername;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin login credentials updated securely!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Secure save failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Login'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 42,
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'ADMINISTRATION LOGIN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Current username: $_currentUsername',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        decoration: _decoration(
                          'Current Password',
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrent = !_obscureCurrent;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter current password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          'New Admin Username',
                          Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter new username';
                          }

                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          'New Password',
                          Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter new password';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _decoration(
                          'Confirm New Password',
                          Icons.lock_reset,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm new password';
                          }

                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _saveChanges,
                          icon: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _saving
                                ? 'Saving...'
                                : 'SAVE LOGIN CHANGES',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Username aur password change karne ke liye '
                                  'pehle current password enter karna zaroori hai.',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
