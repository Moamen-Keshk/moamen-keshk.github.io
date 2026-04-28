import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/app/api/view_models/rate_plan.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/rate_plan_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/revenue.model.dart';
import 'package:lotel_pms/infrastructure/api/res/revenue.service.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class RevenueOptimizationView extends ConsumerStatefulWidget {
  const RevenueOptimizationView({super.key});

  @override
  ConsumerState<RevenueOptimizationView> createState() =>
      _RevenueOptimizationViewState();
}

class _RevenueOptimizationViewState
    extends ConsumerState<RevenueOptimizationView> {
  final RevenueService _service = RevenueService();

  bool _loading = false;
  List<String> _channelCodes = const ['direct'];
  String? _selectedSellableTypeId;
  String? _selectedRatePlanId;
  String _selectedChannelCode = 'direct';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));

  RevenuePolicy? _policy;
  List<RevenueRecommendation> _recommendations = const [];
  List<DailyRevenueRate> _dailyRates = const [];
  List<MarketEventModel> _events = const [];

  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  final TextEditingController _highOccupancyController =
      TextEditingController();
  final TextEditingController _lowOccupancyController = TextEditingController();
  final TextEditingController _highUpliftController = TextEditingController();
  final TextEditingController _lowDiscountController = TextEditingController();
  final TextEditingController _shortLeadDaysController =
      TextEditingController();
  final TextEditingController _shortLeadPctController = TextEditingController();
  final TextEditingController _longLeadDaysController = TextEditingController();
  final TextEditingController _longLeadPctController = TextEditingController();
  final TextEditingController _pickupWindowController = TextEditingController();
  final TextEditingController _pickupPctController = TextEditingController();
  final TextEditingController _channelAdjustmentController =
      TextEditingController();
  final TextEditingController _autoApplyController = TextEditingController();

  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    _highOccupancyController.dispose();
    _lowOccupancyController.dispose();
    _highUpliftController.dispose();
    _lowDiscountController.dispose();
    _shortLeadDaysController.dispose();
    _shortLeadPctController.dispose();
    _longLeadDaysController.dispose();
    _longLeadPctController.dispose();
    _pickupWindowController.dispose();
    _pickupPctController.dispose();
    _channelAdjustmentController.dispose();
    _autoApplyController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  Future<void> _ensureLoaded() async {
    final propertyId = ref.read(selectedPropertyVM);
    final categories = ref.read(categoryListVM);
    final ratePlans = ref.read(ratePlanListVM);

    if (propertyId == null || categories.isEmpty || ratePlans.isEmpty) {
      return;
    }

    _selectedSellableTypeId ??= categories.first.id;

    final applicableRatePlans = _ratePlansForSellableType(ratePlans);
    if (_selectedRatePlanId == null && applicableRatePlans.isNotEmpty) {
      _selectedRatePlanId = applicableRatePlans.first.id;
    }

    if (_policy == null && !_loading) {
      await _refreshAll(forceMetadata: true);
    }
  }

  List<RatePlanVM> _ratePlansForSellableType(List<RatePlanVM> ratePlans) {
    if (_selectedSellableTypeId == null) {
      return const [];
    }
    return ratePlans
        .where((plan) => plan.categoryId == _selectedSellableTypeId)
        .toList();
  }

  Future<void> _refreshAll({bool forceMetadata = false}) async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null || _selectedSellableTypeId == null) {
      return;
    }

    setState(() => _loading = true);
    try {
      if (forceMetadata) {
        final metadata = await _service.getMetadata(propertyId);
        final channels =
            (metadata['channel_codes'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList();
        if (channels.isNotEmpty) {
          _channelCodes = channels;
          if (!_channelCodes.contains(_selectedChannelCode)) {
            _selectedChannelCode = _channelCodes.first;
          }
        }
      }

      final policies = await _service.getPolicies(
        propertyId,
        sellableTypeId: _selectedSellableTypeId,
        channelCode: _selectedChannelCode,
      );
      _policy = policies.isNotEmpty
          ? policies.first
          : RevenuePolicy.empty(
              propertyId: propertyId,
              sellableTypeId: _selectedSellableTypeId!,
              channelCode: _selectedChannelCode,
            );
      _syncPolicyControllers();

      _recommendations = await _service.getRecommendations(
        propertyId,
        startDate: _startDate,
        endDate: _endDate,
        sellableTypeId: _selectedSellableTypeId,
        ratePlanId: _selectedRatePlanId,
        channelCode: _selectedChannelCode,
      );
      _dailyRates = await _service.getDailyRates(
        propertyId,
        startDate: _startDate,
        endDate: _endDate,
        sellableTypeId: _selectedSellableTypeId,
        ratePlanId: _selectedRatePlanId,
        channelCode: _selectedChannelCode,
      );
      _events = await _service.getEvents(
        propertyId,
        sellableTypeId: _selectedSellableTypeId,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _syncPolicyControllers() {
    final policy = _policy;
    if (policy == null) {
      return;
    }
    _minRateController.text = policy.minRate?.toStringAsFixed(2) ?? '';
    _maxRateController.text = policy.maxRate?.toStringAsFixed(2) ?? '';
    _highOccupancyController.text =
        policy.highOccupancyThreshold.toStringAsFixed(2);
    _lowOccupancyController.text =
        policy.lowOccupancyThreshold.toStringAsFixed(2);
    _highUpliftController.text =
        policy.highOccupancyUpliftPct.toStringAsFixed(2);
    _lowDiscountController.text =
        policy.lowOccupancyDiscountPct.toStringAsFixed(2);
    _shortLeadDaysController.text = policy.shortLeadTimeDays.toString();
    _shortLeadPctController.text = policy.shortLeadUpliftPct.toStringAsFixed(2);
    _longLeadDaysController.text = policy.longLeadTimeDays.toString();
    _longLeadPctController.text = policy.longLeadDiscountPct.toStringAsFixed(2);
    _pickupWindowController.text = policy.pickupWindowDays.toString();
    _pickupPctController.text = policy.pickupUpliftPct.toStringAsFixed(2);
    _channelAdjustmentController.text =
        policy.channelAdjustmentPct.toStringAsFixed(2);
    _autoApplyController.text =
        policy.autoApplyMinConfidence.toStringAsFixed(2);
  }

  RevenuePolicy _buildPolicyFromControllers() {
    final current = _policy!;
    double? parseNullable(String value) =>
        value.trim().isEmpty ? null : double.tryParse(value.trim());
    int parseInt(String value, int fallback) =>
        int.tryParse(value.trim()) ?? fallback;
    double parseDouble(String value, double fallback) =>
        double.tryParse(value.trim()) ?? fallback;

    return current.copyWith(
      minRate: parseNullable(_minRateController.text),
      maxRate: parseNullable(_maxRateController.text),
      highOccupancyThreshold: parseDouble(
          _highOccupancyController.text, current.highOccupancyThreshold),
      lowOccupancyThreshold: parseDouble(
          _lowOccupancyController.text, current.lowOccupancyThreshold),
      highOccupancyUpliftPct: parseDouble(
          _highUpliftController.text, current.highOccupancyUpliftPct),
      lowOccupancyDiscountPct: parseDouble(
          _lowDiscountController.text, current.lowOccupancyDiscountPct),
      shortLeadTimeDays:
          parseInt(_shortLeadDaysController.text, current.shortLeadTimeDays),
      shortLeadUpliftPct:
          parseDouble(_shortLeadPctController.text, current.shortLeadUpliftPct),
      longLeadTimeDays:
          parseInt(_longLeadDaysController.text, current.longLeadTimeDays),
      longLeadDiscountPct:
          parseDouble(_longLeadPctController.text, current.longLeadDiscountPct),
      pickupWindowDays:
          parseInt(_pickupWindowController.text, current.pickupWindowDays),
      pickupUpliftPct:
          parseDouble(_pickupPctController.text, current.pickupUpliftPct),
      channelAdjustmentPct: parseDouble(
        _channelAdjustmentController.text,
        current.channelAdjustmentPct,
      ),
      autoApplyMinConfidence: parseDouble(
        _autoApplyController.text,
        current.autoApplyMinConfidence,
      ),
    );
  }

  Future<void> _savePolicy() async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null || _policy == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      final saved = await _service.savePolicy(
        propertyId,
        _buildPolicyFromControllers(),
      );
      setState(() => _policy = saved);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenue policy saved.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _recomputeRecommendations() async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.recomputeRecommendations(
        propertyId,
        startDate: _startDate,
        endDate: _endDate,
        sellableTypeId: _selectedSellableTypeId,
        ratePlanId: _selectedRatePlanId,
        channelCode: _selectedChannelCode,
      );
      await _refreshAll();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenue recommendations refreshed.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _applyRecommendation(
      RevenueRecommendation recommendation) async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.applyRecommendation(propertyId, recommendation.id);
      await _refreshAll();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showOverrideDialog(DailyRevenueRate rate) async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null) {
      return;
    }
    final controller =
        TextEditingController(text: rate.amount.toStringAsFixed(2));
    bool lock = rate.isLocked;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Override ${_dateFormat.format(rate.stayDate)}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: lock,
                    onChanged: (value) => setDialogState(() => lock = value),
                    title: const Text('Lock override'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (rate.sourceType != 'rate_plan')
                  TextButton(
                    onPressed: () async {
                      await _service.resetDailyRate(
                        propertyId,
                        sellableTypeId: rate.sellableTypeId,
                        ratePlanId: rate.ratePlanId,
                        stayDate: rate.stayDate,
                        channelCode: rate.channelCode,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                      await _refreshAll();
                    },
                    child: const Text('Reset'),
                  ),
                FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text.trim());
                    if (amount == null) {
                      return;
                    }
                    await _service.overrideDailyRate(
                      propertyId,
                      sellableTypeId: rate.sellableTypeId,
                      ratePlanId: rate.ratePlanId,
                      stayDate: rate.stayDate,
                      channelCode: rate.channelCode,
                      amount: amount,
                      lock: lock,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                    await _refreshAll();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  Future<void> _showEventDialog({MarketEventModel? existing}) async {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId == null || _selectedSellableTypeId == null) {
      return;
    }

    final nameController = TextEditingController(text: existing?.name ?? '');
    final upliftController = TextEditingController(
      text: (existing?.upliftPct ?? 0).toStringAsFixed(2),
    );
    final deltaController = TextEditingController(
      text: (existing?.flatDelta ?? 0).toStringAsFixed(2),
    );
    DateTime startDate = existing?.startDate ?? _startDate;
    DateTime endDate = existing?.endDate ?? _endDate;
    bool isActive = existing?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate({required bool isStart}) async {
              final picked = await showDatePicker(
                context: context,
                initialDate: isStart ? startDate : endDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked == null) {
                return;
              }
              setDialogState(() {
                if (isStart) {
                  startDate = picked;
                  if (endDate.isBefore(startDate)) {
                    endDate = startDate;
                  }
                } else {
                  endDate = picked;
                }
              });
            }

            return AlertDialog(
              title: Text(existing == null ? 'Add Market Event' : 'Edit Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Event name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: upliftController,
                      decoration: const InputDecoration(
                        labelText: 'Uplift %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deltaController,
                      decoration: const InputDecoration(
                        labelText: 'Flat delta',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickDate(isStart: true),
                            child:
                                Text('Start ${_dateFormat.format(startDate)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickDate(isStart: false),
                            child: Text('End ${_dateFormat.format(endDate)}'),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) =>
                          setDialogState(() => isActive = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final event = MarketEventModel(
                      id: existing?.id ?? '',
                      sellableTypeId: _selectedSellableTypeId!,
                      name: nameController.text.trim(),
                      startDate: startDate,
                      endDate: endDate,
                      upliftPct:
                          double.tryParse(upliftController.text.trim()) ?? 0.0,
                      flatDelta:
                          double.tryParse(deltaController.text.trim()) ?? 0.0,
                      isActive: isActive,
                    );
                    if (existing == null) {
                      await _service.createEvent(propertyId, event);
                    } else {
                      await _service.updateEvent(propertyId, event);
                    }
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                    await _refreshAll();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    nameController.dispose();
    upliftController.dispose();
    deltaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListVM);
    final ratePlans = ref.watch(ratePlanListVM);
    final isCompact = context.showCompactLayout;
    final applicableRatePlans = _ratePlansForSellableType(ratePlans);

    if (_selectedRatePlanId != null &&
        applicableRatePlans.every((plan) => plan.id != _selectedRatePlanId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedRatePlanId =
              applicableRatePlans.isEmpty ? null : applicableRatePlans.first.id;
        });
      });
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _refreshAll(forceMetadata: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilters(categories, applicableRatePlans, isCompact),
              const SizedBox(height: 16),
              _buildPolicyCard(isCompact),
              const SizedBox(height: 16),
              _buildRecommendationsCard(),
              const SizedBox(height: 16),
              _buildDailyRatesCard(),
              const SizedBox(height: 16),
              _buildEventsCard(),
            ],
          ),
        ),
        if (_loading)
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(
    List<CategoryVM> categories,
    List<RatePlanVM> applicableRatePlans,
    bool isCompact,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isCompact ? double.infinity : 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSellableTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Room Type',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedSellableTypeId = value;
                        _selectedRatePlanId = null;
                      });
                      await _refreshAll();
                    },
                  ),
                ),
                SizedBox(
                  width: isCompact ? double.infinity : 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRatePlanId,
                    decoration: const InputDecoration(
                      labelText: 'Rate Plan',
                      border: OutlineInputBorder(),
                    ),
                    items: applicableRatePlans
                        .map(
                          (plan) => DropdownMenuItem(
                            value: plan.id,
                            child: Text(plan.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      setState(() => _selectedRatePlanId = value);
                      await _refreshAll();
                    },
                  ),
                ),
                SizedBox(
                  width: isCompact ? double.infinity : 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedChannelCode,
                    decoration: const InputDecoration(
                      labelText: 'Channel',
                      border: OutlineInputBorder(),
                    ),
                    items: _channelCodes
                        .map(
                          (channel) => DropdownMenuItem(
                            value: channel,
                            child: Text(channel),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedChannelCode = value);
                      await _refreshAll();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      initialDateRange:
                          DateTimeRange(start: _startDate, end: _endDate),
                    );
                    if (picked == null) {
                      return;
                    }
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                    });
                    await _refreshAll();
                  },
                  child: Text(
                    'Window ${_dateFormat.format(_startDate)} to ${_dateFormat.format(_endDate)}',
                  ),
                ),
                FilledButton.icon(
                  onPressed: _selectedRatePlanId == null
                      ? null
                      : _recomputeRecommendations,
                  icon: const Icon(Icons.auto_graph),
                  label: const Text('Recompute'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(bool isCompact) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Policy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _numberField(_minRateController, 'Min Rate', isCompact),
                _numberField(_maxRateController, 'Max Rate', isCompact),
                _numberField(_highOccupancyController,
                    'High Occupancy Threshold', isCompact),
                _numberField(_lowOccupancyController, 'Low Occupancy Threshold',
                    isCompact),
                _numberField(_highUpliftController, 'High Occupancy Uplift %',
                    isCompact),
                _numberField(_lowDiscountController, 'Low Occupancy Discount %',
                    isCompact),
                _numberField(
                    _shortLeadDaysController, 'Short Lead Days', isCompact),
                _numberField(
                    _shortLeadPctController, 'Short Lead Uplift %', isCompact),
                _numberField(
                    _longLeadDaysController, 'Long Lead Days', isCompact),
                _numberField(
                    _longLeadPctController, 'Long Lead Discount %', isCompact),
                _numberField(
                    _pickupWindowController, 'Pickup Window Days', isCompact),
                _numberField(
                    _pickupPctController, 'Pickup Uplift %', isCompact),
                _numberField(_channelAdjustmentController,
                    'Channel Adjustment %', isCompact),
                _numberField(
                    _autoApplyController, 'Auto-Apply Confidence', isCompact),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _policy == null ? null : _savePolicy,
              child: const Text('Save Policy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    bool isCompact,
  ) {
    return SizedBox(
      width: isCompact ? double.infinity : 220,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_recommendations.isEmpty)
              const Text('No recommendations for the selected window.')
            else
              ..._recommendations.map(
                (recommendation) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${_dateFormat.format(recommendation.stayDate)}  £${recommendation.baselineAmount.toStringAsFixed(2)} → £${recommendation.recommendedAmount.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    '${recommendation.channelCode}  confidence ${(recommendation.confidenceScore * 100).toStringAsFixed(0)}%  ${recommendation.reasonCodes.join(', ')}',
                  ),
                  trailing: FilledButton(
                    onPressed: () => _applyRecommendation(recommendation),
                    child: const Text('Apply'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Rates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_dailyRates.isEmpty)
              const Text('No daily rate rows found for the selected filters.')
            else
              ..._dailyRates.map(
                (rate) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${_dateFormat.format(rate.stayDate)}  £${rate.amount.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    'base £${rate.baseAmount.toStringAsFixed(2)}  ${rate.channelCode}  ${rate.sourceType}${rate.isLocked ? '  locked' : ''}',
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _showOverrideDialog(rate),
                    child: const Text('Override'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Market Events',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _selectedSellableTypeId == null
                      ? null
                      : () => _showEventDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Event'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_events.isEmpty)
              const Text('No event uplifts configured for this room type.')
            else
              ..._events.map(
                (event) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(event.name),
                  subtitle: Text(
                    '${_dateFormat.format(event.startDate)} to ${_dateFormat.format(event.endDate)}  uplift ${event.upliftPct.toStringAsFixed(1)}%  delta £${event.flatDelta.toStringAsFixed(2)}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEventDialog(existing: event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final propertyId = ref.read(selectedPropertyVM);
                          if (propertyId == null) {
                            return;
                          }
                          await _service.deleteEvent(propertyId, event.id);
                          await _refreshAll();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
