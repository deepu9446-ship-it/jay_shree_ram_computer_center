import 'package:flutter/material.dart';

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
          MaterialPageRoute(
            builder: (_) => const DashboardPage(),
          ),
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
            colors: [
              Colors.orange,
              Color(0xFFFF8F00),
              Colors.white,
            ],
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
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
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
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
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
      title: 'Attendance',
      subtitle: 'Daily Attendance',
      icon: Icons.fact_check,
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
        title: const Text(
          'Jay Shree Ram Computer Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                ),
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
            await Future<void>.delayed(
              const Duration(milliseconds: 500),
            );
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
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
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
          colors: [
            Colors.orange,
            Color(0xFFFF8F00),
          ],
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
            child: const Icon(
              Icons.computer,
              color: Colors.white,
              size: 34,
            ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage your center from one place',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
        _statCard(
          'Total Students',
          '248',
          Icons.people,
          Colors.blue,
        ),
        _statCard(
          'Present Today',
          '186',
          Icons.how_to_reg,
          Colors.green,
        ),
        _statCard(
          'Pending Fees',
          '₹24,500',
          Icons.account_balance_wallet,
          Colors.red,
        ),
        _statCard(
          'Courses',
          '12',
          Icons.menu_book,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
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
                  Icon(
                    item.icon,
                    color: Colors.orange.shade800,
                    size: 23,
                  ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
            _activity(
              Icons.fact_check,
              'Attendance marked',
              'Today, 12:05 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _activity(
    IconData icon,
    String title,
    String time,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withValues(alpha: 0.12),
        child: Icon(
          icon,
          color: Colors.orange,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
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
                colors: [
                  Colors.orange,
                  Color(0xFFFF8F00),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.computer,
                      color: Colors.orange,
                      size: 38,
                    ),
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
                    style: TextStyle(
                      color: Colors.white70,
                    ),
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
                  leading: const Icon(Icons.fact_check),
                  title: const Text('Attendance'),
                  onTap: () {
                    Navigator.pop(context);
                    openFeature(items[2]);
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
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
                colors: [
                  Colors.orange,
                  Color(0xFFFF8F00),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(
                    icon,
                    size: 44,
                    color: Colors.orange,
                  ),
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
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
          _actionCard(
            context,
            'View List',
            'View all records',
            Icons.list_alt,
          ),
          _actionCard(
            context,
            'Search',
            'Search records',
            Icons.search,
          ),
          _actionCard(
            context,
            'Reports',
            'Generate reports',
            Icons.analytics,
          ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.12),
          child: Icon(
            actionIcon,
            color: Colors.orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
  String pincode;
  String course;
  String admissionNo;
  String rollNo;

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
    required this.pincode,
    required this.course,
    required this.admissionNo,
    required this.rollNo,
  });
}

final List<Student> students = [];

class StudentProfilePage extends StatefulWidget {
  final Student? student;
  final int? index;

  const StudentProfilePage({
    super.key,
    this.student,
    this.index,
  });

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
  final course = TextEditingController();
  final admissionNo = TextEditingController();
  final rollNo = TextEditingController();

  String gender = 'Male';

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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
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

  void saveStudent() {
    if (!formKey.currentState!.validate()) return;

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
    );

    setState(() {
      if (widget.index != null) {
        students[widget.index!] = newStudent;
      } else {
        students.add(newStudent);
      }
    });

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
                  colors: [
                    Colors.orange,
                    Color(0xFFFF8F00),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Student Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Jay Shree Ram Computer Center',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            field(
              'Student Name',
              studentName,
              Icons.person,
            ),

            field(
              'Father Name',
              fatherName,
              Icons.man,
            ),

            field(
              'Mother Name',
              motherName,
              Icons.woman,
            ),

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

            field(
              'Date of Birth',
              dob,
              Icons.calendar_month,
            ),

            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: decoration(
                'Gender',
                Icons.wc,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            field(
              'Address',
              address,
              Icons.home,
            ),

            field(
              'City',
              city,
              Icons.location_city,
            ),

            field(
              'State',
              state,
              Icons.map,
            ),

            field(
              'PIN Code',
              pincode,
              Icons.pin_drop,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 22),

            const Text(
              'Course & Admission',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            field(
              'Course',
              course,
              Icons.menu_book,
            ),

            field(
              'Admission Number',
              admissionNo,
              Icons.confirmation_number,
            ),

            field(
              'Roll Number',
              rollNo,
              Icons.badge,
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: saveStudent,
                icon: const Icon(Icons.save),
                label: Text(
                  editing
                      ? 'UPDATE STUDENT'
                      : 'SAVE STUDENT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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
  State<StudentListPage> createState() => _StudentListPageState();
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
      MaterialPageRoute(
        builder: (_) => const StudentProfilePage(),
      ),
    );

    setState(() {});
  }

  void editStudent(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentProfilePage(
          student: students[index],
          index: index,
        ),
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
          content: Text(
            'Delete ${student.studentName} from student list?',
          ),
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
                  const SnackBar(
                    content: Text('Student deleted'),
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

  void viewStudent(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(
                  Icons.person,
                  size: 45,
                ),
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
        leading: const Icon(
          Icons.info_outline,
          color: Colors.orange,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? '-' : value,
        ),
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
                hintText:
                    'Search name, mobile, admission no...',
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: Colors.orange,
                ),
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
                      mainAxisAlignment:
                          MainAxisAlignment.center,
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
                        const Text(
                          'Tap Add Student to create a profile',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      100,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, position) {
                      final student = list[position];

                      final realIndex =
                          students.indexOf(student);

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(12),

                          leading: const CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                Color(0xFFFFE0B2),
                            child: Icon(
                              Icons.person,
                              color: Colors.orange,
                            ),
                          ),

                          title: Text(
                            student.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                student.course,
                              ),
                              Text(
                                'Admission: ${student.admissionNo}',
                              ),
                              Text(
                                'Mobile: ${student.mobile}',
                              ),
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
                                  leading:
                                      Icon(Icons.visibility),
                                  title: Text('View Profile'),
                                ),
                              ),
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
