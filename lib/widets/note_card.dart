import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/constant.dart';
import 'package:provider/provider.dart';
import 'package:note_app/provider/note_provider.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, 
    required this.note,
    required this.onTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 7) {
    // Show real date after 7 days
      return DateFormat('dd MMM yyyy').format(dateTime);
  } else if (difference.inDays > 1) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.getColorFromHex(note.color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Favourite toggle
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    note.isFavourite ? Icons.star : Icons.star_border,
                    color: note.isFavourite ? Colors.yellow[700] : Colors.black54,
                  ),
                  onPressed: () async {
                    // Toggle favourite locally and update
                    final provider = Provider.of<NoteProvider>(context, listen: false);
                    final updated = note.copyWith(
                      isFavourite: !note.isFavourite,
                      updatedAt: DateTime.now(),
                    );
                    try {
                      await provider.updateNote(updated);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating favourite: $e')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(width: 4),
                // Reminder indicator
                if (note.reminder != null)
                  Tooltip(
                    message: 'Reminder: ${note.reminder}',
                    child: Icon(
                      Icons.notifications_active,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Content preview
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Time stamp
            Text(
              _getTimeAgo(note.updatedAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}