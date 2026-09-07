import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AttendancePage extends StatefulWidget {
  final String? studentId;
  final String? course;

  const AttendancePage({
    super.key,
    this.studentId,
    this.course,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();

  CameraController? _cameraController;
  late final FaceDetector _faceDetector;

  bool _cameraReady = false;
  bool _processing = false;
  bool _faceDetected = false;
  bool _eyesClosed = false;
  bool _blinkDetected = false;
  bool _attendanceMarked = false;

  String _status = 'Details भरें और Start Verification दबाएँ।';

  @override
  void initState() {
    super.initState();

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

      try {
        await File(image.path).delete();
      } catch (_) {}

      if (!mounted) return;

      if (faces.length == 1) {
        final face = faces.first;

        final leftEye = face.leftEyeOpenProbability;
        final rightEye = face.rightEyeOpenProbability;

        setState(() {
          _faceDetected = true;
        });

        if (leftEye == null || rightEye == null) {
          setState(() {
            _status = 'Eyes detect नहीं हो रही हैं। Camera में सीधे देखें।';
          });
          return;
        }

        final eyeAverage = (leftEye + rightEye) / 2.0;

        if (eyeAverage < 0.45) {
          if (!_eyesClosed) {
            setState(() {
              _eyesClosed = true;
              _status = '👁️ Eyes closed detected. अब eyes खोलें।';
            });
          }
          return;
        }

        if (eyeAverage > 0.60) {
          if (_eyesClosed) {
            setState(() {
              _blinkDetected = true;
              _status =
                  '✅ Face Verification Successful\n'
                  '✅ Eye Blink Verification Successful';
            });

            _markAttendance();
          } else {
            setState(() {
              _eyesClosed = false;
              _status = '🙂 Face detected. Blink करें।';
            });
          }
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
          _eyesClosed = false;
          _status = 'Camera में केवल एक व्यक्ति होना चाहिए।';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Biometric processing error: $e';
        });
      }
    } finally {
      _processing = false;

      if (mounted && _cameraReady && !_attendanceMarked) {
        await Future.delayed(const Duration(milliseconds: 900));

        if (mounted && _cameraReady && !_attendanceMarked) {
          _processCamera();
        }
      }
    }
  }

  void _markAttendance() {
    if (_attendanceMarked) return;
    if (!_faceDetected || !_blinkDetected) return;

    setState(() {
      _attendanceMarked = true;
      _status =
          '✅ Face Verification Successful\n'
          '✅ Eye Blink Verification Successful\n'
          '🟢 Attendance Marked Successfully!';
    });

    _showAttendanceDialog();
  }

  Future<void> _showAttendanceDialog() async {
    final now = DateTime.now();

    await _stopCamera();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text('Attendance Marked')),
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
              Text('Date: ${now.day}/${now.month}/${now.year}'),
              const SizedBox(height: 8),
              Text(
                'Time: ${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}:'
                '${now.second.toString().padLeft(2, '0')}',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _resetVerification();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _stopCamera() async {
    _cameraReady = false;

    final controller = _cameraController;
    _cameraController = null;

    if (controller != null) {
      await controller.dispose();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _resetVerification() {
    setState(() {
      _cameraReady = false;
      _processing = false;
      _faceDetected = false;
      _eyesClosed = false;
      _blinkDetected = false;
      _attendanceMarked = false;
      _status = 'Details भरें और Start Verification दबाएँ।';
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.face_retouching_natural,
                      size: 60,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Face + Eye Blink Attendance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        prefixIcon: Icon(Icons.menu_book),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_cameraReady &&
                _cameraController != null &&
                _cameraController!.value.isInitialized)
              Card(
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _faceDetected
                          ? Icons.check_circle
                          : Icons.face,
                      color: _faceDetected
                          ? Colors.green
                          : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (!_cameraReady)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startBiometric,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Start Biometric Verification',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

            if (_cameraReady && !_attendanceMarked)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _stopCamera,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('Stop Camera'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
