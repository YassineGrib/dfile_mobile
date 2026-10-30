import 'package:flutter/material.dart';

import '../../projects/data/data.dart';
import '../data/milestone.dart';

/// Timeline (Gantt) view placeholder component per `docs/design/SPEC.md` (CL5).
///
/// Handed off to Agent B for full implementation.
class CalendarTimelineView extends StatelessWidget {
  const CalendarTimelineView({
    super.key,
    required this.now,
    this.projects,
    this.milestones,
    this.onProjectTap,
  });

  final DateTime now;
  final List<ProjectItem>? projects;
  final List<Milestone>? milestones;
  final void Function(ProjectItem project)? onProjectTap;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'CalendarTimelineView',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
