
import 'package:flutter/material.dart';

import 'camera_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const CameraPage(),
      // PiPSwitcher(
      //   childWhenDisabled:
      //   const CameraPage(),
      //   childWhenEnabled:  const CameraPage(),
      // ),
      // PIPExampleApp(),
      //
    );
  }
}





// SafeArea(
// child: Scaffold(
// body: showButtons?
// Column(
// children: [
// Expanded(child: CameraPreview(_controller!)),
// const SizedBox(
// height: 35,
// ),
// Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// if (!_isRecording)
// ElevatedButton(
// onPressed: _onTakePhotoPressed,
// style: ElevatedButton.styleFrom(
// fixedSize: const Size(70, 70),
// shape: const CircleBorder(),
// backgroundColor: Colors.white),
// child: const Icon(
// Icons.camera_alt,
// color: Colors.black,
// size: 30,
// ),
// ),
// if (!_isRecording) const SizedBox(width: 15),
// ElevatedButton(
// onPressed:
// _isRecording ? null : _onRecordVideoPressed,
// style: ElevatedButton.styleFrom(
// fixedSize: const Size(70, 70),
// shape: const CircleBorder(),
// backgroundColor: Colors.white),
// child: Icon(
// _isRecording ? Icons.stop : Icons.videocam,
// color: Colors.red,
// ),
// ),
// ],
// ),
// ],
// )
//     : Column(
// children: [
// Expanded(
// child: AspectRatio(
// aspectRatio: _controller!.value.aspectRatio,
// child: CameraPreview(_controller!)),
// ),
// ],
// ),
// ),
// ),
