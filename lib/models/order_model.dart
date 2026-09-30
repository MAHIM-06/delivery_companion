import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final List<Map<String, dynamic>> items;

  final double subtotal;
  final double deliveryFee;
  final double totalAmount;

  final String address;
  final String area;

  final double? latitude;
  final double? longitude;

  final String deliveryType;
  final String status;

  final DateTime createdAt;

  final DateTime? scheduledDate;
  final String? scheduledStartTime;
  final String? scheduledEndTime;

  final String? deliveryPersonId;
  final DateTime? assignedAt;
  final String? batchId;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.deliveryType,
    required this.status,
    required this.createdAt,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.deliveryPersonId,
    required this.assignedAt,
    required this.batchId,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'items': items,

      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,

      'address': address,
      'area': area,

      'latitude': latitude,
      'longitude': longitude,

      'deliveryType': deliveryType,
      'status': status,

      'createdAt': Timestamp.fromDate(
        createdAt,
      ),

      'scheduledDate':
          scheduledDate == null
              ? null
              : Timestamp.fromDate(
                  scheduledDate!,
                ),

      'scheduledStartTime':
          scheduledStartTime,

      'scheduledEndTime':
          scheduledEndTime,

      'deliveryPersonId':
          deliveryPersonId,

      'assignedAt':
          assignedAt == null
              ? null
              : Timestamp.fromDate(
                  assignedAt!,
                ),

      'batchId': batchId,
    };
  }

  factory OrderModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return OrderModel(
      id: id,

      customerId:
          map['customerId'] ?? '',

      items:
          List<Map<String, dynamic>>.from(
        (map['items'] ?? []).map(
          (item) =>
              Map<String, dynamic>.from(
            item,
          ),
        ),
      ),

      subtotal:
          (map['subtotal'] ?? 0)
              .toDouble(),

      deliveryFee:
          (map['deliveryFee'] ?? 0)
              .toDouble(),

      totalAmount:
          (map['totalAmount'] ?? 0)
              .toDouble(),

      address:
          map['address'] ?? '',

      area:
          map['area'] ?? '',

      latitude:
          map['latitude'] == null
              ? null
              : (map['latitude'] as num)
                  .toDouble(),

      longitude:
          map['longitude'] == null
              ? null
              : (map['longitude'] as num)
                  .toDouble(),

      deliveryType:
          map['deliveryType'] ??
              'express',

      status:
          map['status'] ?? 'pending',

      createdAt:
          (map['createdAt'] as Timestamp)
              .toDate(),

      scheduledDate:
          map['scheduledDate'] == null
              ? null
              : (map['scheduledDate']
                      as Timestamp)
                  .toDate(),

      scheduledStartTime:
          map['scheduledStartTime'],

      scheduledEndTime:
          map['scheduledEndTime'],

      deliveryPersonId:
          map['deliveryPersonId'],

      assignedAt:
          map['assignedAt'] == null
              ? null
              : (map['assignedAt']
                      as Timestamp)
                  .toDate(),

      batchId:
          map['batchId'],
    );
  }
}