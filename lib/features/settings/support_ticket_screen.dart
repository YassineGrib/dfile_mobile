import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/primary_button.dart';
import 'data/data.dart';
import 'settings_about_strings.dart';
import 'widgets/settings_header.dart';

/// Screen for submitting a support ticket per `docs/design/SPEC.md` (ST13).
class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _subjectError;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    _subjectController.addListener(_onSubjectChanged);
    _messageController.addListener(_onMessageChanged);
  }

  void _onSubjectChanged() {
    if (_subjectError != null && _subjectController.text.trim().isNotEmpty) {
      setState(() => _subjectError = null);
    }
  }

  void _onMessageChanged() {
    if (_messageError != null && _messageController.text.trim().isNotEmpty) {
      setState(() => _messageError = null);
    }
  }

  @override
  void dispose() {
    _subjectController.removeListener(_onSubjectChanged);
    _messageController.removeListener(_onMessageChanged);
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final String subject = _subjectController.text.trim();
    final String message = _messageController.text.trim();

    setState(() {
      _subjectError =
          subject.isEmpty ? SettingsAboutStrings.subjectRequiredError : null;
      _messageError =
          message.isEmpty ? SettingsAboutStrings.messageRequiredError : null;
    });

    if (subject.isEmpty || message.isEmpty) {
      return;
    }

    final SettingsRepository repo = SettingsScope.of(context, listen: false);
    final SupportTicket ticket = SupportTicket(
      id: 'ticket-${DateTime.now().millisecondsSinceEpoch}',
      subject: subject,
      message: message,
      createdAt: DateTime.now(),
    );
    repo.addSupportTicket(ticket);

    final NavigatorState? nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) {
      nav.pop();
      showAppToast(nav.context, SettingsAboutStrings.ticketSentToast);
    } else {
      context.go(
        AppRoutes.settingsAboutPath,
        extra: <String, Object?>{'toast': SettingsAboutStrings.ticketSentToast},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          children: [
            SettingsHeader(
              title: SettingsAboutStrings.supportTicketTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.settingsPath),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Explanatory subtitle
            Text(
              SettingsAboutStrings.supportTicketSubtitle,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.mute,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Subject field
            AppTextField(
              label: SettingsAboutStrings.subjectLabel,
              placeholder: SettingsAboutStrings.subjectPlaceholder,
              controller: _subjectController,
              errorText: _subjectError,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Message details field (multiline)
            AppTextField(
              label: SettingsAboutStrings.messageLabel,
              placeholder: SettingsAboutStrings.messagePlaceholder,
              controller: _messageController,
              multiline: true,
              maxLines: 5,
              errorText: _messageError,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Submit ticket button
            PrimaryButton(
              label: SettingsAboutStrings.submitTicketButton,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
