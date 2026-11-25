import 'package:flutter/material.dart';
import 'package:campuseats/core/theme/app_colors.dart';
import 'package:campuseats/core/theme/app_text_styles.dart';
import 'package:campuseats/core/utils/formatters.dart';
import 'package:campuseats/core/widgets/app_button.dart';

class RegisterSubscriptionPage extends StatefulWidget {
  const RegisterSubscriptionPage({super.key});

  @override
  State<RegisterSubscriptionPage> createState() => _RegisterSubscriptionPageState();
}

class _RegisterSubscriptionPageState extends State<RegisterSubscriptionPage> {
  int _currentStep = 0; // 0: Search student, 1: Duration/Payment, 2: Receipt
  final _matriculeController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _student;
  int _monthsCount = 1;
  String _paymentMethod = 'Espèces';
  bool _isSaving = false;

  void _searchStudent() async {
    final mat = _matriculeController.text.trim();
    if (mat.isEmpty) return;

    setState(() => _isSearching = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isSearching = false;
      _student = {
        'name': mat.toUpperCase().contains('STU003') ? 'Moussa Kabore' : 'Aminata Ouedraogo',
        'matricule': mat.toUpperCase(),
        'className': 'Licence 2 Sciences',
        'currentExpiration': DateTime.now().subtract(const Duration(days: 2)),
      };
      _currentStep = 1;
    });
  }

  void _confirmSubscription() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _isSaving = false;
      _currentStep = 2;
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _matriculeController.clear();
      _student = null;
      _monthsCount = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricePerMonth = 15000;
    final totalPrice = _monthsCount * pricePerMonth;
    final newExpiryDate = DateTime.now().add(Duration(days: 30 * _monthsCount));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guichet Abonnements'),
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Nouvel abonnement',
              onPressed: _reset,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: switch (_currentStep) {
            0 => _buildStep0(),
            1 => _buildStep1(totalPrice, newExpiryDate),
            _ => _buildStep2(totalPrice, newExpiryDate),
          },
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Étape 1 : Identifier l\'étudiant', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        const Text(
          'Entrez le matricule de l\'étudiant ou scannez son QR Code d\'identité au guichet.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _matriculeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Ex: STU002 ou STU003',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Rechercher le dossier',
          isLoading: _isSearching,
          icon: const Icon(Icons.search_rounded, size: 18),
          onPressed: _searchStudent,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Scanner la carte étudiante',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
          onPressed: () {
            _matriculeController.text = 'STU002';
            _searchStudent();
          },
        ),
      ],
    );
  }

  Widget _buildStep1(int totalPrice, DateTime newExpiryDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    _student!['name'][0],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_student!['name'], style: AppTextStyles.titleMedium),
                      const SizedBox(height: 2),
                      Text('Matricule : ${_student!['matricule']}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusCancelledBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Expiré', style: TextStyle(color: AppColors.statusCancelled, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Étape 2 : Durée & Paiement', style: AppTextStyles.h2),
        const SizedBox(height: 16),

        // Duration Stepper
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Durée de l\'abonnement', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text('15 000 FCFA / mois', style: AppTextStyles.caption),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      onPressed: _monthsCount > 1 ? () => setState(() => _monthsCount--) : null,
                    ),
                    Text(
                      '$_monthsCount mois',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: _monthsCount < 10 ? () => setState(() => _monthsCount++) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method Selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mode de règlement', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Espèces', 'Orange Money', 'Moov Money'].map((method) {
                    final isSel = _paymentMethod == method;
                    return ChoiceChip(
                      label: Text(method),
                      selected: isSel,
                      onSelected: (_) => setState(() => _paymentMethod = method),
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.primaryDark : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Total preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant total à encaisser :', style: AppTextStyles.titleSmall),
              Text(
                '${Fmt.price(totalPrice)} FCFA',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppButton(
          text: 'Encaisser et valider l\'abonnement',
          isLoading: _isSaving,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          onPressed: _confirmSubscription,
        ),
      ],
    );
  }

  Widget _buildStep2(int totalPrice, DateTime newExpiryDate) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.statusServedBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.statusServed, size: 56),
        ),
        const SizedBox(height: 20),
        const Text('Abonnement validé !', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text('Le compte de ${_student!['name']} a été activé.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ReceiptRow('Étudiant', _student!['name']),
                const Divider(height: 18, color: AppColors.divider),
                _ReceiptRow('Matricule', _student!['matricule']),
                const Divider(height: 18, color: AppColors.divider),
                _ReceiptRow('Durée', '$_monthsCount mois'),
                const Divider(height: 18, color: AppColors.divider),
                _ReceiptRow('Valable jusqu\'au', Fmt.fullDate(newExpiryDate)),
                const Divider(height: 18, color: AppColors.divider),
                _ReceiptRow('Mode de règlement', _paymentMethod),
                const Divider(height: 18, color: AppColors.divider),
                _ReceiptRow('Total encaissé', '${Fmt.price(totalPrice)} FCFA', isBold: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        AppButton(
          text: 'Enregistrer un autre abonnement',
          onPressed: _reset,
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.isBold = false});
  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: isBold
              ? AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)
              : AppTextStyles.titleSmall,
        ),
      ],
    );
  }
}
