import 'package:flutter/material.dart';

void main() {
  runApp(const JsrcApp());
}

class JsrcApp extends StatelessWidget {
  const JsrcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jay Shree Ram Computer Center',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jay Shree Ram Computer Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _dashboardCard(
            context,
            Icons.people,
            'Students',
            'Manage Students',
          ),
          _dashboardCard(
            context,
            Icons.check_circle,
            'Attendance',
            'Mark Attendance',
          ),
          _dashboardCard(
            context,
            Icons.location_on,
            'Location',
            'GPS Location',
          ),
          _dashboardCard(
            context,
            Icons.face,
            'Face Verification',
            'Verify Student',
          ),
          _dashboardCard(
            context,
            Icons.currency_rupee,
            'Fees',
            'Manage Fees',
          ),
          _dashboardCard(
            context,
            Icons.workspace_premium,
            'Certificates',
            'Student Certificates',
          ),
        ],
      ),
    );
  }

  static Widget _dashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
  if (title == 'Students') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentsPage(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title section selected'),
      ),
    );
  }
},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final List<Map<String, String>> students = [];

  void _addStudent() {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final courseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    prefixIcon: Icon(Icons.school),
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
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  students.add({
                    'name': nameController.text.trim(),
                    'mobile': mobileController.text.trim(),
                    'course': courseController.text.trim(),
                  });
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: students.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No Students Added',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Tap + to add a student'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      student['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Mobile: ${student['mobile'] ?? ''}\n'
                      'Course: ${student['course'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteStudent(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
