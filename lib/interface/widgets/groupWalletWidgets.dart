import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Horizontal chip list to switch between group wallets.
class GroupWalletSelector extends StatelessWidget {
  final GroupWallet active;
  final List<GroupWallet> wallets;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAdd;

  const GroupWalletSelector({
    super.key,
    required this.active,
    required this.wallets,
    required this.onSelected,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length + (onAdd != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (onAdd != null && i == wallets.length) {
            return StickerButton(
              onTap: onAdd,
              color: AppTheme.surface,
              radius: 18,
              dy: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.ink, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'New group',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                  ),
                ],
              ),
            );
          }
          final w = wallets[i];
          final selected = w.id == active.id;
          return GestureDetector(
            onTap: () => onSelected(w.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? themeColor(w.color) : AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outline, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFD9CFB6),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_rounded, size: 18, color: AppTheme.ink),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        '${w.acceptedMembers.length} member${w.acceptedMembers.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One row showing a group wallet member's status, name, and role.
class GroupMemberTile extends StatelessWidget {
  final GroupMember member;
  final bool isOwner;
  final VoidCallback? onRemove;

  const GroupMemberTile({
    super.key,
    required this.member,
    required this.isOwner,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = member.isAccepted
        ? AppTheme.success
        : member.isRejected
            ? AppTheme.error
            : AppTheme.primaryDark;
    final statusIcon = member.isAccepted
        ? Icons.check_circle_rounded
        : member.isRejected
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;
    final display = member.name.isNotEmpty ? member.name : member.phone;

    return Sticker(
      color: AppTheme.surface,
      radius: 18,
      dy: 3,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  member.isOwner
                      ? 'Owner'
                      : member.isAccepted
                          ? 'Member'
                          : member.isRejected
                              ? 'Declined'
                              : 'Pending',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
                ),
              ],
            ),
          ),
          if (!member.isOwner && onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.inkFaint),
            ),
        ],
      ),
    );
  }
}
