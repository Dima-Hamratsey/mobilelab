import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/user.dart';

class ProfileData {
  const ProfileData({required this.user, required this.stations});

  final User? user;
  final List<Station> stations;
}
