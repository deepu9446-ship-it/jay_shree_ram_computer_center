import 'package:flutter/material.dart';

void main() {
  runApp(const JsrcStudentApp());
}

class JsrcStudentApp extends StatelessWidget {
  const JsrcStudentApp({super.key});

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
        fontFamily: 'Roboto',
      ),
      home: const StudentDashboard(),
    );
  }
}

// ============================================================
// STUDENT MODEL
// ============================================================

class StudentData {
  String studentId;
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
    required this.studentId,
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

// ============================================================
// STUDENT DASHBOARD
// ============================================================

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentData student = StudentData(
    studentId: 'JSRC-2026-001',
    name: 'Rahul Kumar',
    fatherName: 'Rajesh Kumar',
    motherName: 'Sunita Kumar',
    dob: '15/08/2005',
    aadhaar: 'XXXX-XXXX-1234',
    address: 'Chhindwara, Madhya Pradesh',
    mobile: '9876543210',
    whatsapp: '9876543210',
    email: 'rahul@gmail.com',
    course: 'PGDCA',
    admissionDate: '21/08/2026',
    feeStatus: 'Paid',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            tooltip: 'Student Profile',
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfilePage(student: student),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --------------------------------------------------
            // Welcome Card
            // --------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.deepOrange,
                    Colors.orange,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome 👋',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.studentId,
                          style: const TextStyle(
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

            const SizedBox(height: 20),

            // --------------------------------------------------
            // PROFILE BUTTON
            // --------------------------------------------------

            _dashboardButton(
              context,
              icon: Icons.person,
              title: 'Student Profile',
              subtitle: 'View & update your personal information',
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StudentProfilePage(student: student),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _dashboardButton(
              context,
              icon: Icons.menu_book,
              title: 'My Course',
              subtitle: student.course,
              color: Colors.blue,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _dashboardButton(
              context,
              icon: Icons.currency_rupee,
              title: 'Fee Status',
              subtitle: student.feeStatus,
              color: Colors.green,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _dashboardButton(
              context,
              icon: Icons.description,
              title: 'Documents',
              subtitle: 'ID & other documents',
              color: Colors.purple,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _dashboardButton(
              context,
              icon: Icons.badge,
              title: 'Student ID Card',
              subtitle: 'View / Download ID Card',
              color: Colors.indigo,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color.withOpacity(.12),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT PROFILE PAGE
// ============================================================

class StudentProfilePage extends StatefulWidget {
  final StudentData student;

  const StudentProfilePage({
    super.key,
    required this.student,
  });

  @override
  State<StudentProfilePage> createState() =>
      _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),

      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text(
          'Student Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditStudentProfilePage(student: student),
                ),
              );

              setState(() {});
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --------------------------------------------------
            // Profile Header
            // --------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.deepOrange,
                    Colors.orange,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 58,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    student.studentId,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.course,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle('Personal Information'),

            _profileTile(
              Icons.badge,
              'Student ID / Registration No.',
              student.studentId,
            ),

            _profileTile(
              Icons.person,
              'Student Name',
              student.name,
            ),

            _profileTile(
              Icons.man,
              'Father Name',
              student.fatherName,
            ),

            _profileTile(
              Icons.woman,
              'Mother Name',
              student.motherName,
            ),

            _profileTile(
              Icons.calendar_month,
              'Date of Birth',
              student.dob,
            ),

            _profileTile(
              Icons.credit_card,
              'Aadhaar Number',
              student.aadhaar,
            ),

            _sectionTitle('Contact Information'),

            _profileTile(
              Icons.location_on,
              'Address',
              student.address,
            ),

            _profileTile(
              Icons.phone,
              'Mobile Number',
              student.mobile,
            ),

            _profileTile(
              Icons.chat,
              'WhatsApp Number',
              student.whatsapp,
            ),

            _profileTile(
              Icons.email,
              'Gmail / Email',
              student.email,
            ),

            _sectionTitle('Admission Information'),

            _profileTile(
              Icons.school,
              'Course',
              student.course,
            ),

            _profileTile(
              Icons.event,
              'Admission Date',
              student.admissionDate,
            ),

            _profileTile(
              Icons.payments,
              'Fee Status',
              student.feeStatus,
              valueColor: student.feeStatus == 'Paid'
                  ? Colors.green
                  : Colors.red,
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // EDIT PROFILE BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditStudentProfilePage(student: student),
                    ),
                  );

                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // ID CARD BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.badge),
                label: const Text(
                  'View Student ID Card',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentIdCardPage(student: student),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _profileTile(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.withOpacity(.1),
          child: Icon(
            icon,
            color: Colors.deepOrange,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EDIT STUDENT PROFILE
// ============================================================

class EditStudentProfilePage extends StatefulWidget {
  final StudentData student;

  const EditStudentProfilePage({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentProfilePage> createState() =>
      _EditStudentProfilePageState();
}

class _EditStudentProfilePageState
    extends State<EditStudentProfilePage> {
  late TextEditingController nameController;
  late TextEditingController fatherController;
  late TextEditingController motherController;
  late TextEditingController dobController;
  late TextEditingController addressController;
  late TextEditingController mobileController;
  late TextEditingController whatsappController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    final s = widget.student;

    nameController = TextEditingController(text: s.name);
    fatherController = TextEditingController(text: s.fatherName);
    motherController = TextEditingController(text: s.motherName);
    dobController = TextEditingController(text: s.dob);
    addressController = TextEditingController(text: s.address);
    mobileController = TextEditingController(text: s.mobile);
    whatsappController = TextEditingController(text: s.whatsapp);
    emailController = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherController.dispose();
    motherController.dispose();
    dobController.dispose();
    addressController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    emailController.dispose();

    super.dispose();
  }

  void saveProfile() {
    final s = widget.student;

    s.name = nameController.text;
    s.fatherName = fatherController.text;
    s.motherName = motherController.text;
    s.dob = dobController.text;
    s.address = addressController.text;
    s.mobile = mobileController.text;
    s.whatsapp = whatsappController.text;
    s.email = emailController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student Profile Updated Successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),

      appBar: AppBar(
        title: const Text(
          'Edit Student Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(
              'Student Name',
              nameController,
              Icons.person,
            ),
            _field(
              'Father Name',
              fatherController,
              Icons.man,
            ),
            _field(
              'Mother Name',
              motherController,
              Icons.woman,
            ),
            _field(
              'Date of Birth',
              dobController,
              Icons.calendar_month,
            ),
            _field(
              'Address',
              addressController,
              Icons.location_on,
              maxLines: 3,
            ),
            _field(
              'Mobile Number',
              mobileController,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _field(
              'WhatsApp Number',
              whatsappController,
              Icons.chat,
              keyboardType: TextInputType.phone,
            ),
            _field(
              'Gmail / Email',
              emailController,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT ID CARD
// ============================================================

class StudentIdCardPage extends StatelessWidget {
  final StudentData student;

  const StudentIdCardPage({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF7F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.deepOrange,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'JAY SHREE RAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'COMPUTER CENTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.deepOrange,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    student.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'ID: ${student.studentId}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    'Course: ${student.course}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    'Mobile: ${student.mobile}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.feeStatus,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
