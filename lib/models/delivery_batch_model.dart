import 'package:cloud_firestore/cloud_firestore.dart';



class DeliveryBatchModel {
  final String id;

  final String area;

  final DateTime scheduledDate;

  final String startTime;
  final String endTime;

  final List<String> orderIds;

  final String? deliveryPersonId;

  final String status;

  final DateTime createdAt;

  DeliveryBatchModel({
    required this.id,
    required this.area,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.orderIds,
    required this.deliveryPersonId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'area': area,

      'scheduledDate':
          Timestamp.fromDate(scheduledDate),

      'startTime': startTime,
      'endTime': endTime,

      'orderIds': orderIds,

      'deliveryPersonId':
          deliveryPersonId,

      'status': status,

      'createdAt':
          Timestamp.fromDate(createdAt),
    };
  }

  factory DeliveryBatchModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return DeliveryBatchModel(
      id: id,

      area: map['area'] ?? '',

      scheduledDate:
          (map['scheduledDate'] as Timestamp)
              .toDate(),

      startTime:
          map['startTime'] ?? '',

      endTime:
          map['endTime'] ?? '',

      orderIds:
          List<String>.from(
        map['orderIds'] ?? [],
      ),

      deliveryPersonId:
          map['deliveryPersonId'],

      status:
          map['status'] ?? 'created',

      createdAt:
          (map['createdAt'] as Timestamp)
              .toDate(),
    );
  }
}