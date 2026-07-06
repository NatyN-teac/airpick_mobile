import 'package:flutter/material.dart';
import '../../../core/utils/time_format.dart';
import '../../chat/models/chat.dart';
import '../../flights/models/flight_models.dart';
import '../../matches/models/match_models.dart';

// ── API models ────────────────────────────────────────────────────────────────

class ProposalItemEngagement {
  final String id;
  final String offerRequestItemId;
  final String itemName;
  final String? measurementUnit;
  final double quantity;
  final double pricePerItem;
  final double lineTotal;

  const ProposalItemEngagement({
    required this.id,
    required this.offerRequestItemId,
    required this.itemName,
    required this.quantity,
    required this.pricePerItem,
    required this.lineTotal,
    this.measurementUnit,
  });

  factory ProposalItemEngagement.fromJson(Map<String, dynamic> json) =>
      ProposalItemEngagement(
        id: (json['id'] ?? '').toString(),
        offerRequestItemId: (json['offerRequestItemId'] ?? '').toString(),
        itemName: (json['itemName'] ?? 'Item').toString(),
        measurementUnit: json['measurementUnit'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        pricePerItem: (json['pricePerItem'] as num?)?.toDouble() ?? 0,
        lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
      );
}

class ProposalEngagement {
  final String id;
  final String offerRequestId;
  final String carrierId;
  final FlightResponse? flight;
  final String status;
  final String deliveryArea;
  final String pickupArea;
  final double? discount;
  final List<String> meetupPlaces;
  final List<String> paymentMethods;
  final String? note;
  final List<ProposalItemEngagement> items;
  final double totalPrice;
  final String createdAt;
  final String updatedAt;

  const ProposalEngagement({
    required this.id,
    required this.offerRequestId,
    required this.carrierId,
    required this.status,
    required this.deliveryArea,
    required this.pickupArea,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.flight,
    this.discount,
    this.meetupPlaces = const [],
    this.paymentMethods = const [],
    this.note,
  });

  factory ProposalEngagement.fromJson(Map<String, dynamic> json) =>
      ProposalEngagement(
        id: (json['id'] ?? '').toString(),
        offerRequestId: (json['offerRequestId'] ?? '').toString(),
        carrierId: (json['carrierId'] ?? '').toString(),
        flight: json['flight'] is Map<String, dynamic>
            ? FlightResponse.fromJson(json['flight'] as Map<String, dynamic>)
            : null,
        status: (json['status'] ?? 'PENDING').toString(),
        deliveryArea: (json['deliveryArea'] ?? '').toString(),
        pickupArea: (json['pickupArea'] ?? '').toString(),
        discount: (json['discount'] as num?)?.toDouble(),
        meetupPlaces: (json['meetupPlaces'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        paymentMethods: (json['paymentMethods'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        note: json['note'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) =>
                ProposalItemEngagement.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
        createdAt: (json['createdAt'] ?? '').toString(),
        updatedAt: (json['updatedAt'] ?? '').toString(),
      );
}

class MatchReceiverInfo {
  final String firstName;
  final String lastName;
  final String phone;
  final String photoIdUrl;
  final bool isActive;

  const MatchReceiverInfo({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.photoIdUrl,
    this.isActive = true,
  });

  factory MatchReceiverInfo.fromJson(Map<String, dynamic> json) =>
      MatchReceiverInfo(
        firstName: (json['firstName'] ?? '').toString(),
        lastName: (json['lastName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        photoIdUrl: (json['photoIdUrl'] ?? '').toString(),
        isActive: json['isActive'] as bool? ?? true,
      );
}

class MatchEngagement {
  final String id;
  final String carrierId;
  final String shipperId;
  final String offerId;
  final String status;
  final double totalPrice;
  final bool receiverNeeded;
  final MatchReceiverInfo? receiver;
  final String? chatId;
  final List<MatchedItemResponse> matchedItems;
  final ChatParticipant? carrier;
  final ChatParticipant? shipper;
  final String createdAt;
  final String updatedAt;

  const MatchEngagement({
    required this.id,
    required this.carrierId,
    required this.shipperId,
    required this.offerId,
    required this.status,
    required this.totalPrice,
    required this.receiverNeeded,
    required this.matchedItems,
    required this.createdAt,
    required this.updatedAt,
    this.receiver,
    this.chatId,
    this.carrier,
    this.shipper,
  });

  ChatParticipant? otherParty({required bool viewerIsCarrier}) =>
      viewerIsCarrier ? shipper : carrier;

  bool get hasAvailableChat =>
      chatId?.trim().isNotEmpty == true &&
      const {'ACCEPTED', 'IN_PROGRESS', 'IN_DELIVERY', 'COMPLETED'}
          .contains(status.toUpperCase());

  factory MatchEngagement.fromJson(Map<String, dynamic> json) {
    ChatParticipant? participant(dynamic raw) =>
        raw is Map<String, dynamic> ? ChatParticipant.fromJson(raw) : null;

    return MatchEngagement(
      id: (json['id'] ?? '').toString(),
      carrierId: (json['carrierId'] ?? '').toString(),
      shipperId: (json['shipperId'] ?? '').toString(),
      offerId: (json['offerId'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      receiverNeeded: json['receiverNeeded'] as bool? ?? false,
      receiver: json['receiver'] is Map<String, dynamic>
          ? MatchReceiverInfo.fromJson(
              json['receiver'] as Map<String, dynamic>,
            )
          : null,
      chatId: json['chatId'] as String?,
      carrier: participant(json['carrier']),
      shipper: participant(json['shipper']),
      matchedItems: (json['matchedItems'] as List<dynamic>? ?? [])
          .map((e) => MatchedItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }
}

class EngagementResponse {
  final String mode;
  final List<ProposalEngagement> proposalsSent;
  final List<ProposalEngagement> proposalsReceived;
  final List<MatchEngagement> matchedOffers;

  const EngagementResponse({
    required this.mode,
    this.proposalsSent = const [],
    this.proposalsReceived = const [],
    this.matchedOffers = const [],
  });

  factory EngagementResponse.fromJson(Map<String, dynamic> json) =>
      EngagementResponse(
        mode: (json['mode'] ?? '').toString(),
        proposalsSent: _parseProposals(json['proposalsSent']),
        proposalsReceived: _parseProposals(json['proposalsReceived']),
        matchedOffers: (json['matchedOffers'] as List<dynamic>? ?? [])
            .map((e) => MatchEngagement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static List<ProposalEngagement> _parseProposals(dynamic raw) =>
      (raw as List<dynamic>? ?? [])
          .map((e) => ProposalEngagement.fromJson(e as Map<String, dynamic>))
          .toList();

  /// Flat list for home UI — mode-aware, merged by updatedAt desc.
  List<EngagementListItem> toListItems() {
    final items = <EngagementListItem>[];
    final isCarrier = mode.toUpperCase() == 'CARRIER';

    for (final p in isCarrier ? proposalsSent : proposalsReceived) {
      items.add(EngagementListItem.fromProposal(
        p,
        kind: isCarrier
            ? EngagementKind.proposalSent
            : EngagementKind.proposalReceived,
      ));
    }
    for (final m in matchedOffers) {
      items.add(EngagementListItem.fromMatch(m));
    }

    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// All items of a single [kind], regardless of the active mode. Used by the
  /// "View all" screen so the user can browse sent/received/matched separately.
  List<EngagementListItem> itemsOfKind(EngagementKind kind) {
    final items = <EngagementListItem>[];
    switch (kind) {
      case EngagementKind.proposalSent:
        for (final p in proposalsSent) {
          items.add(EngagementListItem.fromProposal(p, kind: kind));
        }
      case EngagementKind.proposalReceived:
        for (final p in proposalsReceived) {
          items.add(EngagementListItem.fromProposal(p, kind: kind));
        }
      case EngagementKind.match:
        for (final m in matchedOffers) {
          items.add(EngagementListItem.fromMatch(m));
        }
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }
}

// ── UI view model ─────────────────────────────────────────────────────────────

enum EngagementKind { proposalSent, proposalReceived, match }

enum EngagementDisplayStatus {
  proposalSent,
  proposalReceived,
  matched,
  pending,
  inProgress,
}

extension EngagementDisplayStatusX on EngagementDisplayStatus {
  String get label => switch (this) {
        EngagementDisplayStatus.proposalSent => 'Proposal sent',
        EngagementDisplayStatus.proposalReceived => 'Proposal received',
        EngagementDisplayStatus.matched => 'Matched',
        EngagementDisplayStatus.pending => 'Pending',
        EngagementDisplayStatus.inProgress => 'In progress',
      };

  Color get color => switch (this) {
        EngagementDisplayStatus.proposalSent => const Color(0xFF4299E1),
        EngagementDisplayStatus.proposalReceived => const Color(0xFF9F7AEA),
        EngagementDisplayStatus.matched => const Color(0xFF48BB78),
        EngagementDisplayStatus.pending => const Color(0xFFA0AEC0),
        EngagementDisplayStatus.inProgress => const Color(0xFFED8936),
      };
}

class EngagementListItem {
  final String id;
  final EngagementKind kind;
  final EngagementDisplayStatus status;
  final String title;
  final String fromCode;
  final String toCode;
  final String subtitle;
  final String dateLabel;
  final DateTime updatedAt;

  const EngagementListItem({
    required this.id,
    required this.kind,
    required this.status,
    required this.title,
    required this.fromCode,
    required this.toCode,
    required this.subtitle,
    required this.dateLabel,
    required this.updatedAt,
  });

  factory EngagementListItem.fromProposal(
    ProposalEngagement p, {
    required EngagementKind kind,
  }) {
    final leg = p.flight?.legs.isNotEmpty == true ? p.flight!.legs.first : null;
    final title = p.items.isNotEmpty
        ? p.items.map((i) => i.itemName).take(2).join(', ')
        : 'Proposal';
    return EngagementListItem(
      id: p.id,
      kind: kind,
      status: kind == EngagementKind.proposalSent
          ? EngagementDisplayStatus.proposalSent
          : EngagementDisplayStatus.proposalReceived,
      title: title,
      fromCode: leg?.srcAirport.iataCode ?? '—',
      toCode: leg?.destAirport.iataCode ?? '—',
      subtitle: '${p.pickupArea} → ${p.deliveryArea}',
      dateLabel: _formatDate(p.updatedAt),
      updatedAt: TimeFormat.parseServerTime(p.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory EngagementListItem.fromMatch(MatchEngagement m) {
    final displayStatus = switch (m.status.toUpperCase()) {
      'ACCEPTED' => EngagementDisplayStatus.matched,
      'IN_PROGRESS' => EngagementDisplayStatus.inProgress,
      _ => EngagementDisplayStatus.pending,
    };
    final title = m.matchedItems.isNotEmpty
        ? m.matchedItems.map((i) => i.itemName).take(2).join(', ')
        : 'Match';
    final receiver = m.receiver;
    final receiverLabel = receiver != null
        ? 'Receiver: ${receiver.firstName}${receiver.lastName.trim().isNotEmpty ? ' ${receiver.lastName[0]}.' : ''}'
        : null;
    final subtitle = receiverLabel != null
        ? '$receiverLabel · \$${m.totalPrice.toStringAsFixed(2)}'
        : '\$${m.totalPrice.toStringAsFixed(2)}';
    return EngagementListItem(
      id: m.id,
      kind: EngagementKind.match,
      status: displayStatus,
      title: title,
      fromCode: '—',
      toCode: '—',
      subtitle: subtitle,
      dateLabel: _formatDate(m.updatedAt),
      updatedAt: TimeFormat.parseServerTime(m.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static String _formatDate(String iso) {
    final dt = TimeFormat.parseServerTime(iso);
    if (dt == null) return iso;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
