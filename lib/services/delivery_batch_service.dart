import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delivery_batch_model.dart';
import '../models/order_model.dart';

class DeliveryBatchService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int maxOrdersPerBatch = 5;

  // ============================================================
  // CREATE BATCHES
  // ============================================================

  Future<void> createBatches() async {
    final snapshot = await _firestore
        .collection('orders')
        .where(
          'status',
          isEqualTo: 'ready',
        )
        .where(
          'deliveryType',
          isEqualTo: 'scheduled',
        )
        .where(
          'deliveryPersonId',
          isNull: true,
        )
        .where(
          'batchId',
          isNull: true,
        )
        .get();

    final orders = snapshot.docs.map((doc) {
      return OrderModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    if (orders.isEmpty) {
      return;
    }

    final Map<String, List<OrderModel>> groups =
        {};

    for (final order in orders) {
      if (order.scheduledDate == null ||
          order.scheduledStartTime == null ||
          order.scheduledEndTime == null) {
        continue;
      }

      final String date =
          '${order.scheduledDate!.year}-'
          '${order.scheduledDate!.month}-'
          '${order.scheduledDate!.day}';

      final String key =
          '${order.area}|'
          '$date|'
          '${order.scheduledStartTime}|'
          '${order.scheduledEndTime}';

      groups.putIfAbsent(
        key,
        () => [],
      );

      groups[key]!.add(order);
    }

    for (final group in groups.values) {
      for (
        int i = 0;
        i < group.length;
        i += maxOrdersPerBatch
      ) {
        final int end =
            (i + maxOrdersPerBatch <
                    group.length)
                ? i + maxOrdersPerBatch
                : group.length;

        final batchOrders =
            group.sublist(i, end);

        await createBatch(batchOrders);
      }
    }
  }

  // ============================================================
  // CREATE ONE BATCH
  // ============================================================

  Future<void> createBatch(
    List<OrderModel> orders,
  ) async {
    if (orders.isEmpty) {
      return;
    }

    final firstOrder = orders.first;

    final batch = DeliveryBatchModel(
      id: '',
      area: firstOrder.area,
      scheduledDate:
          firstOrder.scheduledDate!,
      startTime:
          firstOrder.scheduledStartTime!,
      endTime:
          firstOrder.scheduledEndTime!,
      orderIds: orders
          .map((order) => order.id)
          .toList(),
      deliveryPersonId: null,
      status: 'created',
      createdAt: DateTime.now(),
    );

    final batchReference =
        await _firestore
            .collection('delivery_batches')
            .add(
              batch.toMap(),
            );

    final String batchId =
        batchReference.id;

    final writeBatch =
        _firestore.batch();

    for (final order in orders) {
      final orderReference =
          _firestore
              .collection('orders')
              .doc(order.id);

      writeBatch.update(
        orderReference,
        {
          'batchId': batchId,
        },
      );
    }

    await writeBatch.commit();
  }

  // ============================================================
  // GET ALL BATCHES
  // ============================================================

  Stream<List<DeliveryBatchModel>>
      getAllBatches() {
    return _firestore
        .collection('delivery_batches')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeliveryBatchModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // ASSIGN BATCH
  // ============================================================

  Future<void> assignBatch({
    required String batchId,
    required String deliveryPersonId,
  }) async {
    final batchReference =
        _firestore
            .collection('delivery_batches')
            .doc(batchId);

    final batchSnapshot =
        await batchReference.get();

    if (!batchSnapshot.exists) {
      throw Exception(
        'Batch not found.',
      );
    }

    final batchData =
        batchSnapshot.data()!;

    final String currentStatus =
        batchData['status'] ??
            'created';

    if (currentStatus != 'created') {
      throw Exception(
        'Only unassigned batches can be assigned.',
      );
    }

    final List<String> orderIds =
        List<String>.from(
      batchData['orderIds'] ?? [],
    );

    final writeBatch =
        _firestore.batch();

    writeBatch.update(
      batchReference,
      {
        'deliveryPersonId':
            deliveryPersonId,
        'status': 'assigned',
      },
    );

    for (final orderId in orderIds) {
      final orderReference =
          _firestore
              .collection('orders')
              .doc(orderId);

      writeBatch.update(
        orderReference,
        {
          'deliveryPersonId':
              deliveryPersonId,
          'assignedAt':
              Timestamp.now(),
          'status': 'ready',
        },
      );
    }

    await writeBatch.commit();

    // Notify delivery person.
    await _createNotification(
      userId: deliveryPersonId,
      title: 'New Delivery Batch',
      message:
          'A new delivery batch has been assigned to you.',
      type: 'delivery_batch',
    );
  }

  // ============================================================
  // NOTIFY CUSTOMERS WHEN BATCH STARTS
  // ============================================================

  Future<void> notifyCustomersBatchStarted(
    List<OrderModel> orders,
  ) async {
    for (final order in orders) {
      await _createNotification(
        userId: order.customerId,
        title: 'Out for Delivery',
        message:
            'Your order is now out for delivery.',
        type: 'order',
        orderId: order.id,
      );
    }
  }

  // ============================================================
  // NOTIFY CUSTOMERS WHEN BATCH COMPLETES
  // ============================================================

  Future<void> notifyCustomersBatchCompleted(
    List<OrderModel> orders,
  ) async {
    for (final order in orders) {
      await _createNotification(
        userId: order.customerId,
        title: 'Order Delivered',
        message:
            'Your order has been delivered successfully.',
        type: 'order',
        orderId: order.id,
      );
    }
  }

  // ============================================================
  // CREATE NOTIFICATION
  // ============================================================

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? orderId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }
}