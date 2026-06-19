import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cafe_order_state.dart';
import '../../../visuals/visual_config.dart';
import '../game_controller.dart';

class QueuePanel extends ConsumerWidget {
  const QueuePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final activeOrders = state.cafeOrders.where((o) => o.isActive).toList();
    final seatedCount = state.cafeTables.where((t) => t.isOccupied).length;
    final waitingTypes = state.waitingCustomerTypes;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.72),
      decoration: const BoxDecoration(
        color: VisualConfig.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: VisualConfig.panelBorder,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Order Queue', style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _CountChip(
                  icon: Icons.people_outline,
                  label: 'Waiting',
                  count: state.waitingCustomers,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _CountChip(
                  icon: Icons.event_seat,
                  label: 'Seated',
                  count: seatedCount,
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                _CountChip(
                  icon: Icons.receipt_long,
                  label: 'Orders',
                  count: activeOrders.length,
                  color: VisualConfig.coffeeBrown,
                ),
              ],
            ),
          ),
          if (waitingTypes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: waitingTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemBuilder: (context, i) => _customerAvatar(waitingTypes[i]),
                ),
              ),
            ),
          const Divider(height: 1),
          if (activeOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.coffee_outlined, size: 40, color: Colors.brown),
                  SizedBox(height: 8),
                  Text(
                    'No orders right now ☕',
                    style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: activeOrders.length,
                itemBuilder: (context, i) => _OrderCard(order: activeOrders[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _customerAvatar(String typeId) {
    final (icon, color) = _typeIconAndColor(typeId);
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, size: 16, color: color),
    );
  }

  static (IconData, Color) _typeIconAndColor(String typeId) {
    return switch (typeId.toLowerCase()) {
      'vip' => (Icons.star, Colors.amber),
      'tourist' => (Icons.luggage, Colors.blue),
      'business' => (Icons.business_center, Colors.indigo),
      _ => (Icons.person, Colors.brown),
    };
  }
}

// ---------------------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final CafeOrderState order;

  @override
  Widget build(BuildContext context) {
    final ratio = (order.patienceSeconds / order.maxPatienceSeconds).clamp(0.0, 1.0);
    final patienceColor = _patienceColor(ratio);
    final (typeIcon, typeColor) = QueuePanel._typeIconAndColor(order.customerTypeId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: typeColor.withValues(alpha: 0.15),
                  child: Icon(typeIcon, size: 14, color: typeColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _typeName(order.customerTypeId),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                Text(
                  _formatElapsed(order.elapsedSeconds.toInt()),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: order.requestedItems.map((item) => _ItemChip(item: item)).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      color: patienceColor,
                      backgroundColor: patienceColor.withValues(alpha: 0.15),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.patienceSeconds.toInt()}s left',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: patienceColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _patienceColor(double ratio) {
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  static String _typeName(String typeId) => switch (typeId.toLowerCase()) {
        'vip' => 'VIP',
        'tourist' => 'Tourist',
        'business' => 'Business',
        _ => 'Regular',
      };

  static String _formatElapsed(int s) {
    if (s < 60) return '${s}s';
    return '${s ~/ 60}m ${s % 60}s';
  }
}

// ---------------------------------------------------------------------------

class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.item});

  final CafeOrderItemState item;

  @override
  Widget build(BuildContext context) {
    final done = item.delivered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done ? Colors.green.withValues(alpha: 0.12) : Colors.brown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? Colors.green.withValues(alpha: 0.4) : Colors.brown.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: done ? Colors.green[700] : Colors.brown[700],
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
