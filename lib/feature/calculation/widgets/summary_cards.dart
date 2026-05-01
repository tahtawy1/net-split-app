import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/calculation_cubit.dart';
import '../cubit/calculation_state.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculationCubit, CalculationState>(
      builder: (context, state) {
        final result = state.result;
        return Column(
          children: [
            if (state.warning != null) _WarningBanner(message: state.warning!),
            if (result != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  _SummaryCard(
                    title: 'Total Users Usage',
                    value: result.totalUsersUsage.toStringAsFixed(2),
                    unit: 'GB',
                    icon: Icons.people_rounded,
                    color: AppTheme.teal,
                  ),
                  const SizedBox(width: 16),
                  _SummaryCard(
                    title: 'Company Usage',
                    value: result.companyUsage.toStringAsFixed(2),
                    unit: 'GB',
                    icon: Icons.cloud_outlined,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 16),
                  _SummaryCard(
                    title: 'Price per GB',
                    value: result.pricePerGB.toStringAsFixed(4),
                    unit: 'EGP',
                    icon: Icons.attach_money_rounded,
                    color: AppTheme.purple,
                  ),
                  const SizedBox(width: 16),
                  _SummaryCard(
                    title: 'User Limit',
                    value: result.userLimit.toStringAsFixed(2),
                    unit: 'GB',
                    icon: Icons.person_outline_rounded,
                    color: AppTheme.green,
                  ),
                ],
              ),
            ] else
              _buildEmptyState(context),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter plan details and add users to see results',
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.orange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatefulWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hov
              ? Matrix4.translationValues(0.0, -2.0, 0.0)
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2838) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hov
                  ? widget.color.withValues(alpha: 0.4)
                  : (isDark ? const Color(0xFF2E4057) : Colors.grey.shade200),
            ),
            boxShadow: _hov
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, size: 14, color: widget.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.unit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.color.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
