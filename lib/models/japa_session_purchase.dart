import 'package:json_annotation/json_annotation.dart';

part 'japa_session_purchase.g.dart';

/// Модель для представления сессии джапы как покупки в Magento
@JsonSerializable()
class JapaSessionPurchase {
  final String sessionId;
  final String customerId;
  final DateTime sessionDate;
  final int completedRounds;
  final int targetRounds;
  final int durationMinutes;
  final String mantra;
  final String sessionType;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JapaSessionPurchase({
    required this.sessionId,
    required this.customerId,
    required this.sessionDate,
    required this.completedRounds,
    required this.targetRounds,
    required this.durationMinutes,
    required this.mantra,
    required this.sessionType,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создает покупку сессии из JapaSession
  factory JapaSessionPurchase.fromJapaSession({
    required String sessionId,
    required String customerId,
    required DateTime sessionDate,
    required int completedRounds,
    required int targetRounds,
    required int durationMinutes,
    required String mantra,
    String sessionType = 'japa_meditation',
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return JapaSessionPurchase(
      sessionId: sessionId,
      customerId: customerId,
      sessionDate: sessionDate,
      completedRounds: completedRounds,
      targetRounds: targetRounds,
      durationMinutes: durationMinutes,
      mantra: mantra,
      sessionType: sessionType,
      metadata: metadata ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Преобразует в формат Magento Order Item
  Map<String, dynamic> toMagentoOrderItem() {
    return {
      'sku': 'japa_session_${sessionId}',
      'name': 'Japa Meditation Session - $mantra',
      'description': 'Completed $completedRounds/$targetRounds rounds in ${durationMinutes} minutes',
      'price': 0.0, // Сессии бесплатные, но могут иметь духовную ценность
      'qty': 1,
      'product_type': 'virtual',
      'custom_attributes': [
        {
          'attribute_code': 'session_id',
          'value': sessionId,
        },
        {
          'attribute_code': 'completed_rounds',
          'value': completedRounds,
        },
        {
          'attribute_code': 'target_rounds',
          'value': targetRounds,
        },
        {
          'attribute_code': 'duration_minutes',
          'value': durationMinutes,
        },
        {
          'attribute_code': 'mantra',
          'value': mantra,
        },
        {
          'attribute_code': 'session_type',
          'value': sessionType,
        },
        {
          'attribute_code': 'session_date',
          'value': sessionDate.toIso8601String(),
        },
      ],
    };
  }

  /// Преобразует в формат Magento Order
  Map<String, dynamic> toMagentoOrder() {
    return {
      'entity_id': null,
      'state': 'complete',
      'status': 'complete',
      'coupon_code': null,
      'protect_code': null,
      'shipping_description': 'No shipping required',
      'is_virtual': 1,
      'store_id': 1,
      'customer_id': int.parse(customerId),
      'base_discount_amount': 0.0,
      'base_discount_canceled': 0.0,
      'base_discount_invoiced': 0.0,
      'base_discount_refunded': 0.0,
      'base_grand_total': 0.0,
      'base_shipping_amount': 0.0,
      'base_shipping_canceled': 0.0,
      'base_shipping_invoiced': 0.0,
      'base_shipping_refunded': 0.0,
      'base_shipping_tax_amount': 0.0,
      'base_shipping_tax_refunded': 0.0,
      'base_subtotal': 0.0,
      'base_subtotal_canceled': 0.0,
      'base_subtotal_invoiced': 0.0,
      'base_subtotal_refunded': 0.0,
      'base_tax_amount': 0.0,
      'base_tax_canceled': 0.0,
      'base_tax_invoiced': 0.0,
      'base_tax_refunded': 0.0,
      'base_to_global_rate': 1.0,
      'base_to_order_rate': 1.0,
      'base_total_canceled': 0.0,
      'base_total_invoiced': 0.0,
      'base_total_invoiced_count': 0,
      'base_total_offline_refunded': 0.0,
      'base_total_online_refunded': 0.0,
      'base_total_paid': 0.0,
      'base_total_qty_ordered': 1,
      'base_total_refunded': 0.0,
      'discount_amount': 0.0,
      'discount_canceled': 0.0,
      'discount_invoiced': 0.0,
      'discount_refunded': 0.0,
      'grand_total': 0.0,
      'shipping_amount': 0.0,
      'shipping_canceled': 0.0,
      'shipping_invoiced': 0.0,
      'shipping_refunded': 0.0,
      'shipping_tax_amount': 0.0,
      'shipping_tax_refunded': 0.0,
      'store_to_base_rate': 1.0,
      'store_to_order_rate': 1.0,
      'subtotal': 0.0,
      'subtotal_canceled': 0.0,
      'subtotal_invoiced': 0.0,
      'subtotal_refunded': 0.0,
      'tax_amount': 0.0,
      'tax_canceled': 0.0,
      'tax_invoiced': 0.0,
      'tax_refunded': 0.0,
      'total_canceled': 0.0,
      'total_invoiced': 0.0,
      'total_offline_refunded': 0.0,
      'total_online_refunded': 0.0,
      'total_paid': 0.0,
      'total_qty_ordered': 1,
      'total_refunded': 0.0,
      'can_ship_partially': 0,
      'can_ship_partially_item': 0,
      'customer_is_guest': 0,
      'customer_note_notify': 0,
      'billing_address_id': null,
      'customer_group_id': 1,
      'edit_increment': null,
      'email_sent': 0,
      'send_email': 0,
      'forced_shipment_with_invoice': 0,
      'payment_auth_expiration': null,
      'quote_address_id': null,
      'quote_id': null,
      'shipping_address_id': null,
      'adjustment_negative': null,
      'adjustment_positive': null,
      'base_adjustment_negative': null,
      'base_adjustment_positive': null,
      'base_shipping_discount_amount': 0.0,
      'base_subtotal_incl_tax': 0.0,
      'base_total_due': 0.0,
      'payment_authorization_amount': null,
      'shipping_discount_amount': 0.0,
      'subtotal_incl_tax': 0.0,
      'total_due': 0.0,
      'weight': 0.0,
      'customer_dob': null,
      'increment_id': null,
      'applied_rule_ids': null,
      'base_currency_code': 'USD',
      'customer_email': null,
      'customer_firstname': null,
      'customer_lastname': null,
      'customer_middlename': null,
      'customer_prefix': null,
      'customer_suffix': null,
      'customer_taxvat': null,
      'discount_description': null,
      'ext_customer_id': null,
      'ext_order_id': null,
      'global_currency_code': 'USD',
      'hold_before_state': null,
      'hold_before_status': null,
      'order_currency_code': 'USD',
      'original_increment_id': null,
      'relation_child_id': null,
      'relation_child_real_id': null,
      'relation_parent_id': null,
      'relation_parent_real_id': null,
      'remote_ip': null,
      'shipping_method': null,
      'store_currency_code': 'USD',
      'store_name': 'AI Japa Mahamantra',
      'x_forwarded_for': null,
      'customer_note': 'Japa Meditation Session - Spiritual Practice',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_item_count': 1,
      'customer_gender': null,
      'discount_tax_compensation_amount': 0.0,
      'base_discount_tax_compensation_amount': 0.0,
      'shipping_discount_tax_compensation_amount': 0.0,
      'base_shipping_discount_tax_compensation_amnt': 0.0,
      'discount_tax_compensation_invoiced': 0.0,
      'base_discount_tax_compensation_invoiced': 0.0,
      'discount_tax_compensation_refunded': 0.0,
      'base_discount_tax_compensation_refunded': 0.0,
      'shipping_incl_tax': 0.0,
      'base_shipping_incl_tax': 0.0,
      'coupon_rule_name': null,
      'gift_message_id': null,
      'items': [toMagentoOrderItem()],
    };
  }

  factory JapaSessionPurchase.fromJson(Map<String, dynamic> json) =>
      _$JapaSessionPurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$JapaSessionPurchaseToJson(this);

  JapaSessionPurchase copyWith({
    String? sessionId,
    String? customerId,
    DateTime? sessionDate,
    int? completedRounds,
    int? targetRounds,
    int? durationMinutes,
    String? mantra,
    String? sessionType,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JapaSessionPurchase(
      sessionId: sessionId ?? this.sessionId,
      customerId: customerId ?? this.customerId,
      sessionDate: sessionDate ?? this.sessionDate,
      completedRounds: completedRounds ?? this.completedRounds,
      targetRounds: targetRounds ?? this.targetRounds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      mantra: mantra ?? this.mantra,
      sessionType: sessionType ?? this.sessionType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
