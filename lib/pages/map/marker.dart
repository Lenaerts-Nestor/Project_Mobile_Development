import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerInfo {
  final String id;
  final String parkedUserId;
  final String reservedUserId;
  final String parkedVehicleId;
  final String reservedVehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime prevEndTime;
  final bool isGreenMarker;

  MarkerInfo({
    required this.id,
    required this.parkedUserId,
    required this.reservedUserId,
    required this.parkedVehicleId,
    required this.reservedVehicleId,
    required this.startTime,
    required this.endTime,
    required this.prevEndTime,
    required this.isGreenMarker,
  });

  static MarkerInfo fromJson(Map<String, dynamic> json) => MarkerInfo(
        id: json['id'] as String? ?? '',
        parkedUserId: json['parkedUserId'] as String? ?? '',
        reservedUserId: json['reservedUserId'] as String? ?? '',
        parkedVehicleId: json['parkedVehicleId'] as String? ?? '',
        reservedVehicleId: json['reservedVehicleId'] as String? ?? '',
        startTime: (json['startTime'] as Timestamp).toDate(),
        endTime: (json['endTime'] as Timestamp).toDate(),
        prevEndTime: (json['prevEndTime'] as Timestamp).toDate(),
        isGreenMarker: json['isGreenMarker'] as bool? ?? false,
      );
}
