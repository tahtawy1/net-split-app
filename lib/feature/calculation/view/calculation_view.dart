import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/calculation_cubit.dart';
import '../cubit/calculation_state.dart';
import '../widgets/global_inputs_form.dart';
import '../widgets/summary_cards.dart';
import '../widgets/user_data_table.dart';
import '../../about/view/about_view.dart';

class CalculationView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const CalculationView({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  void _copyResults(BuildContext context, CalculationState state) {
    final result = state.result!;
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('  NetSplit — Cost Report');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Plan Limit: ${state.totalPlanLimit.toStringAsFixed(2)} GB');
    buffer.writeln('Plan Price: ${state.planPrice.toStringAsFixed(2)}');
    buffer.writeln(
      'Total Users Usage: ${result.totalUsersUsage.toStringAsFixed(2)} GB',
    );
    if (result.companyUsage > 0) {
      buffer.writeln(
        'Company/Hidden Usage: ${result.companyUsage.toStringAsFixed(2)} GB',
      );
    }
    buffer.writeln('Price per GB: ${result.pricePerGB.toStringAsFixed(4)}');
    buffer.writeln('──────────────────────────');
    for (var uc in result.userCosts) {
      buffer.writeln(
        '• ${uc.name}: ${uc.usage.toStringAsFixed(2)} GB → ${uc.cost.toStringAsFixed(2)}',
      );
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('       Created By Tahtawy');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Results copied to clipboard'),
          ],
        ),
        backgroundColor: AppTheme.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.orange,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text('Reset All Data'),
            ],
          ),
          content: const Text(
            'This will clear all users, plan details, and saved data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<CalculationCubit>().resetData();
                Navigator.pop(ctx);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CalculationCubit, CalculationState>(
        listenWhen: (prev, curr) =>
            prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!)),
                ],
              ),
              backgroundColor: AppTheme.red,
            ),
          );
        },
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const GlobalInputsForm(),
                    const SizedBox(height: 24),
                    const SummaryCards(),
                    const SizedBox(height: 24),
                    const UserDataTable(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF22C55E)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wifi, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            'NetSplit',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'v1.0',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.tealDark : AppTheme.teal,
              ),
            ),
          ),
          const Spacer(),
          BlocBuilder<CalculationCubit, CalculationState>(
            builder: (context, state) {
              return Row(
                children: [
                  _HeaderButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy Results',
                    onTap: state.result != null
                        ? () => _copyResults(context, state)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                    color: AppTheme.red,
                    onTap: () => _resetAll(context),
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    color: AppTheme.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutView(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: onToggleTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _HeaderButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;
    final isDisabled = widget.onTap == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering && !isDisabled
                ? effectiveColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey.withValues(alpha: 0.3)
                  : effectiveColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: isDisabled
                    ? Colors.grey.withValues(alpha: 0.5)
                    : effectiveColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? Colors.grey.withValues(alpha: 0.5)
                      : effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
