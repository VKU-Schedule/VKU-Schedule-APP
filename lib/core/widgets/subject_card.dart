import 'package:flutter/material.dart';

import '../../models/subject.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final int index;
  final bool isEnrolled;
  final bool isSkipped;
  final VoidCallback onEnroll;
  final VoidCallback onSkip;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.index,
    required this.isEnrolled,
    required this.isSkipped,
    required this.onEnroll,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.code} • ${subject.credits} tín chỉ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: isSkipped ? null : onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isEnrolled ? null : onEnroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnrolled
                    ? Colors.grey[300]
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: isEnrolled ? Colors.grey[600] : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: Icon(
                isEnrolled ? Icons.check_circle : Icons.check,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


