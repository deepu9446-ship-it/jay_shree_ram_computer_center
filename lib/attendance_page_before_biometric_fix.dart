import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AttendancePage extends StatefulWidget {
  final String? studentName;
  final String? studentId;
  final String? course;

  const AttendancePage({
    super.key,
    this.studentName,
    this.studentId,
    this.course,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CameraController? _cameraController;
  late final FaceDetector _faceDetector;

  bool _cameraReady = false;
  bool _processing = false;
  bool _faceDetected = false;
  bool _eyesClosed = false;
  bool _blinkDetected = false;
  bool _attendanceMarked = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  String _status = 'Student details भरें और biometric शुरू करें।';

  @override
  void initState() {
    super.initState();

    if (widget.studentName != null) {
      _nameController.text = widget.studentName!;
    }

    if (widget.studentId != null) {
      _studentIdController.text = widget.studentId!;
    }

    if (widget.course != null) {
      _courseController.text = widget.course!;
    }

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.15,
      ),
    );
  }

  Future<void> _startBiometric() async {
    if (_nameController.text.trim().isEmpty ||
        _studentIdController.text.trim().isEmpty ||
        _courseController.text.trim().isEmpty) {
      _showMessage('Name, Student ID और Course भरें।');
      return;
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showMessage('Device में camera नहीं मिला।');
        return;
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _cameraReady = true;
        _faceDetected = false;
        _eyesClosed = false;
        _blinkDetected = false;
        _attendanceMarked = false;
        _status = 'Camera चालू है। Camera में देखें और blink करें।';
      });

      _processCamera();
    } catch (e) {
      _showMessage('Camera error: $e');
    }
  }

  Future<void> _processCamera() async {
    if (!_cameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _processing ||
        _attendanceMarked) {
      return;
    }

    _processing = true;

    try {
      final image = await _cameraController!.takePicture();

      final inputImage = InputImage.fromFilePath(image.path);

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.length == 1) {
        final face = faces.first;

        final leftEye = face.leftEyeOpenProbability;
        final rightEye = face.rightEyeOpenProbability;

        if (leftEye != null && rightEye != null) {
          final eyeAverage = (leftEye + rightEye) / 2;

          final closed = eyeAverage < 0.30;
          final open = eyeAverage > 0.70;

          if (closed) {
            setState(() {
              _faceDetected = true;
              _eyesClosed = true;
              _status = 'Eyes closed detected. अब eyes खोलें।';
            });
          } else if (open) {
            if (_eyesClosed) {
              _markAttendance();
            } else {
              setState(() {
                _faceDetected = true;
                _eyesClosed = false;
                _status = 'Face detected. Blink करें।';
              });
            }
          }
        } else {
          setState(() {
            _faceDetected = true;
            _status = 'Face detected. Camera में सीधे देखें।';
          });
        }
      } else if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
          _eyesClosed = false;
          _status = 'Face नहीं मिला। Camera में देखें।';
        });
      } else {
        setState(() {
          _faceDetected = false;
          _status = 'Camera में केवल एक व्यक्ति होना चाहिए।';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Biometric processing error.';
        });
      }
    } finally {
      _processing = false;

      if (mounted && _cameraReady && !_attendanceMarked) {
        await Future.delayed(const Duration(milliseconds: 700));
        _processCamera();
      }
    }
  }

  void _markAttendance() {
    if (_attendanceMarked) return;

    setState(() {
      _blinkDetected = true;
      _attendanceMarked = true;
      _status = 'Attendance successfully marked!';
    });

    _showAttendanceDialog();
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final now = DateTime.now();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Attendance Marked'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${_nameController.text}'),
              const SizedBox(height: 8),
              Text('Student ID: ${_studentIdController.text}'),
              const SizedBox(height: 8),
              Text('Course: ${_courseController.text}'),
              const SizedBox(height: 8),
              Text('Time: ${_formatTime(now)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute:$second $period';
  }

  void _resetAttendance() {
    setState(() {
      _faceDetected = false;
      _eyesClosed = false;
      _blinkDetected = false;
      _attendanceMarked = false;
      _status = 'Next student के लिए ready।';
    });

    _processCamera();
  }

  Future<void> _stopCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;

    if (mounted) {
      setState(() {
        _cameraReady = false;
        _faceDetected = false;
        _eyesClosed = false;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(
    String title,
    String value,
    IconData icon,
    bool active,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: active ? Colors.green : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();

    _nameController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();

    super.dispose();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Student Details',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _field(
              'Student Name',
              _nameController,
              Icons.person,
            ),

            _field(
              'Student ID / Roll No.',
              _studentIdController,
              Icons.badge,
            ),

            _field(
              'Course',
              _courseController,
              Icons.menu_book,
            ),

            const SizedBox(height: 8),

            if (!_cameraReady)
              ElevatedButton.icon(
                onPressed: _startBiometric,
                icon: const Icon(Icons.face),
                label: const Text(
                  'START BIOMETRIC ATTENDANCE',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),

            if (_cameraReady) ...[
              const SizedBox(height: 16),

              Container(
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.black,
                ),
                clipBehavior: Clip.antiAlias,
                child: CameraPreview(_cameraController!),
              ),

              const SizedBox(height: 14),

              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              _statusCard(
                'Face',
                _faceDetected
                    ? 'Face detected'
                    : 'Face not detected',
                Icons.face,
                _faceDetected,
              ),

              _statusCard(
                'Eyes',
                _eyesClosed
                    ? 'Eyes closed'
                    : 'Waiting for blink',
                Icons.visibility,
                _eyesClosed,
              ),

              _statusCard(
                'Biometric',
                _blinkDetected
                    ? 'Blink detected'
                    : 'Waiting',
                Icons.remove_red_eye,
                _blinkDetected,
              ),

              _statusCard(
                'Attendance',
                _attendanceMarked
                    ? 'MARKED'
                    : 'Not marked',
                Icons.how_to_reg,
                _attendanceMarked,
              ),

              if (_attendanceMarked) ...[
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: _resetAttendance,
                  icon: const Icon(Icons.refresh),
                  label: const Text('NEXT STUDENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _stopCamera,
                icon: const Icon(Icons.stop),
                label: const Text('STOP CAMERA'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
