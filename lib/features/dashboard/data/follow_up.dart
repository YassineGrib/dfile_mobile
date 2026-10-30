import 'package:url_launcher/url_launcher.dart';

import '../../../core/format.dart';
import '../../clients/data/client.dart';
import '../../projects/data/project.dart';
import '../../projects/data/projects_repository.dart';

/// A client who still owes money, with what is left on each project.
class FollowUp {
  const FollowUp({
    required this.client,
    required this.outstanding,
    required this.projectNames,
  });

  final Client client;
  final double outstanding;
  final List<String> projectNames;
}

/// Clients with an unpaid balance on a project that is not cancelled, largest
/// balance first. Projects that are paid in full are ignored.
List<FollowUp> followUps({
  required ProjectsRepository projects,
  required List<Client> clients,
  int limit = 3,
}) {
  final Map<String, double> owed = <String, double>{};
  final Map<String, List<String>> names = <String, List<String>>{};
  for (final ProjectItem p in projects.projects) {
    if (p.status == ProjectStatus.cancelled) continue;
    final double left = projects.remaining(p);
    if (left <= 0) continue;
    owed[p.clientId] = (owed[p.clientId] ?? 0) + left;
    (names[p.clientId] ??= <String>[]).add(p.name);
  }
  final List<FollowUp> result = <FollowUp>[];
  for (final Client c in clients) {
    final double amount = owed[c.id] ?? 0;
    if (amount > 0) {
      result.add(
        FollowUp(
          client: c,
          outstanding: amount,
          projectNames: names[c.id] ?? const <String>[],
        ),
      );
    }
  }
  result.sort(
    (FollowUp a, FollowUp b) => b.outstanding.compareTo(a.outstanding),
  );
  return result.take(limit).toList();
}

/// The message pre-filled in WhatsApp.
String reminderMessage(FollowUp item) {
  final String first = item.client.name.trim().split(RegExp(r'\s+')).first;
  final String what = item.projectNames.length == 1
      ? 'for "${item.projectNames.first}"'
      : 'across ${item.projectNames.length} projects';
  return 'Hello $first, a friendly reminder that ${formatMoney(item.outstanding)} '
      'is still outstanding $what. Thank you!';
}

/// Digits only, with the Algerian country code added to a local number such as
/// "0550 12 34 56". Returns null when there is no usable number.
String? whatsappNumber(String phone) {
  final String raw = phone.trim();
  if (raw.isEmpty) return null;
  String digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (raw.startsWith('+')) return digits;
  if (digits.startsWith('00')) return digits.substring(2);
  if (digits.startsWith('0')) return '213${digits.substring(1)}';
  return digits;
}

Uri? whatsappUri(FollowUp item) {
  final String? number = whatsappNumber(item.client.phone);
  if (number == null) return null;
  return Uri.https('wa.me', '/$number', <String, String>{
    'text': reminderMessage(item),
  });
}

/// Opens a link outside the app. Replaced in tests.
Future<bool> Function(Uri uri) openExternalLink = (Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);
