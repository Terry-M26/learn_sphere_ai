// Service class for checking internet connectivity
// Used to show offline banner when no internet connection

import 'dart:io'; // For InternetAddress and SocketException

// Static utility class - no instance needed, call ConnectivityService.checkInternetConnection()
class ConnectivityService {
  // Checks if device has active internet connection
  // Returns true if connected, false if offline
  static Future<bool> checkInternetConnection() async {
    try {
      // Attempt DNS lookup for google.com to verify internet access
      final result = await InternetAddress.lookup('google.com');
      // If lookup succeeds and returns valid address, we're online
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // SocketException thrown when no internet - return false
      return false;
    }
  }
}
