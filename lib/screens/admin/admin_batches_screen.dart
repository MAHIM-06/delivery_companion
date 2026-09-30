import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/delivery_batch_model.dart';
import '../../services/delivery_batch_service.dart';

class AdminBatchesScreen
    extends StatefulWidget {
  const AdminBatchesScreen({
    super.key,
  });

  @override
  State<AdminBatchesScreen> createState() =>
      _AdminBatchesScreenState();
}

class _AdminBatchesScreenState
    extends State<AdminBatchesScreen> {
  final DeliveryBatchService
      _batchService =
      DeliveryBatchService();

  bool isCreatingBatches = false;

  // ============================================================
  // CREATE BATCHES
  // ============================================================

  Future<void> createBatches() async {
    setState(() {
      isCreatingBatches = true;
    });

    try {
      await _batchService.createBatches();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Batches created successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create batches: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingBatches = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Batches',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: isCreatingBatches
            ? null
            : createBatches,

        icon: isCreatingBatches
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.auto_awesome,
              ),

        label: Text(
          isCreatingBatches
              ? 'Creating...'
              : 'Create Batches',
        ),
      ),

      body: StreamBuilder<
          List<DeliveryBatchModel>>(
        stream:
            _batchService.getAllBatches(),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign:
                    TextAlign.center,
              ),
            );
          }

          final batches =
              snapshot.data ?? [];

          if (batches.isEmpty) {
            return const Center(
              child: Text(
                'No delivery batches found.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),

            itemCount: batches.length,

            itemBuilder: (
              context,
              index,
            ) {
              return AdminBatchCard(
                batch: batches[index],
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// ADMIN BATCH CARD
// ============================================================

class AdminBatchCard
    extends StatelessWidget {
  final DeliveryBatchModel batch;

  const AdminBatchCard({
    super.key,
    required this.batch,
  });

  String getStatusLabel() {
    switch (batch.status) {
      case 'created':
        return 'Waiting for Assignment';

      case 'assigned':
        return 'Assigned';

      case 'in_progress':
        return 'In Progress';

      case 'completed':
        return 'Completed';

      default:
        return batch.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canAssign =
        batch.status == 'created';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Delivery Batch',
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Area: ${batch.area}',
            ),

            const SizedBox(height: 5),

            Text(
              'Date: '
              '${batch.scheduledDate.day}/'
              '${batch.scheduledDate.month}/'
              '${batch.scheduledDate.year}',
            ),

            const SizedBox(height: 5),

            Text(
              'Time: '
              '${batch.startTime} - '
              '${batch.endTime}',
            ),

            const SizedBox(height: 5),

            Text(
              'Orders: '
              '${batch.orderIds.length}',
            ),

            const SizedBox(height: 5),

            Text(
              'Status: '
              '${getStatusLabel()}',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            if (batch.deliveryPersonId !=
                null) ...[
              const SizedBox(height: 5),

              Text(
                'Delivery Person: '
                '${batch.deliveryPersonId}',
              ),
            ],

            const SizedBox(height: 15),

            if (canAssign)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    showAssignDialog(
                      context,
                      batch,
                    );
                  },

                  icon: const Icon(
                    Icons.person_add,
                  ),

                  label: const Text(
                    'Assign Delivery Person',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ASSIGN DIALOG
  // ============================================================

  void showAssignDialog(
    BuildContext context,
    DeliveryBatchModel batch,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AssignBatchDialog(
          batch: batch,
        );
      },
    );
  }
}

// ============================================================
// ASSIGN BATCH DIALOG
// ============================================================

class AssignBatchDialog
    extends StatefulWidget {
  final DeliveryBatchModel batch;

  const AssignBatchDialog({
    super.key,
    required this.batch,
  });

  @override
  State<AssignBatchDialog> createState() =>
      _AssignBatchDialogState();
}

class _AssignBatchDialogState
    extends State<AssignBatchDialog> {
  String? selectedDeliveryPersonId;

  bool isAssigning = false;

  final DeliveryBatchService
      _batchService =
      DeliveryBatchService();

  Future<void> assign() async {
    if (selectedDeliveryPersonId ==
        null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a delivery person.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isAssigning = true;
    });

    try {
      await _batchService.assignBatch(
        batchId: widget.batch.id,
        deliveryPersonId:
            selectedDeliveryPersonId!,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Batch assigned successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Assignment failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Assign Delivery Person',
      ),

      content: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
            );
          }

          final deliveryPersons =
              snapshot.data?.docs ?? [];

          if (deliveryPersons.isEmpty) {
            return const Text(
              'No delivery persons found.',
            );
          }

          return DropdownButtonFormField<
              String>(
            decoration:
                const InputDecoration(
              labelText:
                  'Delivery Person',
              border:
                  OutlineInputBorder(),
            ),

            value:
                selectedDeliveryPersonId,

            items: deliveryPersons
                .map((document) {
              final data =
                  document.data();

              final name =
                  data['name'] ??
                  'Unknown';

              final phone =
                  data['phone'] ??
                  '';

              return DropdownMenuItem<
                  String>(
                value: document.id,

                child: Text(
                  phone.isEmpty
                      ? name
                      : '$name - $phone',
                ),
              );
            }).toList(),

            onChanged: isAssigning
                ? null
                : (value) {
                    setState(() {
                      selectedDeliveryPersonId =
                          value;
                    });
                  },
          );
        },
      ),

      actions: [

        TextButton(
          onPressed: isAssigning
              ? null
              : () {
                  Navigator.pop(
                    context,
                  );
                },
          child: const Text(
            'Cancel',
          ),
        ),

        ElevatedButton(
          onPressed:
              isAssigning
                  ? null
                  : assign,

          child: isAssigning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Assign',
                ),
        ),
      ],
    );
  }
}