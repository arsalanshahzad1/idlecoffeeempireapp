import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../components/customer_component.dart';
import '../managers/customer_type_manager.dart';
import '../data/economy_balance_config.dart';
import '../models/cafe_order_state.dart';
import '../visuals/render_layers.dart';

class CustomerManager {
  CustomerManager({
    required this.world,
    this.typeManager = const CustomerTypeManager(),
  });

  final World world;
  final CustomerTypeManager typeManager;
  final List<CustomerComponent> _queueCustomers = <CustomerComponent>[];
  final List<CustomerComponent> _leavingCustomers = <CustomerComponent>[];
  final Map<String, CustomerComponent> _seatedCustomers = <String, CustomerComponent>{};

  Vector2 _spawnPoint = Vector2.zero();
  Vector2 _exitPoint = Vector2.zero();
  List<Vector2> _queueSlots = const <Vector2>[];
  List<Vector2> _tableSlots = const <Vector2>[];
  Vector2 _fallbackWaitingSlot = Vector2.zero();
  List<String> _targetQueueTypes = const <String>[];
  List<CafeOrderState> _targetOrders = const <CafeOrderState>[];

  void updateAnchors({
    required Vector2 spawnPoint,
    required Vector2 exitPoint,
    required List<Vector2> queueSlots,
    List<Vector2> tableSlots = const <Vector2>[],
    Vector2? fallbackWaitingSlot,
  }) {
    _spawnPoint = spawnPoint;
    _exitPoint = exitPoint;
    _queueSlots = queueSlots;
    _tableSlots = tableSlots;
    _fallbackWaitingSlot = fallbackWaitingSlot ?? (queueSlots.isNotEmpty ? queueSlots.last : spawnPoint);
    _refreshQueueTargets();
  }

  void syncQueueTypes(List<String> queueTypes) {
    _targetQueueTypes = List<String>.from(queueTypes);
    _reconcileQueueCount();
  }

  void syncCafeOrders(List<CafeOrderState> orders) {
    _targetOrders = orders.where((order) => order.phase == CafeOrderPhase.seated).toList(growable: false);
    _reconcileSeatedCustomers();
  }

  void update(double dt) {
    for (final customer in List<CustomerComponent>.from(_leavingCustomers)) {
      final distanceToExit = (customer.position - _exitPoint).length;
      if (distanceToExit < 4 || distanceToExit > 1400) {
        customer.removeFromParent();
        _leavingCustomers.remove(customer);
      }
    }

    for (final customer in _queueCustomers) {
      final slot = _queueCustomers.indexOf(customer);
      if (slot < _queueSlots.length) {
        customer.moveTo(
          _queueSlots[slot] + Vector2(slot * -1.8, slot * 3.2),
          phase: CustomerPhase.waitingQueue,
        );
      }
    }
    _refreshSeatedTargets();
  }

  void _reconcileQueueCount() {
    while (_queueCustomers.length < _targetQueueTypes.length &&
        (_queueCustomers.length + _leavingCustomers.length) <
            EconomyBalanceConfig.maxActiveCustomers) {
      final idx = _queueCustomers.length;
      final typeId = idx < _targetQueueTypes.length ? _targetQueueTypes[idx] : 'regular';
      final typeCfg = typeManager.byId(typeId);
      final customer = CustomerComponent(
        position: _spawnPoint.clone(),
        moveSpeed: EconomyBalanceConfig.customerMoveSpeed / typeCfg.patienceMultiplier,
        customerTypeId: typeId,
        color: Color(typeCfg.colorHex),
        assetPath: typeCfg.assetPath,
        radius: typeId == 'vip_guest'
            ? 11
            : (typeId == 'influencer'
                  ? 10
                  : (typeId == 'student' ? 8 : 9)),
      );
      customer.priority = RenderLayers.customer + (_queueSlots.isEmpty ? 0 : (_queueSlots.first.y / 20).floor());
      world.add(customer);
      _queueCustomers.add(customer);
      customer.triggerArrivalFeedback();
    }

    while (_queueCustomers.length > _targetQueueTypes.length) {
      final served = _queueCustomers.removeAt(0);
      served.triggerServedFeedback();
      served.moveTo(
        _exitPoint,
        phase: CustomerPhase.leaving,
      );
      _leavingCustomers.add(served);
    }

    _refreshQueueTargets();
  }

  void _refreshQueueTargets() {
    for (var i = 0; i < _queueCustomers.length; i++) {
      if (i < _queueSlots.length) {
        _queueCustomers[i].moveTo(
          _queueSlots[i] + Vector2(i * -1.8, i * 3.2),
          phase: CustomerPhase.waitingQueue,
        );
      }
    }
  }

  void _reconcileSeatedCustomers() {
    final activeIds = _targetOrders.map((order) => order.customerId).toSet();
    for (final entry in List<MapEntry<String, CustomerComponent>>.from(_seatedCustomers.entries)) {
      if (activeIds.contains(entry.key)) {
        continue;
      }
      final customer = entry.value;
      _seatedCustomers.remove(entry.key);
      customer.triggerServedFeedback();
      customer.moveTo(_exitPoint, phase: CustomerPhase.leaving);
      _leavingCustomers.add(customer);
    }

    for (final order in _targetOrders) {
      var customer = _seatedCustomers[order.customerId];
      if (customer == null) {
        final typeCfg = typeManager.byId(order.customerTypeId);
        customer = CustomerComponent(
          position: _queueSlots.isNotEmpty ? _queueSlots.first.clone() : _spawnPoint.clone(),
          moveSpeed: EconomyBalanceConfig.customerMoveSpeed / typeCfg.patienceMultiplier,
          customerTypeId: order.customerTypeId,
          color: Color(typeCfg.colorHex),
          assetPath: typeCfg.assetPath,
          radius: order.customerTypeId == 'vip_guest'
              ? 11
              : (order.customerTypeId == 'influencer'
                    ? 10
                    : (order.customerTypeId == 'student' ? 8 : 9)),
        );
        _seatedCustomers[order.customerId] = customer;
        world.add(customer);
        customer.triggerArrivalFeedback();
      }
      customer.setOrderBubble(
        icons: order.requestedItems.map((item) => item.icon).toList(growable: false),
        stationIds: order.requestedItems.map((item) => item.stationId).toList(growable: false),
        deliveredItems: order.deliveredCount,
        totalItems: order.totalCount,
        patienceRatio: order.maxPatienceSeconds <= 0
            ? 1
            : order.patienceSeconds / order.maxPatienceSeconds,
      );
    }
    _refreshSeatedTargets();
  }

  void _refreshSeatedTargets() {
    for (var i = 0; i < _targetOrders.length; i++) {
      final order = _targetOrders[i];
      final customer = _seatedCustomers[order.customerId];
      if (customer == null) {
        continue;
      }
      final slot = _slotForOrder(order, i);
      customer.moveTo(slot, phase: CustomerPhase.seated);
      customer.priority = RenderLayers.customer + (slot.y / 20).floor();
    }
  }

  Vector2 _slotForOrder(CafeOrderState order, int index) {
    final tableNumber = order.tableId == null
        ? -1
        : int.tryParse(order.tableId!.split('_').last) ?? -1;
    if (tableNumber > 0 && tableNumber <= _tableSlots.length) {
      return _tableSlots[tableNumber - 1];
    }
    return _fallbackWaitingSlot + Vector2((index % 3) * 14.0, (index ~/ 3) * 16.0);
  }
}
