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
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFF8F1),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const orange = Color(0xFFF57C00);
  static const darkOrange = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        title: const Text(
          'Jay Shree Ram Computer Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _openPage(
              context,
              'Notifications',
              Icons.notifications,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(),
            const SizedBox(height: 18),

            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                DashboardItem(
                  icon: Icons.people_alt,
                  title: 'Students',
                  subtitle: 'Manage students',
                  color: Colors.blue,
                  onTap: () => _openPage(
                    context,
                    'Students',
                    Icons.people_alt,
                  ),
                ),
                DashboardItem(
                  icon: Icons.fact_check,
                  title: 'Attendance',
                  subtitle: 'Daily attendance',
                  color: Colors.green,
                  onTap: () => _openPage(
                    context,
                    'Attendance',
                    Icons.fact_check,
                  ),
                ),
                DashboardItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: 'GPS tracking',
                  color: Colors.red,
                  onTap: () => _openPage(
                    context,
                    'Location',
                    Icons.location_on,
                  ),
                ),
                DashboardItem(
                  icon: Icons.currency_rupee,
                  title: 'Fees',
                  subtitle: 'Fee management',
                  color: Colors.purple,
                  onTap: () => _openPage(
                    context,
                    'Fees',
                    Icons.currency_rupee,
                  ),
                ),
                DashboardItem(
                  icon: Icons.verified,
                  title: 'Certificates',
                  subtitle: 'Student certificates',
                  color: Colors.teal,
                  onTap: () => _openPage(
                    context,
                    'Certificates',
                    Icons.verified,
                  ),
                ),
                DashboardItem(
                  icon: Icons.face,
                  title: 'Face / Eye',
                  subtitle: 'Verification',
                  color: Colors.indigo,
                  onTap: () => _openPage(
                    context,
                    'Face / Eye Verification',
                    Icons.face,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Popular Courses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _courseCard(
              context,
            Icons.computer,
            'Basic Computer',
            'Computer fundamentals',
            ),
            _courseCard(
              context,
              Icons.calculate,
              'Tally Prime GST',
              'Accounting & GST training',
            ),
            _courseCard(
              context,
              Icons.keyboard,
              'CPCT & Typing',
              'Hindi & English typing',
            ),
            _courseCard(
              context,
              Icons.design_services,
              'Photoshop / CorelDraw',
              'Design & graphics training',
            ),
            _courseCard(
              context,
              Icons.table_chart,
              'Atom Advance Tally Office Management',
              'Office & accounting training',
            ),
            _courseCard(
              context,
              Icons.data_object,
              'Data Entry',
              'Computer data entry training',
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9800),
                    Color(0xFFE65100),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jay Shree Ram Computer Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Computer Education • Job Training • Skill Development',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Mansarovar Complex, 2nd Floor, Prashant Medical, Chhindwara',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFFE65100),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 5),
            color: Colors.orange.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: const Row(
        children: [
          ClipOval(
  child: Container(
    width: 70,
    height: 70,
    color: Colors.white,
    padding: const EdgeInsets.all(5),
    child: Image.asset(
      'assets/icon/jay_shree_ram_logo.png',
      fit: BoxFit.contain,
    ),
  ),
),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Jay Shree Ram Computer Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your future, your first step',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: Icon(
            icon,
            color: orange,
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
        onTap: () => _openPage(context, title, icon),
      ),
    );
  }

  void _openPage(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeaturePage(
          title: title,
          icon: icon,
        ),
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const DashboardItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF9800),
                  Color(0xFFE65100),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.computer,
                    size: 38,
                    color: Color(0xFFF57C00),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'JSRC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Jay Shree Ram Computer Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _item(
            context,
            Icons.dashboard,
            'Dashboard',
            const DashboardPage(),
          ),
          _item(
            context,
            Icons.people_alt,
            'Students',
            const FeaturePage(
              title: 'Students',
              icon: Icons.people_alt,
            ),
          ),
          _item(
            context,
            Icons.fact_check,
            'Attendance',
            const FeaturePage(
              title: 'Attendance',
              icon: Icons.fact_check,
            ),
          ),
          _item(
            context,
            Icons.currency_rupee,
            'Fees',
            const FeaturePage(
              title: 'Fees',
              icon: Icons.currency_rupee,
            ),
          ),
          _item(
            context,
            Icons.school,
            'Courses',
            const FeaturePage(
              title: 'Courses',
              icon: Icons.school,
            ),
          ),
          _item(
            context,
            Icons.verified,
            'Certificates',
            const FeaturePage(
              title: 'Certificates',
              icon: Icons.verified,
            ),
          ),
          const Divider(),
          _item(
            context,
            Icons.settings,
            'Settings',
            const FeaturePage(
              title: 'Settings',
              icon: Icons.settings,
            ),
          ),
          _item(
            context,
            Icons.info_outline,
            'About Center',
            const FeaturePage(
              title: 'About Center',
              icon: Icons.info_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange.shade800),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}

class FeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.orange.shade50,
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This module is ready for the next development step.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: Text('Add $title'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
