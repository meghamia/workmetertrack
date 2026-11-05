import 'package:camera/camera.dart' as cam;
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class CameraController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();

  cam.CameraController? previewController; // asli camera (package wala)
  List<cam.CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  final RxBool isLoading = false.obs;
  final RxString capturedImagePath = ''.obs;
  final RxBool showConfirmDialog = false.obs;
  final RxBool isCameraInitialized = false.obs;
  final RxBool hasMultipleCameras = false.obs;

  @override
  void onInit() {
    super.onInit();
    locationController.getCurrentLocation();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await cam.availableCameras();
      if (_cameras.isEmpty) {
        Get.snackbar('Error', 'No camera found');
        return;
      }
      hasMultipleCameras.value = _cameras.length > 1;
      final front = _cameras.indexWhere(
              (c) => c.lensDirection == cam.CameraLensDirection.front);
      _cameraIndex = front >= 0 ? front : 0;
      await _startCamera();
    } catch (e) {
      Get.snackbar('Error', 'Camera error: $e');
    }
  }

  Future<void> _startCamera() async {
    final c = cam.CameraController(
      _cameras[_cameraIndex],
      cam.ResolutionPreset.medium,
      enableAudio: false,
    );
    await c.initialize();
    previewController = c;
    isCameraInitialized.value = true;
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || isLoading.value) return;
    isLoading.value = true;
    try {
      isCameraInitialized.value = false;
      final old = previewController;
      previewController = null;
      await old?.dispose();
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      await _startCamera();
    } catch (e) {
      Get.snackbar('Error', 'Camera error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Photo app de andar hi click hundi hai (image_picker nahi)
  Future<void> captureImage() async {
    final c = previewController;
    if (c == null || !isCameraInitialized.value) return;
    try {
      isLoading.value = true;
      final file = await c.takePicture();
      capturedImagePath.value = file.path;
      showConfirmDialog.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ' + e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void confirmCapture() {
    showConfirmDialog.value = false;
    Get.back(result: {
      'imagePath': capturedImagePath.value,
      'location': locationController.currentAddress.value,
      'latitude': locationController.currentLatitude.value,
      'longitude': locationController.currentLongitude.value,
    });
    capturedImagePath.value = '';
  }

  void cancelCapture() {
    showConfirmDialog.value = false;
    capturedImagePath.value = '';
  }

  void refreshLocation() {
    locationController.getCurrentLocation();
  }

  @override
  void onClose() {
    previewController?.dispose();
    super.onClose();
  }
}