import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/calculation_cubit.dart';

class GlobalInputsForm extends StatefulWidget {
  const GlobalInputsForm({super.key});

  @override
  State<GlobalInputsForm> createState() => _GlobalInputsFormState();
}

class _GlobalInputsFormState extends State<GlobalInputsForm> {
  final _limitController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<CalculationCubit>().state;
    _limitController.text = state.totalPlanLimit > 0
        ? state.totalPlanLimit.toString()
        : '';
    _priceController.text = state.planPrice > 0
        ? state.planPrice.toString()
        : '';
  }

  @override
  void dispose() {
    _limitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final limit = double.tryParse(_limitController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    context.read<CalculationCubit>().updateGlobalInputs(
      planLimit: limit,
      planPrice: price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.router_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Plan Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    controller: _limitController,
                    label: 'Total Plan Limit',
                    suffix: 'GB',
                    icon: Icons.data_usage_rounded,
                    onChanged: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InputField(
                    controller: _priceController,
                    label: 'Plan Price',
                    suffix: 'EGP',
                    icon: Icons.payments_rounded,
                    onChanged: (_) => _submit(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    this.suffix,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}
