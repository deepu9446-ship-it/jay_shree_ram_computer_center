import 'package:flutter/material.dart';

void main() {
  runApp(const JsrcApp());
}

// ============================================================
// APP
// ============================================================

class JsrcApp extends StatelessWidget {
  const JsrcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jay Shree Ram Computer Center',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6D00),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6D00),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFF6D00),
              width: 2,
            ),
          ),
        ),
      ),
      home: const AdminLoginPage(),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class StudentData {
  String id;
  String name;
  String fatherName;
  String motherName;
  String dob;
  String aadhaar;
  String address;
  String mobile;
  String whatsapp;
  String email;
  String course;
  String admissionDate;
  String feeStatus;

  StudentData({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.aadhaar,
    required this.address,
    required this.mobile,
    required this.whatsapp,
    required this.email,
    required this.course,
    required this.admissionDate,
    required this.feeStatus,
  });
}

class StaffData {
  String id;
  String name;
  String designation;
  String mobile;
  String email;

  StaffData({
    required this.id,
    required this.name,
    required this.designation,
    required this.mobile,
    required this.email,
  });
}

// ============================================================
// GLOBAL SAMPLE DATA
// ============================================================

final List<StudentData> students = [
  StudentData(
    id: 'JSRC001',
    name: 'Rahul Sharma',
    fatherName: 'Ramesh Sharma',
    motherName: 'Sunita Sharma',
    dob: '12/05/2005',
    aadhaar: 'XXXX XXXX 1234',
    address: 'Chhindwara, Madhya Pradesh',
    mobile: '9876543210',
    whatsapp: '9876543210',
    email: 'rahul@example.com',
    course: 'PGDCA',
    admissionDate: '20/08/2026',
    feeStatus: 'Paid',
  ),
  StudentData(
    id: 'JSRC002',
    name: 'Priya Verma',
    fatherName: 'Mahesh Verma',
    motherName: 'Kiran Verma',
    dob: '04/02/2006',
    aadhaar: 'XXXX XXXX 5678',
    address: 'Chhindwara, Madhya Pradesh',
    mobile: '9123456780',
    whatsapp: '9123456780',
    email: 'priya@example.com',
    course: 'DCA',
    admissionDate: '18/08/2026',
    feeStatus: 'Pending',
  ),
  StudentData(
    id: 'JSRC003',
    name: 'Amit Patel',
    fatherName: 'Suresh Patel',
    motherName: 'Rekha Patel',
    dob: '15/09/2004',
    aadhaar: 'XXXX XXXX 9012',
    address: 'Chhindwara, Madhya Pradesh',
    mobile: '9988776655',
    whatsapp: '9988776655',
    email: 'amit@example.com',
    course: 'Tally Prime GST',
    admissionDate: '15/08/2026',
    feeStatus: 'Paid',
  ),
];

final List<StaffData> staffList = [
  StaffData(
    id: 'ST001',
    name: 'Deepak Sir',
    designation: 'Computer Instructor',
    mobile: '9876500001',
    email: 'deepak@jsrc.com',
  ),
  StaffData(
    id: 'ST002',
    name: 'Pooja Madam',
    designation: 'Office Manager',
    mobile: '9876500002',
    email: 'pooja@jsrc.com',
  ),
];

// ============================================================
// ADMIN LOGIN
// ============================================================

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username == 'admin' && password == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF6D00),
              Color(0xFFFF9800),
              Color(0xFFFFCC80),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFFFFF3E0),
                        child: Icon(
                          Icons.computer,
                          size: 58,
                          color: Color(0xFFFF6D00),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'JAY SHREE RAM',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const Text(
                        'COMPUTER CENTER',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Administration Login',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        onSubmitted: (_) => login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: login,
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Demo Login: admin / 1234',
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
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Dashboard',
    'Students',
    'Admission',
    'Staff Management',
    'Attendance',
    'Fees Management',
    'Study Material',
    'Certificates',
    'Reports',
    'Settings',
  ];

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (MediaQuery.of(context).size.width < 800) {
      Navigator.pop(context);
    }
  }

  Widget page() {
    switch (selectedIndex) {
      case 0:
        return const DashboardHome();
      case 1:
        return const StudentsPage();
      case 2:
        return const AdmissionPage();
      case 3:
        return const StaffPage();
      case 4:
        return const AttendancePage();
      case 5:
        return const FeesPage();
      case 6:
        return const StudyMaterialPage();
      case 7:
        return const CertificatesPage();
      case 8:
        return const ReportsPage();
      case 9:
        return const SettingsPage();
      default:
        return const DashboardHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  );
                },
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginPage(),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Text('Admin Profile'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFFFF6D00),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: AppDrawer(
                selectedIndex: selectedIndex,
                onSelect: selectPage,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 270,
              child: AppDrawer(
                selectedIndex: selectedIndex,
                onSelect: selectPage,
              ),
            ),
          Expanded(
            child: page(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DRAWER
// ============================================================

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final menu = [
      [Icons.dashboard, 'Dashboard'],
      [Icons.people, 'Students'],
      [Icons.person_add, 'Admission'],
      [Icons.badge, 'Staff Management'],
      [Icons.fact_check, 'Attendance'],
      [Icons.currency_rupee, 'Fees Management'],
      [Icons.menu_book, 'Study Material'],
      [Icons.workspace_premium, 'Certificates'],
      [Icons.assessment, 'Reports'],
      [Icons.settings, 'Settings'],
    ];

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 22, 15, 18),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF6D00),
                    Color(0xFFFF9800),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.computer,
                      size: 43,
                      color: Color(0xFFFF6D00),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'JAY SHREE RAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'COMPUTER CENTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: selectedIndex == index,
                    selectedTileColor: const Color(0xFFFFE0B2),
                    selectedColor: const Color(0xFFE65100),
                    leading: Icon(menu[index][0] as IconData),
                    title: Text(menu[index][1] as String),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'JSRC Admin Panel',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD HOME
// ============================================================

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Administrator 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Jay Shree Ram Computer Center Management Dashboard',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.8,
                children: [
                  StatCard(
                    title: 'Total Students',
                    value: '${students.length}',
                    icon: Icons.people,
                  ),
                  const StatCard(
                    title: 'Total Staff',
                    value: '2',
                    icon: Icons.badge,
                  ),
                  const StatCard(
                    title: 'Present Today',
                    value: '28',
                    icon: Icons.fact_check,
                  ),
                  const StatCard(
                    title: 'Pending Fees',
                    value: '₹12,500',
                    icon: Icons.currency_rupee,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 500
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  QuickAction(
                    title: 'New Admission',
                    icon: Icons.person_add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdmissionPage(),
                        ),
                      );
                    },
                  ),
                  QuickAction(
                    title: 'Students',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentsPage(),
                        ),
                      );
                    },
                  ),
                  QuickAction(
                    title: 'Attendance',
                    icon: Icons.fact_check,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendancePage(),
                        ),
                      );
                    },
                  ),
                  QuickAction(
                    title: 'Fees',
                    icon: Icons.currency_rupee,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeesPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 25),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Admissions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...students.take(3).map(
                        (student) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFE0B2),
                            child: Text(
                              student.name.substring(0, 1),
                              style: const TextStyle(
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                          title: Text(student.name),
                          subtitle: Text(
                            '${student.id} • ${student.course}',
                          ),
                          trailing: Text(student.admissionDate),
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

// ============================================================
// STAT CARD
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE65100),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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
}

// ============================================================
// QUICK ACTION
// ============================================================

class QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFE65100),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STUDENTS
// ============================================================

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String search = '';

  List<StudentData> get filtered {
    if (search.isEmpty) return students

import 'package:flutter/material.dart';

void main() {
  runApp(const JsrcApp());
}

// ============================================================
// APP
// ============================================================

class JsrcApp extends StatelessWidget {
  const JsrcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jay Shree Ram Computer Center',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F2),
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeDashboard(),
    StudentsPage(),
    AttendancePage(),
    FeesPage(),
    StudyMaterialPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
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
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_rupee),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME DASHBOARD
// ============================================================

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Jay Shree Ram Computer Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _openPage(
                context,
                const NotificationsPage(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _openPage(
                context,
                const SettingsPage(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(context),
              const SizedBox(height: 18),

              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      'Students',
                      '128',
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      context,
                      'Present',
                      '96',
                      Icons.how_to_reg,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      'Fees',
                      '₹48,500',
                      Icons.currency_rupee,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      context,
                      'Courses',
                      '12',
                      Icons.school,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'All Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _serviceGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6D00),
            Color(0xFFFF9800),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.computer,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Jay Shree Ram Computer Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Student Management & Learning Dashboard',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _serviceGrid(BuildContext context) {
    final services = [
      ServiceItem(
        'Location',
        Icons.location_on,
        const LocationPage(),
      ),
      ServiceItem(
        'Face Attendance',
        Icons.face,
        const FaceAttendancePage(),
      ),
      ServiceItem(
        'Eye Blink',
        Icons.visibility,
        const EyeBlinkPage(),
      ),
      ServiceItem(
        'Attendance',
        Icons.fact_check,
        const AttendancePage(),
      ),
      ServiceItem(
        'QR Scanner',
        Icons.qr_code_scanner,
        const QrScannerPage(),
      ),
      ServiceItem(
        'Study Material',
        Icons.menu_book,
        const StudyMaterialPage(),
      ),
      ServiceItem(
        'Audio / Video',
        Icons.play_circle,
        const MediaPage(),
      ),
      ServiceItem(
        'Social Media',
        Icons.share,
        const SocialMediaPage(),
      ),
      ServiceItem(
        'Fees',
        Icons.currency_rupee,
        const FeesPage(),
      ),
      ServiceItem(
        '12 Month Plan',
        Icons.calendar_month,
        const TwelveMonthFeesPage(),
      ),
      ServiceItem(
        'Payment',
        Icons.payment,
        const PaymentPage(),
      ),
      ServiceItem(
        'Student Profile',
        Icons.account_circle,
        const StudentProfilePage(),
      ),
      ServiceItem(
        'Certificates',
        Icons.workspace_premium,
        const CertificatesPage(),
      ),
      ServiceItem(
        'Staff',
        Icons.badge,
        const StaffPage(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .90,
      ),
      itemBuilder: (context, index) {
        final item = services[index];

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _openPage(context, item.page);
          },
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        Colors.deepOrange.withOpacity(.12),
                    child: Icon(
                      item.icon,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}

class ServiceItem {
  final String title;
  final IconData icon;
  final Widget page;

  ServiceItem(
    this.title,
    this.icon,
    this.page,
  );
}

void _openPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => page,
    ),
  );
}

// ============================================================
// STUDENTS
// ============================================================

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      'Rahul Sharma',
      'Aman Verma',
      'Priya Patel',
      'Neha Yadav',
      'Rohit Jain',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openPage(context, const AddStudentPage());
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Text(
                  students[index][0],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(students[index]),
              subtitle: Text(
                'JSRC-2026-${1001 + index}',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                _openPage(
                  context,
                  const StudentProfilePage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ADD STUDENT
// ============================================================

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final name = TextEditingController();
  final father = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final aadhaar = TextEditingController();
  final address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Admission'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Student Name', name, Icons.person),
          _field('Father Name', father, Icons.person_outline),
          _field('Mobile Number', mobile, Icons.phone),
          _field('Email', email, Icons.email),
          _field('Aadhaar Number', aadhaar, Icons.credit_card),
          _field('Address', address, Icons.location_on),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Student admission saved'),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Admission'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT PROFILE
// ============================================================

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 55,
            child: Icon(
              Icons.person,
              size: 60,
            ),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Rahul Sharma',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _info('Student ID', 'JSRC-2026-1001'),
          _info('Father Name', 'Rajesh Sharma'),
          _info('Course', 'PGDCA'),
          _info('Mobile', '9876543210'),
          _info('Email', 'student@gmail.com'),
          _info('Admission Date', '22 August 2026'),
          _info('Fee Status', 'Paid'),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ATTENDANCE
// ============================================================

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Map<String, bool> attendance = {
    'Rahul Sharma': true,
    'Aman Verma': true,
    'Priya Patel': false,
    'Neha Yadav': true,
    'Rohit Jain': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance System'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Colors.deepOrange,
              ),
              title: const Text('22 August 2026'),
              subtitle: const Text('Today's Attendance'),
              trailing: Text(
                '${attendance.values.where((e) => e).length}/${attendance.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...attendance.entries.map(
            (entry) => Card(
              child: SwitchListTile(
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    attendance[entry.key] = value;
                  });
                },
                title: Text(entry.key),
                subtitle: Text(
                  entry.value ? 'Present' : 'Absent',
                ),
                secondary: Icon(
                  entry.value
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: entry.value
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FACE ATTENDANCE
// ============================================================

class FaceAttendancePage extends StatefulWidget {
  const FaceAttendancePage({super.key});

  @override
  State<FaceAttendancePage> createState() =>
      _FaceAttendancePageState();
}

class _FaceAttendancePageState
    extends State<FaceAttendancePage> {
  bool scanning = false;

  void startScan() {
    setState(() {
      scanning = true;
    });

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        setState(() {
          scanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Face attendance demo completed',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Attendance'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundColor:
                    Colors.deepOrange.withOpacity(.12),
                child: Icon(
                  Icons.face,
                  size: 120,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                scanning
                    ? 'Scanning Face...'
                    : 'Face Verification',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Camera based face verification module',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              FilledButton.icon(
                onPressed: scanning ? null : startScan,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  scanning
                      ? 'Please Wait...'
                      : 'Start Face Attendance',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EYE BLINK
// ============================================================

class EyeBlinkPage extends StatefulWidget {
  const EyeBlinkPage({super.key});

  @override
  State<EyeBlinkPage> createState() => _EyeBlinkPageState();
}

class _EyeBlinkPageState extends State<EyeBlinkPage> {
  bool blinkDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Blink Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility,
                size: 130,
                color: blinkDetected
                    ? Colors.green
                    : Colors.deepOrange,
              ),
              const SizedBox(height: 25),
              Text(
                blinkDetected
                    ? 'Blink Detected ✓'
                    : 'Eye Blink Verification',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    blinkDetected = true;
                  });
                },
                child: const Text(
                  'Verify Blink',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION
// ============================================================

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool tracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 130,
                color: tracking
                    ? Colors.green
                    : Colors.deepOrange,
              ),
              const SizedBox(height: 20),
              Text(
                tracking
                    ? 'Location Tracking ON'
                    : 'Location Tracking OFF',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'GPS location module',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    tracking = !tracking;
                  });
                },
                icon: const Icon(Icons.gps_fixed),
                label: Text(
                  tracking
                      ? 'Stop Tracking'
                      : 'Start Tracking',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QR SCANNER
// ============================================================

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() =>
      _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String result = 'QR code not scanned';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepOrange,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 25),
              Text(result),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    result =
                        'Demo QR Result: JSRC-STUDENT-1001';
                  });
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                ),
                label: const Text(
                  'Scan QR',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FEES
// ============================================================

class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _feeCard(
            'Total Course Fee',
            '₹24,000',
            Icons.school,
          ),
          _feeCard(
            'Paid Amount',
            '₹12,000',
            Icons.check_circle,
          ),
          _feeCard(
            'Pending Amount',
            '₹12,000',
            Icons.pending,
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: () {
              _openPage(
                context,
                const TwelveMonthFeesPage(),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text(
              'View 12 Month Fee Plan',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              _openPage(
                context,
                const PaymentPage(),
              );
            },
            icon: const Icon(Icons.payment),
            label: const Text(
              'Pay Fees',
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeCard(
    String title,
    String amount,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepOrange,
        ),
        title: Text(title),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 12 MONTH FEES
// ============================================================

class TwelveMonthFeesPage extends StatelessWidget {
  const TwelveMonthFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('12 Month Payment Plan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 12,
        itemBuilder: (context, index) {
          final paid = index < 5;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(
                'Month ${index + 1}',
              ),
              subtitle: Text(
                paid ? 'Payment Completed' : 'Payment Pending',
              ),
              trailing: paid
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : FilledButton(
                      onPressed: () {
                        _openPage(
                          context,
                          const PaymentPage(),
                        );
                      },
                      child: const Text('Pay'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PAYMENT
// ============================================================

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() =>
      _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String method = 'UPI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 60,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Fee Payment',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Amount: ₹2,000',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          RadioListTile(
            value: 'UPI',
            groupValue: method,
            title: const Text('UPI'),
            onChanged: (value) {
              setState(() {
                method = value!;
              });
            },
          ),
          RadioListTile(
            value: 'QR',
            groupValue: method,
            title: const Text('QR Payment'),
            onChanged: (value) {
              setState(() {
                method = value!;
              });
            },
          ),
          RadioListTile(
            value: 'Card',
            groupValue: method,
            title: const Text('Debit / Credit Card'),
            onChanged: (value) {
              setState(() {
                method = value!;
              });
            },
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment initiated via $method',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.lock),
            label: const Text(
              'Proceed to Payment',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STUDY MATERIAL
// ============================================================

class StudyMaterialPage extends StatelessWidget {
  const StudyMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final materials = [
      ['PGDCA Notes', Icons.picture_as_pdf],
      ['DCA Notes', Icons.picture_as_pdf],
      ['Tally Prime GST', Icons.menu_book],
      ['CPCT Material', Icons.description],
      ['MS Office', Icons.computer],
      ['Photoshop DTP', Icons.image],
      ['CorelDraw', Icons.design_services],
      ['AI Tools', Icons.smart_toy],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Material'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(
                materials[index][1] as IconData,
                color: Colors.deepOrange,
              ),
              title: Text(
                materials[index][0] as String,
              ),
              trailing: const Icon(
                Icons.download,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Study material selected',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// AUDIO / VIDEO
// ============================================================

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio & Video'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _media(
            context,
            'Tally Prime GST Class',
            Icons.play_circle,
          ),
          _media(
            context,
            'MS Excel Practical',
            Icons.video_library,
          ),
          _media(
            context,
            'Computer Basic Audio',
            Icons.audiotrack,
          ),
          _media(
            context,
            'CPCT Typing Practice',
            Icons.keyboard,
          ),
        ],
      ),
    );
  }

  Widget _media(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: Colors.deepOrange,
        ),
        title: Text(title),
        subtitle: const Text(
          'Learning content',
        ),
        trailing: const Icon(
          Icons.play_arrow,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Media player opened'),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SOCIAL MEDIA
// ============================================================

class SocialMediaPage extends StatelessWidget {
  const SocialMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSRC Social'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _social(
            context,
            'WhatsApp',
            Icons.chat,
          ),
          _social(
            context,
            'YouTube',
            Icons.play_circle,
          ),
          _social(
            context,
            'Facebook',
            Icons.facebook,
          ),
          _social(
            context,
            'Instagram',
            Icons.camera_alt,
          ),
          _social(
            context,
            'Telegram',
            Icons.send,
          ),
        ],
      ),
    );
  }

  Widget _social(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.open_in_new,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title selected',
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// CERTIFICATES
// ============================================================

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _certificate('Course Certificate'),
          _certificate('PGDCA Certificate'),
          _certificate('DCA Certificate'),
          _certificate('Tally Certificate'),
          _certificate('Typing Certificate'),
        ],
      ),
    );
  }

  Widget _certificate(String title) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.workspace_premium,
          color: Colors.amber,
          size: 35,
        ),
        title: Text(title),
        trailing: const Icon(Icons.download),
      ),
    );
  }
}

// ============================================================
// STAFF
// ============================================================

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _staff('Computer Instructor', 'Admin'),
          _staff('Tally Instructor', 'Teacher'),
          _staff('Office Staff', 'Staff'),
        ],
      ),
    );
  }

  Widget _staff(String name, String role) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Welcome to JSRC'),
            subtitle: Text(
              'Jay Shree Ram Computer Center',
            ),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Fee Reminder'),
            subtitle: Text(
              'Your monthly fee is pending.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('New Study Material'),
            subtitle: Text(
              'New learning material available.',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MORE
// ============================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _item(
            context,
            'Location Tracker',
            Icons.location_on,
            const LocationPage(),
          ),
          _item(
            context,
            'Face Attendance',
            Icons.face,
            const FaceAttendancePage(),
          ),
          _item(
            context,
            'Eye Blink',
            Icons.visibility,
            const EyeBlinkPage(),
          ),
          _item(
            context,
            'QR Scanner',
            Icons.qr_code_scanner,
            const QrScannerPage(),
          ),
          _item(
            context,
            'Certificates',
            Icons.workspace_premium,
            const CertificatesPage(),
          ),
          _item(
            context,
            'Staff',
            Icons.badge,
            const StaffPage(),
          ),
          _item(
            context,
            'Settings',
            Icons.settings,
            const SettingsPage(),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepOrange,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          _openPage(context, page);
        },
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool location = false;
  bool biometric = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (v) {
              setState(() {
                notifications = v;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Location Tracking'),
            value: location,
            onChanged: (v) {
              setState(() {
                location = v;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Face / Biometric'),
            value: biometric,
            onChanged: (v) {
              setState(() {
                biometric = v;
              });
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About JSRC'),
            subtitle: Text(
              'Jay Shree Ram Computer Center',
            ),
          ),
        ],
      ),
    );
  }
}
