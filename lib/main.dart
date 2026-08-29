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
      home: const DashboardPage(),
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
        builder: (_) => FeaturePage(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
        ),
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
