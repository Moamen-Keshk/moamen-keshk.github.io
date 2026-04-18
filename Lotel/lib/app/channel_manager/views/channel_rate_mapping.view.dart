import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

import 'package:lotel_pms/app/channel_manager/models/channel_rate_plan_map.dart';
import 'package:lotel_pms/app/channel_manager/models/external_rate_plan.dart';
import 'package:lotel_pms/app/channel_manager/view_models/channel_connection_list.vm.dart';
import 'package:lotel_pms/app/channel_manager/view_models/channel_rate_mapping.vm.dart';
import 'package:lotel_pms/app/channel_manager/view_models/external_room.vm.dart'; // Holds selectedChannelIdVM
import 'package:lotel_pms/app/global/selected_property.global.dart';

// Assuming you have these! Adjust the import paths if needed.
import 'package:lotel_pms/app/api/view_models/lists/rate_plan_list.vm.dart';
import 'package:lotel_pms/app/channel_manager/views/external_rate_plan.view.dart';

class ChannelRateMappingView extends ConsumerStatefulWidget {
  final String connectionId;

  const ChannelRateMappingView({super.key, required this.connectionId});

  @override
  ConsumerState<ChannelRateMappingView> createState() =>
      _ChannelRateMappingViewState();
}

class _ChannelRateMappingViewState
    extends ConsumerState<ChannelRateMappingView> {
  @override
  void initState() {
    super.initState();
    // Set the global channel ID so External Rate Plans can fetch in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parsedId = int.tryParse(widget.connectionId);
      if (parsedId != null) {
        ref.read(selectedChannelIdVM.notifier).setChannel(parsedId);
      } else {
        debugPrint(
            "Warning: Could not parse connection ID to int: ${widget.connectionId}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.showCompactLayout;
    // Transparent Scaffold allows the FAB to float perfectly over the list
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildList(context, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMappingModal(context, ref),
        icon: const Icon(Icons.add),
        label: Text(isCompact ? 'Add' : 'Add Mapping'),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final mappingState = ref.watch(channelRateMappingVMProvider);
    final isCompact = context.showCompactLayout;

    return mappingState.when(
      data: (mappings) {
        if (mappings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No rate plans mapped yet.\nTap + to link a local rate plan to the OTA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(channelRateMappingVMProvider),
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 16, bottom: 80), // Padding for FAB
            itemCount: mappings.length,
            itemBuilder: (context, index) {
              final map = mappings[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 16,
                  vertical: 8,
                ),
                child: isCompact
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Local Rate ID: ${map.internalRatePlanId}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${map.externalRatePlanName ?? "Unknown OTA Rate"}\nOTA Rate ID: ${map.externalRatePlanId}',
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                tooltip: 'Remove Mapping',
                                onPressed: () async {
                                  final success = await ref
                                      .read(
                                          channelRateMappingVMProvider.notifier)
                                      .deleteRatePlanMapping(map.id.toString());

                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Failed to remove mapping. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          'Local Rate ID: ${map.internalRatePlanId} ↔ ${map.externalRatePlanName ?? "Unknown OTA Rate"}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text('OTA Rate ID: ${map.externalRatePlanId}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: 'Remove Mapping',
                          onPressed: () async {
                            final success = await ref
                                .read(channelRateMappingVMProvider.notifier)
                                .deleteRatePlanMapping(map.id.toString());

                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to remove mapping. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Failed to load mappings:\n$error',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => ref.invalidate(channelRateMappingVMProvider),
            )
          ],
        ),
      ),
    );
  }

  void _showAddMappingModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String? selectedInternalRateId;
    String? selectedInternalRateName;
    ExternalRatePlan? selectedExternalRate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, ref, _) {
                final isCompact = context.showCompactLayout;
                final propertyId = ref.watch(selectedPropertyVM) ?? 0;
                // Make sure `ratePlanListVM` matches whatever provider holds your local rate plans!
                final localRates = ref.watch(ratePlanListVM);
                final channelConnectionsAsync =
                    ref.watch(channelConnectionListVMProvider);
                final parsedConnectionId = int.tryParse(widget.connectionId);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: isCompact ? 16 : 24,
                    right: isCompact ? 16 : 24,
                    top: 24,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Rate Plan Mapping',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedInternalRateId,
                          decoration: const InputDecoration(
                            labelText: 'Select Local Rate Plan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          items: localRates.map((rate) {
                            return DropdownMenuItem<String>(
                              value: rate.id,
                              child: Text(rate
                                  .name), // Adjust based on your Local Rate Plan model
                            );
                          }).toList(),
                          onChanged: (value) {
                            dynamic matchedRate;
                            for (final rate in localRates) {
                              if (rate.id == value) {
                                matchedRate = rate;
                                break;
                              }
                            }
                            setModalState(() {
                              selectedInternalRateId = value;
                              selectedInternalRateName = matchedRate?.name;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a local rate plan'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (parsedConnectionId != null)
                          ExternalRatePlanSelector(
                            // Assumes you built this alongside ExternalRoomSelector!
                            channelId: parsedConnectionId,
                            selectedPlan: selectedExternalRate,
                            onChanged: (value) {
                              setModalState(() {
                                selectedExternalRate = value;
                              });
                            },
                          )
                        else
                          const InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Channel Rate Plan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.error_outline),
                            ),
                            child: Text('Invalid connection ID'),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: parsedConnectionId == null
                                ? null
                                : () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    if (selectedExternalRate == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select a channel rate plan'),
                                        ),
                                      );
                                      return;
                                    }

                                    final channelConnections =
                                        channelConnectionsAsync.value ?? [];
                                    dynamic matchingConnection;
                                    for (final connection
                                        in channelConnections) {
                                      if (connection.id ==
                                          widget.connectionId) {
                                        matchingConnection = connection;
                                        break;
                                      }
                                    }

                                    // Safely derive the channel_code from the channelCode (e.g. "Booking.com" -> "booking_com")
                                    final channelCode = matchingConnection ==
                                            null
                                        ? ''
                                        : matchingConnection.channelCode
                                            .toLowerCase()
                                            .replaceAll(
                                                RegExp(r'[^a-z0-9]+'), '_')
                                            .replaceAll(RegExp(r'^_+|_+$'), '');

                                    final success = await ref
                                        .read(channelRateMappingVMProvider
                                            .notifier)
                                        .addRatePlanMapping(
                                          ChannelRatePlanMap(
                                            id: '',
                                            propertyId: propertyId,
                                            channelCode: channelCode,
                                            internalRatePlanId:
                                                selectedInternalRateId!,
                                            internalRatePlanName:
                                                selectedInternalRateName,
                                            externalRatePlanId:
                                                selectedExternalRate!.id,
                                            externalRatePlanName:
                                                selectedExternalRate!.name,
                                          ),
                                        );

                                    if (!context.mounted) return;

                                    if (success) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Rate plan mapping added successfully'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Failed to add rate plan mapping'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            child: const Text('Save Mapping'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
