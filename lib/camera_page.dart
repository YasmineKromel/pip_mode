
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:floating/floating.dart';
import 'package:pip_mode/preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final floating = Floating();
  CameraController? _controller;
  bool _isCameraInitialized = false;
  // bool showButtons = true;
  late final List<CameraDescription> _cameras;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      floating.enable(aspectRatio: const Rational.vertical());
    }
    // App state changed before we got the chance to initialize.
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      //    onNewCameraSelected(cameraController.description);
    }
  }

  // Future<void> enablePip(BuildContext context) async {
  //   setState(() {
  //     showButtons = false;
  //   });
  //   const rational = Rational.landscape();
  //   final screenSize =
  //       MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
  //   final height = screenSize.width ~/ rational.aspectRatio;
  //
  //   final status = await floating.enable(
  //     aspectRatio: rational,
  //     sourceRectHint: Rectangle<int>(
  //       0,
  //       (screenSize.height ~/ 2) - (height ~/ 2),
  //       screenSize.width.toInt(),
  //       height,
  //     ),
  //   );
  //   debugPrint('PiP enabled? $status');
  // }

  @override
  void dispose() {
    debugPrint('+++++++++++++++++++++++++++++++++++++++++++++++++');
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    floating.dispose();
    super.dispose();
  }

  Future<XFile?> capturePhoto() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off);
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<XFile?> captureVideo() async {
    final CameraController? cameraController = _controller;
    try {
      setState(() {
        _isRecording = true;
      });
      await cameraController?.startVideoRecording();
      await Future.delayed(const Duration(seconds: 20));
      final video = await cameraController?.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      return video;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void _onTakePhotoPressed() async {
    final navigator = Navigator.of(context);
    final xFile = await capturePhoto();
    if (xFile != null) {
      if (xFile.path.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              imagePath: xFile.path,
            ),
          ),
        );
      }
    }
  }

  void _onRecordVideoPressed() async {
    final navigator = Navigator.of(context);
    final xFile = await captureVideo();
    if (xFile != null) {
      if (xFile.path.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              videoPath: xFile.path,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitialized) {
      return PiPSwitcher(
        childWhenEnabled: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Expanded(child: CameraPreview(_controller!)),
              ],
            ),
          ),
        ),
        childWhenDisabled: SafeArea(
          child: Scaffold(
              body: Column(
                children: [
                  Expanded(child: CameraPreview(_controller!)),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isRecording)
                        ElevatedButton(
                          onPressed: _onTakePhotoPressed,
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(70, 70),
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      if (!_isRecording) const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: _isRecording ? null : _onRecordVideoPressed,
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.videocam,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    // showButtons = true;
    final previousCameraController = _controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }
}