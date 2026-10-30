import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'client_strings.dart';
import 'data/data.dart';

enum ClientFilter { all, active, inactive }

enum ClientSort { nameAZ, highestRevenue, newestFirst }

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ClientFilter _filter = ClientFilter.all;
  ClientSort _sort = ClientSort.nameAZ;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _sortLabel {
    switch (_sort) {
      case ClientSort.nameAZ:
        return ClientStrings.sortName;
      case ClientSort.highestRevenue:
        return ClientStrings.sortRevenue;
      case ClientSort.newestFirst:
        return ClientStrings.sortNewest;
    }
  }

  void _openSortSheet() {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ClientStrings.sortSheetTitle, style: AppText.sectionTitle),
            const SizedBox(height: AppSpacing.lg),
            _buildSortOption(
              sheetContext: sheetContext,
              title: ClientStrings.sortNameAZ,
              sortValue: ClientSort.nameAZ,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSortOption(
              sheetContext: sheetContext,
              title: ClientStrings.sortHighestRevenue,
              sortValue: ClientSort.highestRevenue,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSortOption(
              sheetContext: sheetContext,
              title: ClientStrings.sortNewestFirst,
              sortValue: ClientSort.newestFirst,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext sheetContext,
    required String title,
    required ClientSort sortValue,
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
                color: isSelected ? AppColors.ink : AppColors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Client> _getFilteredAndSortedClients(ClientsRepository repo) {
    final String query = _searchController.text.trim().toLowerCase();
    final String normalizedQuery = query.replaceAll(' ', '');

    final List<Client> filtered = repo.clients.where((Client client) {
      if (_filter == ClientFilter.active && !repo.isActive(client)) {
        return false;
      }
      if (_filter == ClientFilter.inactive && repo.isActive(client)) {
        return false;
      }

      if (query.isNotEmpty) {
        final bool nameMatch = client.name.toLowerCase().contains(query);
        final bool emailMatch = client.email.toLowerCase().contains(query);
        final bool phoneMatch = client.phone
            .replaceAll(' ', '')
            .contains(normalizedQuery);
        if (!nameMatch && !emailMatch && !phoneMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((Client a, Client b) {
      switch (_sort) {
        case ClientSort.nameAZ:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case ClientSort.highestRevenue:
          return repo.totalRevenue(b).compareTo(repo.totalRevenue(a));
        case ClientSort.newestFirst:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  Widget _socialDot(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppText.captionSm.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClientsRepository repo = ClientsScope.of(context);
    final List<Client> displayedClients = _getFilteredAndSortedClients(repo);
    final bool isSearchActive =
        _searchController.text.trim().isNotEmpty || _filter != ClientFilter.all;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.clientsTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.xl,
                AppSpacing.pageGutter,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ClientStrings.clientsTitle,
                                style: AppText.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSearchActive
                                    ? ClientStrings.clientsFound(
                                        displayedClients.length,
                                      )
                                    : ClientStrings.clientsCount(
                                        repo.clients.length,
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
                              context.push(AppRoutes.addClientPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

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
                          hintText: ClientStrings.searchPlaceholder,
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
                    const SizedBox(height: AppSpacing.lg),

                    // Filters and sort row
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        const double minSortWidth = 72;
                        final double maxPillsWidth =
                            (constraints.maxWidth -
                                    AppSpacing.sm -
                                    minSortWidth)
                                .clamp(0.0, constraints.maxWidth);
                        return Row(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxPillsWidth,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppPill.compact(
                                      label: ClientStrings.filterAll,
                                      selected: _filter == ClientFilter.all,
                                      onTap: () => setState(
                                        () => _filter = ClientFilter.all,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AppPill.compact(
                                      label: ClientStrings.filterActive,
                                      selected: _filter == ClientFilter.active,
                                      onTap: () => setState(
                                        () => _filter = ClientFilter.active,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AppPill.compact(
                                      label: ClientStrings.filterInactive,
                                      selected:
                                          _filter == ClientFilter.inactive,
                                      onTap: () => setState(
                                        () => _filter = ClientFilter.inactive,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: _openSortSheet,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${ClientStrings.sortPrefix}$_sortLabel',
                                            maxLines: 1,
                                            softWrap: false,
                                            style: AppText.caption.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.mute,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            size: 16,
                                            color: AppColors.mute,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content: Empty state or Cards list
            if (displayedClients.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
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
                          vertical: 48,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '?',
                                style: AppText.title.copyWith(
                                  fontSize: 38,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              ClientStrings.emptyTitle,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ClientStrings.emptySubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: ClientStrings.addClientWithPlus,
                        onPressed: () => context.push(AppRoutes.addClientPath),
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
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final Client client = displayedClients[index];
                    final double revenue = repo.totalRevenue(client);
                    final int activeProjs = repo.activeProjectsCount(client);
                    final bool isActive = repo.isActive(client);

                    final List<Widget> dots = <Widget>[];
                    if (client.github.isNotEmpty) {
                      dots.add(_socialDot('gh'));
                    }
                    if (client.twitter.isNotEmpty) {
                      dots.add(_socialDot('x'));
                    }
                    if (client.linkedin.isNotEmpty) {
                      dots.add(_socialDot('in'));
                    }
                    if (client.website.isNotEmpty && client.id != 'c1') {
                      dots.add(_socialDot('web'));
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.line,
                            width: AppSpacing.borderWidth,
                          ),
                        ),
                        child: Material(
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            onTap: () => context.push('/clients/${client.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      UserAvatar(name: client.name, size: 48),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              client.name,
                                              style: AppText.cardTitle,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              ClientStrings.addedDate(
                                                formatDate(client.createdAt),
                                              ),
                                              style: AppText.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusPill(isActive: isActive),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const Divider(
                                    color: AppColors.line,
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Text(
                                        formatMoney(revenue),
                                        style: AppText.cardTitle.copyWith(
                                          fontSize: 17,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: activeProjs > 0
                                                        ? AppColors.green
                                                        : AppColors.mute,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '$activeProjs active projs',
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  style: AppText.captionSm
                                                      .copyWith(
                                                        color: activeProjs > 0
                                                            ? AppColors.green
                                                            : AppColors.mute,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      ...dots,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: displayedClients.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
