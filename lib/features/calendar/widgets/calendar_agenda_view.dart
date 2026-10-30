import 'package:flutter/material.dart';

import '../data/calendar_events.dart';

/// Agenda view placeholder component per `docs/design/SPEC.md` (CL4).
///
/// Handed off to Agent B for full implementation.
class CalendarAgendaView extends StatelessWidget {
  const CalendarAgendaView({
    super.key,
    required this.events,
    required this.now,
    this.onEventTap,
  });

  final List<CalendarEvent> events;
  final DateTime now;
  final void Function(CalendarEvent event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'CalendarAgendaView',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
