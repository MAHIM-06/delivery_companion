import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get notificationCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  // Create notification for the current user
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? orderId,
  }) async {
    await notificationCollection.add({
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Get current user's notifications
  Stream<List<NotificationModel>>
      getNotifications() {
    return notificationCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // Mark one notification as read
  Future<void> markAsRead(
    String notificationId,
  ) async {
    await notificationCollection
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final snapshot =
        await notificationCollection.get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      if (document.data()['isRead'] != true) {
        batch.update(
          document.reference,
          {
            'isRead': true,
          },
        );
      }
    }

    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(
    String notificationId,
  ) async {
    await notificationCollection
        .doc(notificationId)
        .delete();
  }

  // Count unread notifications
  Stream<int> getUnreadCount() {
    return notificationCollection
        .where(
          'isRead',
          isEqualTo: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
        );
  }
}