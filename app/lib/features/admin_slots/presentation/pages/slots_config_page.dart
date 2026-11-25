import 'package:flutter/material.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/widgets/app_button.dart';
import 'package:campuseats/features/admin_slots/domain/entities/slots_config.dart';
import 'package:campuseats/features/admin_slots/domain/repositories/slots_config_repository.dart';

class SlotsConfigPage extends StatefulWidget {
  const SlotsConfigPage({super.key});

  @override
  State<SlotsConfigPage> createState() => _SlotsConfigPageState();
}

class _SlotsConfigPageState extends State<SlotsConfigPage> {
  final _repository = sl<SlotsConfigRepository>();
  SlotsConfig? _config;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final res = await _repository.load();
    res.when(
      success: (cfg) => setState(() {
        _config = cfg;
        _isLoading = false;
      }),
      failure: (_) {
        // Fallback default
        setState(() {
          _config = const SlotsConfig(
            cutoffTime: '10:00',
            slots: [
              SlotConfig(id: 'slot_1', label: '11h30 - 12h00', capacity: 60),
              SlotConfig(id: 'slot_2', label: '12h00 - 12h30', capacity: 70),
              SlotConfig(id: 'slot_3', label: '12h30 - 13h00', capacity: 60),
              SlotConfig(id: 'slot_4', label: '13h00 - 13h30', capacity: 50),
            ],
          );
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _saveConfig() async {
    if (_config == null) return;
    setState(() => _isSaving = true);
    await _repository.save(_config!);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration des créneaux enregistrée avec succès !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cfg = _config!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuration des créneaux'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cutoff Time Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heure limite de commande', style: AppTextStyles.titleMedium),
                        SizedBox(height: 4),
                        Text('UTC+0 (Heure de Ouagadougou)', style: AppTextStyles.caption),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cfg.cutoffTime,
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Créneaux de passage & Capacités', style: AppTextStyles.h2),
            const SizedBox(height: 12),

            ...cfg.slots.asMap().entries.map((entry) {
              final idx = entry.key;
              final slot = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Switch(
                        value: slot.active,
                        activeColor: AppColors.primary,
                        onChanged: (active) {
                          final updatedSlots = List<SlotConfig>.from(cfg.slots);
                          updatedSlots[idx] = slot.copyWith(active: active);
                          setState(() => _config = cfg.copyWith(slots: updatedSlots));
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slot.label, style: AppTextStyles.titleMedium),
                            Text('Capacité maximale : ${slot.capacity}', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: slot.capacity > 10
                            ? () {
                                final updatedSlots = List<SlotConfig>.from(cfg.slots);
                                updatedSlots[idx] = slot.copyWith(capacity: slot.capacity - 5);
                                setState(() => _config = cfg.copyWith(slots: updatedSlots));
                              }
                            : null,
                      ),
                      Text('${slot.capacity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: () {
                          final updatedSlots = List<SlotConfig>.from(cfg.slots);
                          updatedSlots[idx] = slot.copyWith(capacity: slot.capacity + 5);
                          setState(() => _config = cfg.copyWith(slots: updatedSlots));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            AppButton(
              text: 'Enregistrer la configuration',
              isLoading: _isSaving,
              icon: const Icon(Icons.save_rounded, size: 18),
              onPressed: _saveConfig,
            ),
          ],
        ),
      ),
    );
  }
}
