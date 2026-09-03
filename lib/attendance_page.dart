import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool faceDetected = false;
  bool blinkDetected = false;
  bool attendanceMarked = false;

  void markAttendance() {
    setState(() {
      faceDetected = true;
      blinkDetected = true;
      attendanceMarked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance Marked Successfully ✓'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Attendance'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            const CircleAvatar(
              radius: 90,
              backgroundColor: Color(0xFFFFE0B2),
              child: Icon(
                Icons.face,
                size: 110,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Face + Eye Blink Attendance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              attendanceMarked
                  ? 'Attendance Marked Successfully ✓'
                  : 'Camera ke saamne face rakhein aur blink karein',
              style: TextStyle(
                fontSize: 16,
                color: attendanceMarked
                    ? Colors.green
                    : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            _statusCard(
              Icons.face,
              'Face Detection',
              faceDetected,
            ),

            const SizedBox(height: 12),

            _statusCard(
              Icons.remove_red_eye,
              'Eye Blink Verification',
              blinkDetected,
            ),

            const SizedBox(height: 12),

            _statusCard(
              Icons.verified,
              'Attendance',
              attendanceMarked,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: attendanceMarked ? null : markAttendance,
                icon: const Icon(Icons.fingerprint),
                label: Text(
                  attendanceMarked
                      ? 'ATTENDANCE MARKED'
                      : 'MARK ATTENDANCE',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(
    IconData icon,
    String title,
    bool verified,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              verified ? Colors.green : Colors.orange.shade100,
          child: Icon(
            icon,
            color: verified ? Colors.white : Colors.orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          verified ? Icons.check_circle : Icons.pending,
          color: verified ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}
