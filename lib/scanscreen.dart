import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'postscanscreen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  bool isFlashOn = false;
  bool get isFrontCamera =>
      _controller?.description.lensDirection == CameraLensDirection.front;

  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: -275, end: 320).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAgain();
    }
  }

  Future<void> _checkPermissionAgain() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      if (_controller == null) {
        initCamera(); // restart camera nếu đã bật lại quyền
      }
    } else if (status.isPermanentlyDenied) {
      // user vẫn chưa cấp hoặc deny vĩnh viễn
      // có thể mở settings nếu muốn
    }
  }

  Future<void> initCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (!mounted) return;

      Navigator.pop(context);
      return;
    }

    try {
      cameras = await availableCameras();

      _controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("Camera error: $e");

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    final newCamera = _controller!.description == cameras![0]
        ? cameras![1]
        : cameras![0];

    await _controller?.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (newCamera.lensDirection == CameraLensDirection.front) {
      isFlashOn = false;
    }
    await _controller!.setFlashMode(
      isFlashOn ? FlashMode.always : FlashMode.off,
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> toggleFlash() async {
    if (_controller == null) return;

    isFlashOn = !isFlashOn;

    await _controller!.setFlashMode(
      isFlashOn ? FlashMode.torch : FlashMode.off,
    );

    setState(() {});
  }

  Future<void> openGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostScanScreen(imagePath: image.path, isFront: false),
        ),
      );
    } catch (e) {
      debugPrint("Gallery error: $e");
    }
  }

  Future<void> captureImage() async {
    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostScanScreen(
            imagePath: image.path,
            isFront:
                _controller!.description.lensDirection ==
                CameraLensDirection.front,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  Widget buildDashedLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        18,
        (index) => Container(width: 10, height: 2, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          SafeArea(
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: isFrontCamera ? null : toggleFlash,
                        child: Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: isFrontCamera
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white,
                        ),
                      ),

                      Text(
                        "onboarding_title_2".tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment(0, 0.3),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.75,
                      child: AnimatedBuilder(
                        animation: _lineAnimation,
                        builder: (_, __) {
                          final y = _lineAnimation.value;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              /// GRADIENT (moving scan area)
                              Transform.translate(
                                offset: Offset(0, y),
                                child: Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.28),
                                        Colors.white.withOpacity(0.16),
                                        Colors.white.withOpacity(0.08),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              /// DASH LINE (NEO Ở TOP EDGE của gradient)
                              Transform.translate(
                                offset: Offset(0, y - 110), // 👈 QUAN TRỌNG
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    24,
                                    (_) => Container(
                                      width: 6,
                                      height: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// BUTTONS
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      /// GALLERY
                      GestureDetector(
                        onTap: openGallery,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      /// CAPTURE
                      GestureDetector(
                        onTap: captureImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// SWITCH CAMERA
                      GestureDetector(
                        onTap: switchCamera,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Icon(
                            Icons.cameraswitch,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
