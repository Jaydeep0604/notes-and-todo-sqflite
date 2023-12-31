import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class TextRecognizerScreen extends StatefulWidget {
  const TextRecognizerScreen({super.key});

  @override
  State<TextRecognizerScreen> createState() => _TextRecognizerScreenState();
}

class _TextRecognizerScreenState extends State<TextRecognizerScreen>
    with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool isTorch = false;
  bool isImportImage = false;

  late final Future<void> _future;
  CameraController? _cameraController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  File? image;
  Future<bool> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return false;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      return true;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
      return false;
    }
  }

  final textRecognizer = TextRecognizer();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            isImportImage
                ? Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      title: Text(
                        "Image",
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isImportImage = false;
                              });
                            },
                            icon: Icon(
                              Icons.document_scanner,
                              color: AppColors.whiteColor,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    bottomNavigationBar: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(AppColors.blueColor),
                            ),
                            onPressed: () async {
                              final inputImage = InputImage.fromFile(image!);
                              final recognizedText =
                                  await textRecognizer.processImage(inputImage);
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NoteDetailScreen(
                                          isUpdateNote: false,
                                          scannedText: recognizedText.text),
                                ),
                              );
                            },
                            child: const Text(
                              'scan_text',
                              style: TextStyle(
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: InteractiveViewer(
                      child: Center(
                        child: Image.file(image!),
                      ),
                    ),
                  )
                : Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      title: Text(
                        "Scan",
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              pickImage().then((value) {
                                if (value == true) {
                                  setState(() {
                                    isImportImage = true;
                                  });
                                }
                              });
                            },
                            icon: Icon(
                              Icons.add_photo_alternate_rounded,
                              color: AppColors.whiteColor,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isTorch = !isTorch;
                            });
                            if (isTorch) {
                              _cameraController!.setFlashMode(FlashMode.torch);
                            } else {
                              _cameraController!.setFlashMode(FlashMode.off);
                            }
                          },
                          icon: isTorch
                              ? Icon(
                                  Icons.flashlight_on_rounded,
                                  color: AppColors.whiteColor,
                                )
                              : Icon(
                                  Icons.flashlight_off_rounded,
                                  color: AppColors.yellowColor,
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    backgroundColor:
                        _isPermissionGranted ? Colors.transparent : null,
                    body: _isPermissionGranted
                        ? Column(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                AppColors.blueColor),
                                      ),
                                      onPressed: _scanImage,
                                      child: const Text(
                                        'scan_text',
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0),
                              child: const Text(
                                'Camera permission denied',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }
  
  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFocusMode(FocusMode.auto);
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      Navigator.pop(context);
      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) => NoteDetailScreen(
              isUpdateNote: false, scannedText: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }
}
