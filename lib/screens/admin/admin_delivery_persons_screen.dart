import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDeliveryPersonsScreen
    extends StatelessWidget {
  const AdminDeliveryPersonsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Persons',
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              'role',
              isEqualTo: 'delivery_person',
            )
            .snapshots(),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'No delivery persons found.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                documents.length,

            itemBuilder: (
              context,
              index,
            ) {
              final data =
                  documents[index].data()
                      as Map<String, dynamic>;

              final name =
                  data['name'] ??
                  'Unknown';

              final email =
                  data['email'] ??
                  '';

              final phone =
                  data['phone'] ??
                  'Not provided';

              final vehicle =
                  data['vehicleType'] ??
                  'Not provided';

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(
                  leading:
                      const CircleAvatar(
                    child: Icon(
                      Icons
                          .delivery_dining,
                    ),
                  ),

                  title: Text(
                    name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 8,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          email,
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Phone: $phone',
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Vehicle: $vehicle',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}