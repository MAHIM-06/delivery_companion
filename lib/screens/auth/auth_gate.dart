import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/admin_home_screen.dart';
import '../customer/customer_home_screen.dart';
import '../delivery/delivery_home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.hasError) {
  return Scaffold(
    body: Center(
      child: Text(
        'Firestore error: ${authSnapshot.error}',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final User user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'User profile not found.',
                  ),
                ),
              );
            }

            final data =
                userSnapshot.data!.data()
                    as Map<String, dynamic>;

            final String role = data['role'] ?? 'customer';

            if (role == 'admin') {
              return const AdminHomeScreen();
            }

            if (role == 'delivery_person') {
              return const DeliveryHomeScreen();
            }

            return const CustomerHomeScreen();
          },
        );
      },
    );
  }
}