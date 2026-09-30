import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';
import 'notification_service.dart';

class OrderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final NotificationService _notificationService =
      NotificationService();

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<String> createOrder(
    OrderModel order,
  ) async {
    final document = await _firestore
        .collection('orders')
        .add(order.toMap());

    // Notify customer
    await _createCustomerNotification(
      customerId: order.customerId,
      title: 'Order Placed',
      message:
          'Your order has been placed successfully.',
      type: 'order',
      orderId: document.id,
    );

    return document.id;
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<void> clearCart() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final cartSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    for (final document in cartSnapshot.docs) {
      await document.reference.delete();
    }
  }

  // ============================================================
  // GET ALL ORDERS
  // ============================================================

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // GET CUSTOMER ORDERS
  // ============================================================

  Stream<List<OrderModel>> getMyOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where(
          'customerId',
          isEqualTo: user.uid,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // ACCEPT ORDER
  // ============================================================

  Future<void> acceptOrder(
    String orderId,
  ) async {
    await _updateStatus(
      orderId,
      'accepted',
    );
  }

  // ============================================================
  // REJECT ORDER
  // ============================================================

  Future<void> rejectOrder(
    String orderId,
  ) async {
    await _updateStatus(
      orderId,
      'rejected',
    );
  }

  // ============================================================
  // START PREPARING
  // ============================================================

  Future<void> startPreparing(
    String orderId,
  ) async {
    await _updateStatus(
      orderId,
      'preparing',
    );
  }

  // ============================================================
  // MARK READY
  // ============================================================

  Future<void> markReady(
    String orderId,
  ) async {
    await _updateStatus(
      orderId,
      'ready',
    );
  }

  // ============================================================
  // GENERAL STATUS UPDATE
  // ============================================================

  Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    await _updateStatus(
      orderId,
      status,
    );
  }

  // ============================================================
  // INTERNAL STATUS UPDATE
  // ============================================================

  Future<void> _updateStatus(
    String orderId,
    String status,
  ) async {
    final orderReference = _firestore
        .collection('orders')
        .doc(orderId);

    final orderSnapshot =
        await orderReference.get();

    if (!orderSnapshot.exists) {
      throw Exception('Order not found.');
    }

    final order = OrderModel.fromMap(
      orderSnapshot.id,
      orderSnapshot.data()!,
    );

    await orderReference.update({
      'status': status,
    });

    await _sendStatusNotification(
      customerId: order.customerId,
      orderId: orderId,
      status: status,
    );
  }

  // ============================================================
  // SEND STATUS NOTIFICATION
  // ============================================================

  Future<void> _sendStatusNotification({
    required String customerId,
    required String orderId,
    required String status,
  }) async {
    String title;
    String message;

    switch (status) {
      case 'accepted':
        title = 'Order Accepted';
        message =
            'Your order has been accepted by the store.';
        break;

      case 'preparing':
        title = 'Order Being Prepared';
        message =
            'Your order is now being prepared.';
        break;

      case 'ready':
        title = 'Order Ready';
        message =
            'Your order is ready for delivery.';
        break;

      case 'out_for_delivery':
        title = 'Out for Delivery';
        message =
            'Your order is now out for delivery.';
        break;

      case 'delivered':
        title = 'Order Delivered';
        message =
            'Your order has been delivered successfully.';
        break;

      case 'rejected':
        title = 'Order Rejected';
        message =
            'Unfortunately, your order was rejected.';
        break;

      default:
        return;
    }

    await _createCustomerNotification(
      customerId: customerId,
      title: title,
      message: message,
      type: 'order',
      orderId: orderId,
    );
  }

  // ============================================================
  // CREATE CUSTOMER NOTIFICATION
  // ============================================================

  Future<void> _createCustomerNotification({
    required String customerId,
    required String title,
    required String message,
    required String type,
    String? orderId,
  }) async {
    await _firestore
        .collection('users')
        .doc(customerId)
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

  // ============================================================
  // AVAILABLE DELIVERY ORDERS
  // ============================================================

  Stream<List<OrderModel>>
      getAvailableDeliveryOrders() {
    return _firestore
        .collection('orders')
        .where(
          'status',
          isEqualTo: 'ready',
        )
        .where(
          'deliveryPersonId',
          isNull: true,
        )
        .where(
          'batchId',
          isNull: true,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // MY DELIVERIES
  // ============================================================

  Stream<List<OrderModel>> getMyDeliveries() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where(
          'deliveryPersonId',
          isEqualTo: user.uid,
        )
        .where(
          'batchId',
          isNull: true,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // ACCEPT DELIVERY
  // ============================================================

  Future<void> acceptDelivery(
    String orderId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final orderReference = _firestore
        .collection('orders')
        .doc(orderId);

    final orderSnapshot =
        await orderReference.get();

    if (!orderSnapshot.exists) {
      throw Exception('Order not found.');
    }

    final order = OrderModel.fromMap(
      orderSnapshot.id,
      orderSnapshot.data()!,
    );

    await orderReference.update({
      'deliveryPersonId': user.uid,
      'assignedAt': Timestamp.now(),
      'status': 'out_for_delivery',
    });

    await _sendStatusNotification(
      customerId: order.customerId,
      orderId: orderId,
      status: 'out_for_delivery',
    );
  }

  // ============================================================
  // COMPLETE DELIVERY
  // ============================================================

  Future<void> completeDelivery(
    String orderId,
  ) async {
    await _updateStatus(
      orderId,
      'delivered',
    );
  }
}