import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:prototypeapp/screens/previewPage.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:sensors_plus/sensors_plus.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      //
      setState(() {
        _gyroscopeEvent = event;
      });
    });
  }

  Future<String> saveImageToGallery(XFile image) async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/TENX';
    final myImagePath = Directory(path);

    if (!(await myImagePath.exists())) {
      myImagePath.create();
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$path/$fileName';

    final imageFile = File(image.path);
    final savedImage = await imageFile.copy(filePath);

    await ImageGallerySaver.saveFile(savedImage.path);

    return savedImage.path;
  }

String formatFraction(String fraction) {
  final parts = fraction.split('/');
  if (parts.length == 2) {
    final numerator = double.tryParse(parts[0]);
    final denominator = double.tryParse(parts[1]);
    if (numerator != null && denominator != null && denominator != 0) {
      return (numerator / denominator).toStringAsFixed(1);
    }
  }
  return fraction;
}

Future<void> printImageInfo(XFile picture) async {
  // Load the image file
  final bytes = await picture.readAsBytes();
  final data = await readExifFromBytes(bytes);

  if (data!.isEmpty) {
    print('No EXIF information found');
    return;
  }

  // Extract and print the EXIF information
  final iso = data['EXIF ISOSpeedRatings']?.printable ?? 'Unknown ISO';
  final focalLength = data['EXIF FocalLength']?.printable ?? 'Unknown Focal Length';
  final aperture = data['EXIF FNumber']?.printable ?? 'Unknown Aperture';
  final exposureTime = data['EXIF ExposureTime']?.printable ?? 'Unknown Exposure Time';
  final gpsLatitude = data['EXIF GPSLatitude']?.printable ?? 'Unknown GPS Latitude';
  final gpsLongitude = data['EXIF GPSLongitude']?.printable ?? 'Unknown GPS Longitude';
  final apertureValue = data['EXIF ApertureValue']?.printable ?? 'Unknown Aperture Value';
  final make = data['EXIF Make']?.printable ?? 'Unknown Make';
  final model = data['EXIF Model']?.printable ?? 'Unknown Model';
  final exposureProgram = data['EXIF ExposureProgram']?.printable ?? 'Unknown ExposureProgram';

  // Decode the image to get its dimensions
  final image = img.decodeImage(bytes);
  final resolution = image != null ? '${image.width}x${image.height} (Approx. ${image.width * image.height ~/ 1000000}MP)' : 'Unknown Resolution';

  // Format the focal length and aperture
  final formattedFocalLength = formatFraction(focalLength);
  final formattedAperture = formatFraction(aperture);

  print('ISO: $iso');
  print('Focal Length: ${formattedFocalLength}mm');
  print('Aperture: f/$formattedAperture');
  print('Resolution: $resolution');
  print('Shutter Speed: $exposureTime');
  print('GPS Coordinate: $gpsLatitude, $gpsLongitude');
  print('Aperture Value: $apertureValue');
  print('Make: $make');
  print('Model: $model');
  print('Exposure Program: $exposureProgram');
}
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setFlashMode(FlashMode.off);
      // XFile picture2 = await _cameraController.takePicture();

      // await _cameraController.setFlashMode(FlashMode.always);
      XFile picture = await _cameraController.takePicture();
      await printImageInfo(picture);
      await saveImageToGallery(picture);
      // await saveImageToGallery(picture2);

    File imageFile = File(picture.path);
    Uint8List imageBytes = await imageFile.readAsBytes();

    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image originalImage = frameInfo.image;

    // int originalWidth = originalImage.width;
    // int originalHeight = originalImage.height;
    // double aspectRatio = originalHeight / originalWidth;
    // int newHeight = (256 * aspectRatio).round();

    // Resize the image
    // ui.PictureRecorder recorder = ui.PictureRecorder();
    // Canvas canvas = Canvas(recorder);
    // Paint paint = Paint();
    // canvas.drawImageRect(
    //   originalImage,
    //   Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
    //   Rect.fromLTWH(0, 0, 2000.toDouble(), newHeight.toDouble()),
    //   paint,
    // );

    // ui.Image resizedImage = await recorder.endRecording().toImage(2000, newHeight);
    ByteData? byteData = await originalImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      // ignore: unused_local_variable
      Uint8List resizedImageBytes = byteData.buffer.asUint8List();
    }
    Uint8List resizedImageBytes = byteData!.buffer.asUint8List();
    await imageFile.writeAsBytes(resizedImageBytes);
    double imageSizeInKB = resizedImageBytes.lengthInBytes / 1024;
    print("-----------------------------------------");
    print('Resized image size: ${imageSizeInKB.toStringAsFixed(2)} kB');
      print("-----------------------------------------");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.veryHigh);
    // await _cameraController.setZoomLevel(3.0);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
      await _cameraController.setZoomLevel(3.0);
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        
        (_cameraController.value.isInitialized)
            ? CameraPreview(_cameraController)
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 30,
                  icon: Icon(
                      _isRearCameraSelected
                          ? Icons.switch_camera
                          : Icons.switch_camera_rounded,
                      color: Colors.white),
                  onPressed: () {
                    setState(
                        () => _isRearCameraSelected = !_isRearCameraSelected);
                    initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                  },
                )),
                Expanded(
                    child: IconButton(
                  onPressed: takePicture,
                  iconSize: 50,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle, color: Colors.white),
                )),
                const Spacer(),
              ]),
            )),
            Column(
              children: [
                Container(
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(20),
                          color: Colors.grey.withOpacity(0.3),
                          child: Column(children: [
                Text(
                  'Accelerometer:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'X: ${_accelerometerEvent?.x.toStringAsFixed(3) ?? '0.000'}',
                ),
                Text(
                  'Y: ${_accelerometerEvent?.y.toStringAsFixed(3) ?? '0.000'}',
                ),
                Text(
                  'Z: ${_accelerometerEvent?.z.toStringAsFixed(3) ?? '0.000'}',
                ),
                SizedBox(height: 20),
                Text(
                  'Gyroscope:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'X: ${_gyroscopeEvent?.x.toStringAsFixed(3) ?? '0.000'}',
                ),
                Text(
                  'Y: ${_gyroscopeEvent?.y.toStringAsFixed(3) ?? '0.000'}',
                ),
                Text(
                  'Z: ${_gyroscopeEvent?.z.toStringAsFixed(3) ?? '0.000'}',
                ),
                          ],),
                        ),
              ],
            ),
      ]),
    ));
  }
}