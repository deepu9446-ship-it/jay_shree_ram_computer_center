import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _cameraController = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraReady = true;
        _faceDetected = false;
        _eyesClosed = false;
        _blinkDetected = false;
        _attendanceMarked = false;
        _status = '📷 Camera चालू है। Camera में सीधे देखें।';
      });

      await controller.startImageStream(_processCameraImage);
    } catch (e) {
      await _stopCamera();

      if (mounted) {
        _showMessage('Camera error: $e');
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_processing ||
        !_cameraReady ||
        _attendanceMarked ||
        _cameraController == null) {
      return;
    }

    _processing = true;

    try {
      final inputImage = _convertCameraImage(
        image,
        _cameraController!.description,
      );

      if (inputImage == null) {
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted || _attendanceMarked) {
        return;
      }

      if (faces.length == 1) {
        final face = faces.first;

        final leftEye = face.leftEyeOpenProbability;
        final rightEye = face.rightEyeOpenProbability;

        setState(() {
          _faceDetected = true;
        });

        if (leftEye == null || rightEye == null) {
          setState(() {
            _status =
                '👤 Face मिला, लेकिन आँखें detect नहीं हो रही हैं।';
          });
          return;
        }

        final eyeAverage = (leftEye + rightEye) / 2.0;

        // Debug information
        final eyeText =
            'L:${leftEye.toStringAsFixed(2)} '
            'R:${rightEye.toStringAsFixed(2)}';

        // Eyes CLOSED
        if (eyeAverage < 0.45) {
          if (!_eyesClosed) {
            setState(() {
              _eyesClosed = true;
              _status = '😉 Blink का पहला step detected\n$eyeText';
            });
          }
          return;
        }

        // Eyes OPEN after being CLOSED = BLINK
        if (eyeAverage > 0.65 && _eyesClosed) {
          setState(() {
            _blinkDetected = true;
            _status =
                '✅ Face Verification Successful\n'
                '✅ Eye Blink Verification Successful\n'
                '🟢 Attendance Marking...';
          });

          await _markAttendance();
          return;
        }

        setState(() {
          _eyesClosed = false;
          _status =
              '👤 Face detected\n'
              '👁️ Eyes: $eyeText\n'
              '😉 एक बार blink करें।';
        });
      } else if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
          _eyesClosed = false;
          _status = '🙂 Face नहीं मिला। Camera में देखें।';
        });
      } else {
        setState(() {
          _faceDetected = false;
          _eyesClosed = false;
          _status =
              '⚠️ Camera में केवल एक व्यक्ति होना चाहिए।';
        });
      }
    } catch (e) {
      if (mounted && !_attendanceMarked) {
        setState(() {
          _status = 'Biometric processing error: $e';
        });
      }
    } finally {
      _processing = false;
    }
  }

  InputImage? _convertCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    try {
      if (image.planes.length < 2) {
        return null;
      }

      // Android YUV420 -> NV21
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final ySize = image.width * image.height;
      final uvSize = ySize ~/ 2;

      final nv21 = Uint8List(ySize + uvSize);

      int offset = 0;

      // Y plane
      for (int row = 0; row < image.height; row++) {
        final rowStart = row * yPlane.bytesPerRow;

        for (int col = 0; col < image.width; col++) {
          nv21[offset++] = yPlane.bytes[rowStart + col];
        }
      }

      // VU planes
      final uvRowStride = uPlane.bytesPerRow;
      final uvPixelStride = uPlane.bytesPerPixel ?? 1;

      for (int row = 0; row < image.height ~/ 2; row++) {
        final rowStart = row * uvRowStride;

        for (int col = 0; col < image.width ~/ 2; col++) {
          final pixel = rowStart + col * uvPixelStride;

          if (pixel < vPlane.bytes.length &&
              pixel < uPlane.bytes.length) {
            nv21[offset++] = vPlane.bytes[pixel];
            nv21[offset++] = uPlane.bytes[pixel];
          }
        }
      }

      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );

      if (rotation == null) {
        return null;
      }

      final metadata = InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );

      return InputImage.fromBytes(
        bytes: nv21,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Camera conversion error: $e');
      return null;
    }
  }

  Future<void> _markAttendance() async {
    if (_attendanceMarked) return;
    if (!_faceDetected || !_blinkDetected) return;

    _attendanceMarked = true;

    if (mounted) {
      setState(() {
        _status =
            '✅ Face Verification Successful\n'
            '✅ Eye Blink Verification Successful\n'
            '🟢 Attendance Marked Successfully!';
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    await _showAttendanceDialog();
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
              Text(
                'Student ID: ${_studentIdController.text}',
              ),
              const SizedBox(height: 8),
              Text('Course: ${_courseController.text}'),
              const SizedBox(height: 8),
              Text(
                'Date: '
                '${now.day}/${now.month}/${now.year}',
              ),
              const SizedBox(height: 8),
              Text(
                'Time: '
                '${now.hour.toString().padLeft(2, '0')}:'
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
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (_) {}

      try {
        await controller.dispose();
      } catch (_) {}
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
      _status =
          'Details भरें और Start Verification दबाएँ।';
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
                  aspectRatio:
                      _cameraController!.value.aspectRatio,
                  child: CameraPreview(
                    _cameraController!,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
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
