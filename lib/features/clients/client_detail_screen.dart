import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'client_strings.dart';
import 'data/data.dart';

enum DetailViewMode { overview, tabs }

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  DetailViewMode _viewMode = DetailViewMode.overview;
  int _selectedTab = 0; // 0: Projects, 1: Payments

  static const List<Color> _avatarColors = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];

  Color _avatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  void _popOrGoClients() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.clientsPath);
    }
  }

  void _copyToClipboard(String text, String successToast) {
    Clipboard.setData(ClipboardData(text: text));
    showAppToast(context, successToast);
  }

  void _openActionsSheet(Client client, ClientsRepository repo) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with avatar and name
            Row(
              children: [
                InitialAvatar(
                  initial: client.name,
                  color: _avatarColor(client.avatarColorIndex),
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: AppText.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        ClientStrings.addedDate(formatDate(client.createdAt)),
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action: View profile
            _buildActionItem(
              label: ClientStrings.actionsViewProfile,
              textColor: AppColors.ink,
              onTap: () {
                Navigator.of(sheetContext).pop();
                setState(() => _viewMode = DetailViewMode.overview);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Action: Edit client
            _buildActionItem(
              label: ClientStrings.actionsEditClient,
              textColor: AppColors.ink,
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/clients/${client.id}/edit');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Action: Copy email
            _buildActionItem(
              label: ClientStrings.actionsCopyEmail,
              textColor: AppColors.ink,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyToClipboard(client.email, ClientStrings.copiedEmailToast);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Action: Delete client (red)
            _buildActionItem(
              label: ClientStrings.actionsDeleteClient,
              textColor: AppColors.red,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openDeleteConfirmSheet(client, repo);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionItem({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppText.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _openDeleteConfirmSheet(Client client, ClientsRepository repo) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext confirmContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '!',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ClientStrings.deleteConfirmTitle,
                        style: AppText.sectionTitle.copyWith(
                          color: AppColors.red,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ClientStrings.deleteConfirmSubtitle,
                        style: AppText.caption.copyWith(color: AppColors.mute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Red warning container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                border: Border.all(
                  color: AppColors.red.withValues(alpha: 0.2),
                  width: AppSpacing.borderWidth,
                ),
              ),
              child: Text(
                ClientStrings.deleteConfirmWarning(client.name),
                style: AppText.bodyMedium.copyWith(
                  color: AppColors.red,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Confirm delete button
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: Material(
                color: AppColors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    repo.delete(client.id);
                    Navigator.of(confirmContext).pop();
                    _popOrGoClients();
                    showAppToast(context, ClientStrings.clientDeletedToast);
                  },
                  child: Center(
                    child: Text(
                      ClientStrings.confirmDelete,
                      style: AppText.button,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Cancel button
            SecondaryButton(
              label: ClientStrings.cancel,
              onPressed: () => Navigator.of(confirmContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar({
    required String title,
    required VoidCallback onBack,
    required VoidCallback onMore,
  }) {
    return Row(
      children: [
        RoundIconButton(icon: Icons.arrow_back, onPressed: onBack),
        Expanded(
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
        ),
        RoundIconButton(icon: Icons.more_horiz, onPressed: onMore),
      ],
    );
  }

  Widget _buildContactRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: AppText.label)),
          Expanded(
            child: Text(
              value,
              style: AppText.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                ClientStrings.copyAction,
                style: AppText.captionSm.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChips(Client client) {
    final List<String> links = <String>[];
    if (client.linkedin.isNotEmpty) {
      links.add('LinkedIn');
    }
    if (client.github.isNotEmpty) {
      links.add('GitHub');
    }
    if (client.twitter.isNotEmpty) {
      links.add('Twitter');
    }
    if (client.website.isNotEmpty && client.id != 'c1') {
      links.add('Website');
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(ClientStrings.contactLinks, style: AppText.label),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: links.map((String text) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.seg,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    text,
                    style: AppText.captionSm.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTile({
    required String label,
    required String value,
    required Color valueColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.label.copyWith(fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent(Client client, ClientsRepository repo) {
    final double budgetVal = repo.budget(client);
    final double clearedVal = repo.totalRevenue(client);
    final double outstandingVal = repo.outstanding(client);
    final double netProfitVal = repo.netProfit(client);
    final bool isActive = repo.isActive(client);

    return Column(
      children: [
        // Avatar, Name, Joined, Status
        InitialAvatar(
          initial: client.name,
          color: _avatarColor(client.avatarColorIndex),
          size: 80,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(client.name, style: AppText.sectionTitleLg),
        const SizedBox(height: 4),
        Text(
          ClientStrings.joinedDate(formatDate(client.createdAt)),
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        StatusPill(isActive: isActive),
        const SizedBox(height: AppSpacing.xl),

        // Quick actions row (Call, Email, Copy)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickActionButton(
              icon: Icons.phone,
              label: ClientStrings.quickActionCall,
              onTap: () =>
                  showAppToast(context, ClientStrings.demoNotAvailableToast),
            ),
            const SizedBox(width: AppSpacing.xxl),
            _buildQuickActionButton(
              icon: Icons.alternate_email,
              label: ClientStrings.quickActionEmail,
              onTap: () =>
                  showAppToast(context, ClientStrings.demoNotAvailableToast),
            ),
            const SizedBox(width: AppSpacing.xxl),
            _buildQuickActionButton(
              icon: Icons.copy_rounded,
              label: ClientStrings.quickActionCopy,
              onTap: () => _copyToClipboard(
                client.phone,
                ClientStrings.copiedPhoneToast,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Contact card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Column(
            children: [
              _buildContactRow(
                label: ClientStrings.contactEmail,
                value: client.email.isEmpty ? '—' : client.email,
                onCopy: () => _copyToClipboard(
                  client.email,
                  ClientStrings.copiedEmailToast,
                ),
              ),
              const Divider(color: AppColors.line, height: 1, thickness: 1),
              _buildContactRow(
                label: ClientStrings.contactPhone,
                value: client.phone.isEmpty ? '—' : client.phone,
                onCopy: () => _copyToClipboard(
                  client.phone,
                  ClientStrings.copiedPhoneToast,
                ),
              ),
              const Divider(color: AppColors.line, height: 1, thickness: 1),
              _buildContactRow(
                label: ClientStrings.contactAddress,
                value: client.address.isEmpty ? '—' : client.address,
                onCopy: () => _copyToClipboard(
                  client.address,
                  ClientStrings.copiedAddressToast,
                ),
              ),
              const Divider(color: AppColors.line, height: 1, thickness: 1),
              _buildSocialChips(client),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Finance 2x2 grid
        Row(
          children: [
            _buildFinanceTile(
              label: ClientStrings.financeBudget,
              value: formatMoney(budgetVal),
              valueColor: AppColors.ink,
              onTap: () => setState(() {
                _viewMode = DetailViewMode.tabs;
                _selectedTab = 0;
              }),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildFinanceTile(
              label: ClientStrings.financeCleared,
              value: formatMoney(clearedVal),
              valueColor: AppColors.green,
              onTap: () => setState(() {
                _viewMode = DetailViewMode.tabs;
                _selectedTab = 1;
              }),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildFinanceTile(
              label: ClientStrings.financeOutstanding,
              value: formatMoney(outstandingVal),
              valueColor: AppColors.coral,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildFinanceTile(
              label: ClientStrings.financeProfit,
              value: formatMoney(netProfitVal),
              valueColor: AppColors.ink,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Edit client button
        PrimaryButton(
          label: ClientStrings.editClient,
          onPressed: () => context.push('/clients/${client.id}/edit'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        RoundIconButton(size: 52, icon: icon, onPressed: onTap),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppText.captionSm.copyWith(
            color: AppColors.mute,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsTab(Client client) {
    if (client.projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Center(
          child: Text(
            'No projects found',
            style: AppText.bodyMedium.copyWith(color: AppColors.mute),
          ),
        ),
      );
    }

    return Column(
      children: client.projects.map((Project project) {
        Color statusBg = AppColors.seg;
        Color statusFg = AppColors.mute;
        Color progressColor = AppColors.ink;

        if (project.status == 'In Progress') {
          statusBg = AppColors.orangeBg;
          statusFg = AppColors.orange;
          progressColor = AppColors.orange;
        } else if (project.status == 'Waiting Client') {
          statusBg = AppColors.purpleBg;
          statusFg = AppColors.purple;
          progressColor = AppColors.purple;
        } else if (project.status == 'Completed') {
          statusBg = AppColors.greenBg;
          statusFg = AppColors.green;
          progressColor = AppColors.green;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(project.name, style: AppText.cardTitle),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        project.status,
                        style: AppText.captionSm.copyWith(
                          color: statusFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formatMoney(project.price),
                  style: AppText.body.copyWith(color: AppColors.mute),
                ),
                const SizedBox(height: AppSpacing.md),
                // Progress bar
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.seg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (project.progress / 100.0).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ClientStrings.completePercent(project.progress),
                  style: AppText.captionSm.copyWith(color: AppColors.mute),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentsTab(Client client, ClientsRepository repo) {
    final double totalCleared = repo.totalRevenue(client);

    return Column(
      children: [
        if (client.payments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                'No payments found',
                style: AppText.bodyMedium.copyWith(color: AppColors.mute),
              ),
            ),
          )
        else
          ...client.payments.map((Payment payment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.greenBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ClientStrings.paymentReceived,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${payment.date} • ${payment.reference}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '+${formatMoney(payment.amount)}',
                      style: AppText.cardTitle.copyWith(
                        fontSize: 17,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        // Total cleared card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  ClientStrings.totalCleared,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                formatMoney(totalCleared),
                style: AppText.sectionTitle.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClientsRepository repo = ClientsScope.of(context);
    final Client? client = repo.byId(widget.clientId);

    if (client == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ClientStrings.clientNotFound, style: AppText.sectionTitle),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: ClientStrings.backToClients,
                  onPressed: () => context.go(AppRoutes.clientsPath),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool isOverview = _viewMode == DetailViewMode.overview;

    return PopScope(
      canPop: isOverview,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          setState(() => _viewMode = DetailViewMode.overview);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.lg,
              AppSpacing.pageGutter,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBar(
                  title: isOverview
                      ? ClientStrings.clientDetailTitle
                      : client.name,
                  onBack: () {
                    if (isOverview) {
                      _popOrGoClients();
                    } else {
                      setState(() => _viewMode = DetailViewMode.overview);
                    }
                  },
                  onMore: () => _openActionsSheet(client, repo),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (isOverview) ...[
                  _buildOverviewContent(client, repo),
                ] else ...[
                  SegmentedToggle(
                    options: const <String>[
                      ClientStrings.tabProjects,
                      ClientStrings.tabPayments,
                    ],
                    selectedIndex: _selectedTab,
                    onChanged: (int index) {
                      setState(() => _selectedTab = index);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_selectedTab == 0)
                    _buildProjectsTab(client)
                  else
                    _buildPaymentsTab(client, repo),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
