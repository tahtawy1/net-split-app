import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/calculation_cubit.dart';
import '../cubit/calculation_state.dart';

class UserDataTable extends StatefulWidget {
  const UserDataTable({super.key});

  @override
  State<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends State<UserDataTable> {
  final _nameCtrl = TextEditingController();
  final _usageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usageCtrl.dispose();
    super.dispose();
  }

  void _addUser() {
    final name = _nameCtrl.text.trim();
    final usage = double.tryParse(_usageCtrl.text) ?? -1;
    if (name.isNotEmpty && usage >= 0) {
      context.read<CalculationCubit>().addUser(name, usage);
      _nameCtrl.clear();
      _usageCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and usage.')),
      );
    }
  }

  void _showAddDialog() {
    _nameCtrl.clear();
    _usageCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: AppTheme.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Roommate'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usageCtrl,
              decoration: const InputDecoration(
                labelText: 'Usage',
                suffixText: 'GB',
                prefixIcon: Icon(Icons.data_usage_rounded, size: 20),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addUser();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final usageCtrl = TextEditingController(
      text: user.internetUsage.toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Edit Roommate'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usageCtrl,
              decoration: const InputDecoration(
                labelText: 'Usage',
                suffixText: 'GB',
                prefixIcon: Icon(Icons.data_usage_rounded, size: 20),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              final u = double.tryParse(usageCtrl.text) ?? -1;
              if (n.isNotEmpty && u >= 0) {
                context.read<CalculationCubit>().updateUser(user.id, n, u);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: isDark ? AppTheme.greenDark : AppTheme.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Roommates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Roommate'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<CalculationCubit, CalculationState>(
              builder: (context, state) {
                if (state.users.isEmpty) return _buildEmpty(isDark);
                final result = state.result;
                final topId = (result?.userCosts.isNotEmpty == true)
                    ? result!.userCosts.first.userId
                    : null;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    columnSpacing: 32,
                    horizontalMargin: 20,
                    headingRowHeight: 48,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Usage (GB)'), numeric: true),
                      DataColumn(label: Text('Cost'), numeric: true),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List.generate(state.users.length, (i) {
                      final user = state.users[i];
                      final costMatch = result?.userCosts.where(
                        (uc) => uc.userId == user.id,
                      );
                      final userCost =
                          (costMatch != null && costMatch.isNotEmpty)
                          ? costMatch.first
                          : null;
                      final isTop = user.id == topId;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith((s) {
                          if (isTop && result != null)
                            return AppTheme.orange.withValues(alpha: 0.06);
                          return null;
                        }),
                        cells: [
                          DataCell(
                            Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Avatar(name: user.name, isTop: isTop),
                                const SizedBox(width: 10),
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontWeight: isTop
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isTop) ...[
                                  const SizedBox(width: 6),
                                  const Tooltip(
                                    message: 'Top Consumer',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          color: AppTheme.orange,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              user.internetUsage.toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              userCost != null
                                  ? userCost.cost.toStringAsFixed(2)
                                  : '—',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.greenDark
                                    : AppTheme.green,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionIcon(
                                  icon: Icons.edit_outlined,
                                  color: Colors.blue,
                                  tooltip: 'Edit',
                                  onTap: () => _showEditDialog(user),
                                ),
                                const SizedBox(width: 4),
                                _ActionIcon(
                                  icon: Icons.delete_outline_rounded,
                                  color: AppTheme.red,
                                  tooltip: 'Remove',
                                  onTap: () => context
                                      .read<CalculationCubit>()
                                      .removeUser(user.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 48,
            color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No roommates added yet',
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add Roommate" to get started',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final bool isTop;
  const _Avatar({required this.name, required this.isTop});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isTop
            ? AppTheme.orange.withValues(alpha: 0.15)
            : AppTheme.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isTop ? AppTheme.orange : AppTheme.teal,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hov
                  ? widget.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _hov ? widget.color : widget.color.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
