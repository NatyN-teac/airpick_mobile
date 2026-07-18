// One row in the conversations list. Parsed defensively (endpoint shape TBD).
class ChatSummary {
  final String matchId;
  final String title;
  final String? otherPartyName;
  final String? otherPartyAvatarUrl;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String status; // match status: ACCEPTED / IN_PROGRESS / COMPLETED

  const ChatSummary({
    required this.matchId,
    required this.title,
    this.otherPartyName,
    this.otherPartyAvatarUrl,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
    this.status = '',
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : null;
    final other = asMap(json['otherParty']) ??
        asMap(json['counterparty']) ??
        asMap(json['shipper']) ??
        asMap(json['carrier']);
    final last = asMap(json['lastMessage']);

    String? name;
    if (other != null) {
      final f = other['firstName'] ?? other['name'];
      final l = other['lastName'];
      name = [f, l].where((e) => e != null && '$e'.isNotEmpty).join(' ').trim();
      if (name.isEmpty) name = null;
    }

    final itemTitle = (json['title'] ?? json['itemTitle'] ?? name ?? 'Chat')
        .toString();

    final lastText =
        (last?['content'] ?? json['lastMessageText'] ?? json['lastMessage']);
    final lastTs = last?['createdAt'] ?? json['lastMessageAt'] ?? json['updatedAt'];

    return ChatSummary(
      matchId: (json['matchId'] ?? json['match']?['id'] ?? '').toString(),
      title: itemTitle,
      otherPartyName: name,
      otherPartyAvatarUrl:
          (other?['profilePictureUrl'] ?? other?['avatarUrl']) as String?,
      lastMessage: lastText is String ? lastText : '',
      lastMessageAt: lastTs != null
          ? DateTime.tryParse(lastTs.toString())?.toLocal()
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}
