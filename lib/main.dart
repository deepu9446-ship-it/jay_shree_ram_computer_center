import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_page.dart';

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

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  static const String adminUsername = 'admin';
  static const String adminPassword = '123456';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      if (username == adminUsername && password == adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Admin ID or Password'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _loading = false;
      });
    });
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
   return const FeesManagementPage();
}if (item.title == 'Fees') {
  return const FeesManagementPage();
}
if (item.title == 'Staff') {
  return const StaffManagementPage();
}
if (item.title == 'Receipt Management') {
  return const ReceiptManagementPage();
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

class StudentProfilePage extends StatefulWidget {
  final Student? student;
  final int? index;

  const StudentProfilePage({super.key, this.student, this.index});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
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
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
  );

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

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState()
  => _StudentListPageState();
}

class _StudentListPageState extends
 State<StudentListPage> {
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
class ReceiptManagementPage extends StatefulWidget {
  const ReceiptManagementPage({super.key});

  @override
  State<ReceiptManagementPage> createState() =>
      _ReceiptManagementPageState();
}

class _ReceiptManagementPageState
    extends State<ReceiptManagementPage> {
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (receipts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No receipts created yet'),
                ),
              ),
            ),

          ...receipts.map(
            (receipt) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.receipt,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  receipt['receipt']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
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
        records.addAll(
          List<Map<String, dynamic>>.from(decoded),
        );
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'jsrc_fee_records',
      jsonEncode(records),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सभी जानकारी सही भरें'),
        ),
      );
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
        'admissionDate':
            DateTime.now().toIso8601String(),
        'installments': installments,
      });
    });

    _saveRecords();

    nameController.clear();
    idController.clear();
    courseController.clear();
    totalController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student Fees Record Save हो गया'),
      ),
    );
  }

  double _totalPaid(Map<String, dynamic> student) {
    final list =
        List<Map<String, dynamic>>.from(student['installments']);

    return list.fold<double>(
      0,
      (sum, item) =>
          sum + ((item['paidAmount'] ?? 0) as num).toDouble(),
    );
  }

  Future<void> _payInstallment(
    Map<String, dynamic> student,
    int index,
  ) async {
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
                final paid =
                    double.tryParse(amountController.text.trim());

                if (paid == null || paid <= 0) {
                  return;
                }

                final installment =
                    (student['installments'][index]['amount'] as num)
                        .toDouble();

                setState(() {
                  student['installments'][index]['paidAmount'] =
                      paid;
                  student['installments'][index]['status'] =
                      paid >= installment ? 'Paid' : 'Partial';
                  student['installments'][index]['paidDate'] =
                      DateTime.now().toIso8601String();
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                child: Center(
                  child: Text('अभी कोई Fees Record नहीं है'),
                ),
              ),
            ),

          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;

            final total =
                (student['totalFees'] as num).toDouble();
            final paid = _totalPaid(student);
            final pending = total - paid;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  student['studentName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${student['course']} • ${student['studentId']}',
                ),
                children: [
                  ListTile(
                    title: const Text('Total Fees'),
                    trailing: Text(
                      '₹${total.toStringAsFixed(0)}',
                    ),
                  ),
                  ListTile(
                    title: const Text('Total Paid'),
                    trailing: Text(
                      '₹${paid.toStringAsFixed(0)}',
                    ),
                  ),
                  ListTile(
                    title: const Text('Pending'),
                    trailing: Text(
                      '₹${pending.toStringAsFixed(0)}',
                    ),
                  ),

                  const Divider(),

                  ...List.generate(12, (monthIndex) {
                    final installment =
                        student['installments'][monthIndex];

                    final amount =
                        (installment['amount'] as num).toDouble();

                    final paidAmount =
                        (installment['paidAmount'] as num).toDouble();

                    final status =
                        installment['status'] ?? 'Pending';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${monthIndex + 1}'),
                      ),
                      title: Text(
                        '${installment['month']} - ₹${amount.toStringAsFixed(0)}',
                      ),
                      subtitle: Text(
                        'Paid: ₹${paidAmount.toStringAsFixed(0)} • $status',
                      ),
                      trailing: status == 'Paid'
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.payment,
                                color: Colors.orange,
                              ),
                              onPressed: () =>
                                  _payInstallment(
                                student,
                                monthIndex,
                              ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff Record Deleted'),
      ),
    );
  }

  Future<void> _toggleStatus(int index) async {
    final staff = _filteredStaff[index];

    final actualIndex = _staffList.indexWhere(
      (item) => item['id'] == staff['id'],
    );

    if (actualIndex == -1) return;

    setState(() {
      _staffList[actualIndex]['status'] =
          _staffList[actualIndex]['status'] == 'Active'
              ? 'Inactive'
              : 'Active';
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
              Expanded(
                child: Text(
                  staff['name']?.toString() ?? 'Staff',
                ),
              ),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value?.toString() ?? '-',
            ),
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                          Icon(
                            Icons.person_add_alt_1,
                            color: Colors.orange,
                          ),
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
                        decoration: _inputDecoration(
                          'Staff ID',
                          Icons.badge,
                        ),
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
                        decoration: _inputDecoration(
                          'Designation',
                          Icons.work,
                        ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
              ...List.generate(
                _filteredStaff.length,
                (index) {
                  final staff = _filteredStaff[index];
                  final isActive = staff['status'] == 'Active';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isActive ? Colors.orange : Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        staff['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
                                isActive
                                    ? Icons.person_off
                                    : Icons.person,
                              ),
                              title: Text(
                                isActive
                                    ? 'Set Inactive'
                                    : 'Set Active',
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
