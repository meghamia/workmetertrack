import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/attendance_record.dart';

class LocationController extends GetxController {
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  final RxString currentAddress = 'Fetching location...'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation({int retries = 3}) async {
    isLoading.value = true;
    currentAddress.value = 'Fetching location...';

    for (int i = 0; i < retries; i++) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          final requested = await Geolocator.requestPermission();
          if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
            currentAddress.value = 'Location permission denied';
            isLoading.value = false;
            return;
          }
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        final placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          currentAddress.value = (place.street ?? '') + ', ' + (place.locality ?? '') + ', ' + (place.administrativeArea ?? '') + ' ' + (place.postalCode ?? '');
        }
        return;
      } catch (e) {
        if (i == retries - 1) {
          currentAddress.value = 'Unable to get location';
        } else {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    }
    isLoading.value = false;
  }

  AttendanceLocation getCurrentLocationData() {
    return AttendanceLocation(
      latitude: currentLatitude.value,
      longitude: currentLongitude.value,
      address: currentAddress.value,
    );
  }
}
