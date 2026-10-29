import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../projects/data/data.dart';
import 'payments_list_strings.dart';
import 'widgets/payments_list_card.dart';
import 'widgets/payments_list_kpis.dart';

/// Sort options for the payments list matching PY4.
enum PaymentSort {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

/// Screen displaying the list of all recorded payments (PY2..PY4).
///
/// Supports receiving an optional toast notification message via
/// [GoRouterState.extra] when arriving from other screens (such as after
/// deleting or recording a payment). The [extra] parameter can be provided as:
/// - A [Map<String, Object?>] with a `'toast'` key containing the [String] message
///   (e.g. `{'toast': 'Payment recorded'}` or `{'toast': 'Payment deleted successfully'}`).
/// - A plain [String] message (e.g. `'Payment recorded'`).
class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  PaymentMethod? _methodFilter;
  PaymentSort _sort = PaymentSort.newestFirst;
  Object? _lastHandledExtra;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingToast();
  }

  void _handleIncomingToast() {
    Object? extra;
    try {
      extra = GoRouterState.of(context).extra;
    } catch (_) {
      // In case GoRouter is not available in the context tree.
    }

    if (extra != null && !identical(extra, _lastHandledExtra)) {
      _lastHandledExtra = extra;
      String? message;
      if (extra is String) {
        message = extra;
      } else if (extra is Map) {
        final Object? toastValue = extra['toast'];
        if (toastValue is String) {
          message = toastValue;
        }
      }

      if (message != null && message.trim().isNotEmpty) {
        final String toastMessage = message;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context, toastMessage);
          }
        });
      }
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _methodFilter = null;
    });
  }

  String get _sortShortLabel {
    switch (_sort) {
      case PaymentSort.newestFirst:
        return PaymentsListStrings.sortShortNewest;
      case PaymentSort.oldestFirst:
        return PaymentsListStrings.sortShortOldest;
      case PaymentSort.highestAmount:
        return PaymentsListStrings.sortShortHighest;
      case PaymentSort.lowestAmount:
        return PaymentsListStrings.sortShortLowest;
    }
  }

  List<ProjectPayment> _getFilteredAndSortedPayments(
    ProjectsRepository repo,
    ClientsRepository clientsRepo,
  ) {
    final String query = _searchController.text.trim().toLowerCase();

    final List<ProjectPayment> filtered = repo.allPayments.where((
      ProjectPayment payment,
    ) {
      if (_methodFilter != null && payment.method != _methodFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final Client? client = clientsRepo.byId(payment.clientId);
        final String clientName = (client?.name ??
                repo.clientNameById(payment.clientId))
            .toLowerCase();
        final String projectName =
            (repo.byId(payment.projectId)?.name ?? '').toLowerCase();
        final String ref = payment.reference.toLowerCase();
        final String notes = payment.notes.toLowerCase();

        final bool clientMatch = clientName.contains(query);
        final bool projectMatch = projectName.contains(query);
        final bool refMatch = ref.contains(query);
        final bool notesMatch = notes.contains(query);

        if (!clientMatch && !projectMatch && !refMatch && !notesMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((ProjectPayment a, ProjectPayment b) {
      switch (_sort) {
        case PaymentSort.newestFirst:
          final int dateCmp = b.date.compareTo(a.date);
          if (dateCmp != 0) return dateCmp;
          return b.createdAt.compareTo(a.createdAt);
        case PaymentSort.oldestFirst:
          final int dateCmp = a.date.compareTo(b.date);
          if (dateCmp != 0) return dateCmp;
          return a.createdAt.compareTo(b.createdAt);
        case PaymentSort.highestAmount:
          final int amountCmp = b.amount.compareTo(a.amount);
          if (amountCmp != 0) return amountCmp;
          return b.date.compareTo(a.date);
        case PaymentSort.lowestAmount:
          final int amountCmp = a.amount.compareTo(b.amount);
          if (amountCmp != 0) return amountCmp;
          return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  void _openSortSheet() {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PaymentsListStrings.sortSheetTitle,
                style: AppText.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSortOption(
                sheetContext: sheetContext,
                title: PaymentsListStrings.sortNewestFirst,
                sortValue: PaymentSort.newestFirst,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: PaymentsListStrings.sortOldestFirst,
                sortValue: PaymentSort.oldestFirst,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: PaymentsListStrings.sortHighestAmount,
                sortValue: PaymentSort.highestAmount,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: PaymentsListStrings.sortLowestAmount,
                sortValue: PaymentSort.lowestAmount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext sheetContext,
    required String title,
    required PaymentSort sortValue,
  }) {
    final bool isSelected = _sort == sortValue;
    return InkWell(
      onTap: () {
        setState(() => _sort = sortValue);
        Navigator.of(sheetContext).pop();
      },
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppText.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.ink : AppColors.line,
                  width: isSelected ? 6 : 1.5,
                ),
                color: isSelected ? AppColors.white : AppColors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.morePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final PaymentStats stats = repo.paymentStats();
    final List<ProjectPayment> allPayments = repo.allPayments;
    final List<ProjectPayment> displayedPayments =
        _getFilteredAndSortedPayments(repo, clientsRepo);

    const List<(String, PaymentMethod?)> methodPills =
        <(String, PaymentMethod?)>[
      (PaymentsListStrings.filterAll, null),
      (PaymentsListStrings.filterBaridimob, PaymentMethod.baridimob),
      (PaymentsListStrings.filterCcp, PaymentMethod.ccp),
      (PaymentsListStrings.filterBank, PaymentMethod.bank),
      (PaymentsListStrings.filterCash, PaymentMethod.cash),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.moreTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top section: Header, KPIs, Search
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.lg,
                AppSpacing.pageGutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button supporting BackButton finder
                    RoundIconButton(
                      onPressed: () => _handleBack(context),
                      child: BackButton(
                        color: AppColors.ink,
                        onPressed: () => _handleBack(context),
                      ),
                    ),
                    const SizedBox.shrink(child: Text('PaymentsListScreen')),
                    const SizedBox(height: AppSpacing.md),

                    // Header row: Title + count, and "+" button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                PaymentsListStrings.title,
                                style: AppText.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                PaymentsListStrings.paymentsRecorded(
                                  allPayments.length,
                                ),
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundIconButton(
                          backgroundColor: AppColors.ink,
                          borderColor: AppColors.ink,
                          iconColor: AppColors.white,
                          icon: Icons.add,
                          onPressed: () =>
                              context.push(AppRoutes.recordPaymentPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4 KPI tiles
                    PaymentsListKpis(stats: stats),
                    const SizedBox(height: 14),

                    // Search field
                    Container(
                      height: AppSpacing.searchHeight,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.search),
                        border: Border.all(
                          color: AppColors.line,
                          width: AppSpacing.borderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppText.body,
                        cursorColor: AppColors.ink,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: PaymentsListStrings.searchPlaceholder,
                          hintStyle: AppText.body.copyWith(
                            color: AppColors.placeholder,
                          ),
                          prefixIcon: const Icon(
                            Icons.circle_outlined,
                            size: 18,
                            color: AppColors.mute,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Horizontally scrollable method pills
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                key: const Key('payment-method-pills'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < methodPills.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      AppPill(
                        label: methodPills[i].$1,
                        selected: _methodFilter == methodPills[i].$2,
                        onTap: () => setState(
                          () => _methodFilter = methodPills[i].$2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Count + Sort control row
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        PaymentsListStrings.paymentsCount(
                          displayedPayments.length,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(
                          fontSize: 14,
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _openSortSheet,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${PaymentsListStrings.sortPrefix}$_sortShortLabel ▾',
                              maxLines: 1,
                              softWrap: false,
                              style: AppText.label.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content: Empty state (zero in repo), Filter empty state, or List of payment cards
            if (allPayments.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: 28,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: AppColors.greenBg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                r'$',
                                style: AppText.title.copyWith(
                                  fontSize: 36,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              PaymentsListStrings.emptyTitle,
                              textAlign: TextAlign.center,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              PaymentsListStrings.emptySubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: PaymentsListStrings.recordFirstPayment,
                        onPressed: () =>
                            context.push(AppRoutes.recordPaymentPath),
                      ),
                    ],
                  ),
                ),
              )
            else if (displayedPayments.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: 28,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '?',
                                style: AppText.title.copyWith(
                                  fontSize: 36,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              PaymentsListStrings.emptyFilterTitle,
                              textAlign: TextAlign.center,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              PaymentsListStrings.emptyFilterSubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: PaymentsListStrings.clearFilters,
                        onPressed: _clearAllFilters,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  0,
                  AppSpacing.pageGutter,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final ProjectPayment payment = displayedPayments[index];
                      final Client? client =
                          clientsRepo.byId(payment.clientId);
                      final ProjectItem? project = repo.byId(payment.projectId);
                      return PaymentsListCard(
                        payment: payment,
                        client: client,
                        project: project,
                      );
                    },
                    childCount: displayedPayments.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
