import 'package:geolocator/geolocator.dart';
import 'package:walker/common/widgets/fcm_controller.dart';

class WebServerCommunication {
  MsgController msgController = MsgController();

  final String steps;

  Position? currentPosition;

  String? currentAddress;

  String? token;

  WebServerCommunication({
    required this.steps,
    this.currentPosition,
    this.currentAddress,
    this.token,
  }) {
    _initToken();
  }

  /// Get User Token Value from Firebase Server (Unique)
  Future<void> _initToken() async {
    token = await msgController.getToken();
  }
}
