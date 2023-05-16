import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerInfo {
  final String parkedUserId;
  final String reservedUserId;
  final String parkedVehicleId;
  final String reservedVehicleId;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime prevEndTime;
  final bool isGreenMarker;

  MarkerInfo({
    required this.latitude,
    required this.longitude,
    required this.parkedUserId,
    required this.reservedUserId,
    required this.parkedVehicleId,
    required this.reservedVehicleId,
    required this.startTime,
    required this.endTime,
    required this.prevEndTime,
    required this.isGreenMarker,
  });

  factory MarkerInfo.fromJson(Map<String, dynamic> json) {
    return MarkerInfo(
      parkedUserId: json['parkedUserId'] ?? '',
      reservedUserId: json['reservedUserId'] ?? '',
      parkedVehicleId: json['parkedVehicleId'] ?? '',
      reservedVehicleId: json['reservedVehicleId'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      prevEndTime: (json['prevEndTime'] as Timestamp).toDate(),
      isGreenMarker: json['isGreenMarker'] ?? false,
    );
  }
}
