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
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  void login() {
    if (usernameController.text.trim() == 'admin' &&
        passwordController.text == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9800),
              Color(0xFFE65100),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icon/jay_shree_ram_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, __) => const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.computer, size: 50),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Jay Shree Ram',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const Text(
                        'Computer Center',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: login,
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Demo: admin / 123456',
                        style: TextStyle(color: Colors.grey),
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

// ================= DASHBOARD =================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const orange = Color(0xFFF57C00);

  void openPage(
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
            onPressed: () => openPage(
              context,
              'Notifications',
              Icons.notifications,
            ),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(context),
            const SizedBox(height: 20),
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
              childAspectRatio: 1.3,
              children: [
                DashboardItem(
                  icon: Icons.people_alt,
                  title: 'Students',
                  subtitle: 'Manage students',
                  color: Colors.blue,
                  onTap: () => openPage(
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
                  onTap: () => openPage(
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
                  onTap: () => openPage(
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
                  onTap: () => openPage(
                    context,
                    'Fees',
                    Icons.currency_rupee,
                  ),
                ),
                DashboardItem(
                  icon: Icons.qr_code_2,
                  title: 'UPI QR',
                  subtitle: 'Scan & Pay',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentPage(),
                      ),
                    );
                  },
                ),
                DashboardItem(
                  icon: Icons.verified,
                  title: 'Certificates',
                  subtitle: 'Student certificates',
                  color: Colors.teal,
                  onTap: () => openPage(
                    context,
                    'Certificates',
                    Icons.verified,
                  ),
                ),
                DashboardItem(
                  icon: Icons.face,
                  title: 'Face / Eye',
                  subtitle: 'Verification',
                  color: Colors.deepPurple,
                  onTap: () => openPage(
                    context,
                    'Face / Eye Verification',
                    Icons.face,
                  ),
                ),
                DashboardItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Admin settings',
                  color: Colors.grey,
                  onTap: () => openPage(
                    context,
                    'Admin Settings',
                    Icons.settings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Popular Courses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CourseCard(
              icon: Icons.computer,
              title: 'Basic Computer',
              subtitle: 'Computer fundamentals',
              onTap: () => openPage(
                context,
                'Basic Computer',
                Icons.computer,
              ),
            ),
            CourseCard(
              icon: Icons.calculate,
              title: 'Tally Prime GST',
              subtitle: 'Accounting & GST training',
              onTap: () => openPage(
                context,
                'Tally Prime GST',
                Icons.calculate,
              ),
            ),
            CourseCard(
              icon: Icons.keyboard,
              title: 'CPCT & Typing',
              subtitle: 'Hindi & English typing',
              onTap: () => openPage(
                context,
                'CPCT & Typing',
                Icons.keyboard,
              ),
            ),
            CourseCard(
              icon: Icons.design_services,
              title: 'Photoshop / CorelDraw',
              subtitle: 'Design & graphics training',
              onTap: () => openPage(
                context,
                'Photoshop / CorelDraw',
                Icons.design_services,
              ),
            ),
            CourseCard(
              icon: Icons.table_chart,
              title: 'ATOM Advance Tally Office Management',
              subtitle: 'Office & accounting training',
              onTap: () => openPage(
                context,
                'ATOM Advance Tally Office Management',
                Icons.table_chart,
              ),
            ),
            CourseCard(
              icon: Icons.data_object,
              title: 'Data Entry',
              subtitle: 'Computer data entry training',
              onTap: () => openPage(
                context,
                'Data Entry',
                Icons.data_object,
              ),
            ),
            const SizedBox(height: 10),
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

  Widget _welcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFFE65100),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              color: Colors.white,
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/icon/jay_shree_ram_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, __) => const Icon(
                  Icons.computer,
                  size: 40,
                  color: orange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jay Shree Ram Computer Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your future, your first step',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DASHBOARD ITEM =================

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
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= COURSE CARD =================

class CourseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: Icon(
            icon,
            color: Colors.orange.shade800,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ================= DRAWER =================

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void open(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    Navigator.pop(context);

    if (title == 'Payment') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentPage(),
        ),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF9800),
                  Color(0xFFE65100),
                ],
              ),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.white,
                    width: 65,
                    height: 65,
                    padding: const EdgeInsets.all(7),
                    child: Image.asset(
                      'assets/icon/jay_shree_ram_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, __) => const Icon(
                        Icons.computer,
                        color: Colors.orange,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _item(
            context,
            Icons.dashboard,
            'Dashboard',
          ),
          _item(
            context,
            Icons.people_alt,
            'Students',
          ),
          _item(
            context,
            Icons.fact_check,
            'Attendance',
          ),
          _item(
            context,
            Icons.currency_rupee,
            'Fees',
          ),
          _item(
            context,
            Icons.qr_code_2,
            'Payment',
          ),
          _item(
            context,
            Icons.location_on,
            'Location',
          ),
          _item(
            context,
            Icons.verified,
            'Certificates',
          ),
          _item(
            context,
            Icons.face,
            'Face / Eye Verification',
          ),
          _item(
            context,
            Icons.notifications,
            'Notifications',
          ),
          _item(
            context,
            Icons.settings,
            'Admin Settings',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
      ),
      onTap: () => open(context, title, icon),
    );
  }
}

// ================= PAYMENT PAGE =================

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final amountController = TextEditingController();
  final upiId = '9691696981-4@ybl';

  void showPaymentMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Payment'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 70,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'UPI QR Payment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'UPI ID',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      upiId,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Simple visual QR placeholder.
                    // Real scannable QR should be generated with a QR
                    // package after adding it to pubspec.yaml.
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 180,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (amountController.text.trim().isEmpty) {
                            showPaymentMessage(
                              'Amount Required',
                              'Please enter payment amount.',
                            );
                            return;
                          }

                          showPaymentMessage(
                            'UPI Payment',
                            'Open your UPI app and pay to:\n\n$upiId\n\nAmount: ₹${amountController.text}',
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('PAY USING UPI'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.credit_card),
                ),
                title: const Text(
                  'Online Payment Gateway',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Gateway integration ready',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () {
                  showPaymentMessage(
                    'Payment Gateway',
                    'Gateway screen is ready.\n\nFor live payments, merchant credentials and secure server-side payment verification are required.',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= FEATURE PAGE =================

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 12),
                  Text(
                    _description(title),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title module opened successfully'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text('Add / Manage $title'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _description(String name) {
    switch (name) {
      case 'Students':
        return 'Add, search and manage student records.';
      case 'Attendance':
        return 'Manage daily student attendance.';
      case 'Fees':
        return 'Manage student fees and payment status.';
      case 'Location':
        return 'Location/GPS module. Device location permission can be added here.';
      case 'Certificates':
        return 'Manage and generate student certificates.';
      case 'Face / Eye Verification':
        return 'Face and eye verification module.';
      case 'Notifications':
        return 'View important center notifications.';
      case 'Admin Settings':
        return 'Manage administrator and application settings.';
      default:
        return 'Course and training information.';
    }
  }
}


