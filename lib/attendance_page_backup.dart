
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

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

  String _status = 'Camera starting...';

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _status = 'Camera available nahi hai';
        });
        return;
      }

      CameraDescription frontCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      _cameraController = controller;

      if (!mounted) return;

      setState(() {
        _cameraReady = true;
        _status = 'Face ke saamne dekhein';
      });

      await controller.startImageStream(_processCameraImage);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Camera error';
      });

      debugPrint('Camera error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_processing || _attendanceMarked) return;

    _processing = true;

    try {
      final inputImage = _convertCameraImage(image);

      if (inputImage == null) {
        _processing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) {
        _processing = false;
        return;
      }

      if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
          _eyesClosed = false;
          _status = 'Face detect nahi hua';
        });
      } else {
        final face = faces.first;

        final leftEye = face.leftEyeOpenProbability;
        final rightEye = face.rightEyeOpenProbability;

        setState(() {
          _faceDetected = true;
        });

        if (leftEye != null && rightEye != null) {
          final bothClosed = leftEye < 0.30 && rightEye < 0.30;
          final bothOpen = leftEye > 0.70 && rightEye > 0.70;

          if (bothClosed) {
            _eyesClosed = true;

            setState(() {
              _status = 'Eyes closed — Blink detected...';
            });
          }

          if (bothOpen && _eyesClosed) {
            _blinkDetected = true;
            _eyesClosed = false;

            setState(() {
              _status = 'Face + Eye Blink verified ✓';
            });

            await Future.delayed(
              const Duration(milliseconds: 500),
            );

            await _markAttendance();
          }
        } else {
          setState(() {
            _status = 'Face detected — Blink karein';
          });
        }
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    }

    _processing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final controller = _cameraController;

      if (controller == null) return null;

      final camera = controller.description;

      final rotation =
          InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );

      if (rotation == null) return null;

      final format =
          InputImageFormatValue.fromRawValue(
        image.format.raw,
      );

      if (format == null) return null;

      final WriteBuffer allBytes = WriteBuffer();

      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final Uint8List bytes =
          allBytes.done().buffer.asUint8List();

      final metadata = InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Image conversion error: $e');
      return null;
    }
  }

  Future<void> _markAttendance() async {
    if (_attendanceMarked) return;

    _attendanceMarked = true;

    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _status = 'Attendance Marked Successfully ✓';
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attendance Successful'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 70,
              ),
              SizedBox(height: 15),
              Text(
                'Face + Eye Blink Verified',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Student Present ✓',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Attendance'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: !_cameraReady ||
              controller == null ||
              !controller.value.isInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(_status),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CameraPreview(controller),
                      ),

                      Container(
                        width: 260,
                        height: 330,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _faceDetected
                                ? Colors.green
                                : Colors.orange,
                            width: 4,
                          ),
                          borderRadius:
                              BorderRadius.circular(130),
                        ),
                      ),

                      Positioned(
                        bottom: 25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                          child: Text(
                            _status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _verificationItem(
                        Icons.face,
                        'Face',
                        _faceDetected,
                      ),
                      _verificationItem(
                        Icons.remove_red_eye,
                        'Blink',
                        _blinkDetected,
                      ),
                      _verificationItem(
                        Icons.verified,
                        'Verified',
                        _attendanceMarked,
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    'Camera ke saamne face rakhein aur ek baar naturally blink karein.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _verificationItem(
    IconData icon,
    String title,
    bool verified,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
              verified ? Colors.green : Colors.grey.shade300,
          child: Icon(
            icon,
            color: verified
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(title),
      ],
    );
  }
}
            
