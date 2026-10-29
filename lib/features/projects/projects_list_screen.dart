import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import 'data/data.dart';
import 'project_strings.dart';
import 'widgets/project_status_chip.dart';

/// Status filter modes shared between the horizontal status pills and the Filter sheet.
enum ProjectStatusFilter {
  all,
  planned,
  inProgress,
  completed,
  delivered,
  done,
}

/// Sort modes for the projects list (P3).
enum ProjectSort {
  newestFirst,
  nameAZ,
  highestBudget,
  progress,
  nearestDeadline,
}

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectStatusFilter _statusFilter = ProjectStatusFilter.all;
  String? _selectedCategory;
  String? _selectedClientId;
  ProjectSort _sort = ProjectSort.newestFirst;

  static const List<String> _defaultCategories = <String>[
    'Development',
    'Design',
    'Branding',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _statusFilter != ProjectStatusFilter.all ||
        _selectedCategory != null ||
        _selectedClientId != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = ProjectStatusFilter.all;
      _selectedCategory = null;
      _selectedClientId = null;
    });
  }

  String get _sortShortLabel {
    switch (_sort) {
      case ProjectSort.newestFirst:
        return ProjectStrings.sortShortNewest;
      case ProjectSort.nameAZ:
        return ProjectStrings.sortShortName;
      case ProjectSort.highestBudget:
        return ProjectStrings.sortShortBudget;
      case ProjectSort.progress:
        return ProjectStrings.sortShortProgress;
      case ProjectSort.nearestDeadline:
        return ProjectStrings.sortShortDeadline;
    }
  }

  bool _matchesStatusFilter(ProjectItem project, ProjectStatusFilter filter) {
    switch (filter) {
      case ProjectStatusFilter.all:
        return true;
      case ProjectStatusFilter.planned:
        return project.status == ProjectStatus.planned;
      case ProjectStatusFilter.inProgress:
        return project.status == ProjectStatus.inProgress ||
            project.status == ProjectStatus.waitingClient;
      case ProjectStatusFilter.completed:
        return project.status == ProjectStatus.completed;
      case ProjectStatusFilter.delivered:
        return project.status == ProjectStatus.delivered;
      case ProjectStatusFilter.done:
        return project.status == ProjectStatus.completed ||
            project.status == ProjectStatus.delivered;
    }
  }

  List<ProjectItem> _getFilteredAndSortedProjects(ProjectsRepository repo) {
    final String query = _searchController.text.trim().toLowerCase();

    final List<ProjectItem> filtered = repo.projects.where((
      ProjectItem project,
    ) {
      if (!_matchesStatusFilter(project, _statusFilter)) {
        return false;
      }
      if (_selectedCategory != null &&
          project.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
        return false;
      }
      if (_selectedClientId != null && project.clientId != _selectedClientId) {
        return false;
      }
      if (query.isNotEmpty) {
        final String clientName = repo.clientNameOf(project).toLowerCase();
        final bool nameMatch = project.name.toLowerCase().contains(query);
        final bool clientMatch = clientName.contains(query);
        final bool categoryMatch = project.category.toLowerCase().contains(
          query,
        );
        if (!nameMatch && !clientMatch && !categoryMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((ProjectItem a, ProjectItem b) {
      switch (_sort) {
        case ProjectSort.newestFirst:
          return b.createdAt.compareTo(a.createdAt);
        case ProjectSort.nameAZ:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case ProjectSort.highestBudget:
          return b.price.compareTo(a.price);
        case ProjectSort.progress:
          return b.progress.compareTo(a.progress);
        case ProjectSort.nearestDeadline:
          if (a.endDate == null && b.endDate == null) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          if (a.endDate == null) {
            return 1;
          }
          if (b.endDate == null) {
            return -1;
          }
          return a.endDate!.compareTo(b.endDate!);
      }
    });

    return filtered;
  }

  List<String> _availableCategories(ProjectsRepository repo) {
    final List<String> result = List<String>.of(_defaultCategories);
    for (final ProjectItem p in repo.projects) {
      if (!result.contains(p.category)) {
        result.add(p.category);
      }
    }
    return result;
  }

  List<Client> _availableClients(
    ProjectsRepository repo,
    ClientsRepository clientsRepo,
  ) {
    final Set<String> projectClientIds = repo.projects
        .map((ProjectItem p) => p.clientId)
        .toSet();
    if (_selectedClientId != null) {
      projectClientIds.add(_selectedClientId!);
    }
    final List<Client> withProjects = clientsRepo.clients
        .where((Client c) => projectClientIds.contains(c.id))
        .toList();
    return withProjects.isNotEmpty ? withProjects : clientsRepo.clients;
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
              Text(ProjectStrings.sortSheetTitle, style: AppText.sectionTitle),
              const SizedBox(height: AppSpacing.lg),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ProjectStrings.sortNewestFirst,
                sortValue: ProjectSort.newestFirst,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ProjectStrings.sortNameAZ,
                sortValue: ProjectSort.nameAZ,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ProjectStrings.sortHighestBudget,
                sortValue: ProjectSort.highestBudget,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ProjectStrings.sortProgress,
                sortValue: ProjectSort.progress,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ProjectStrings.sortNearestDeadline,
                sortValue: ProjectSort.nearestDeadline,
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
    required ProjectSort sortValue,
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
                  width: 1.5,
                ),
                color: isSelected ? AppColors.ink : AppColors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(
    ProjectsRepository repo,
    ClientsRepository clientsRepo,
  ) {
    String? draftCategory = _selectedCategory;
    String? draftClientId = _selectedClientId;
    ProjectStatusFilter draftStatus =
        (_statusFilter == ProjectStatusFilter.completed ||
            _statusFilter == ProjectStatusFilter.delivered)
        ? ProjectStatusFilter.done
        : _statusFilter;

    final List<String> categories = _availableCategories(repo);
    final List<Client> clients = _availableClients(repo, clientsRepo);

    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ProjectStrings.filterSheetTitle,
                          style: AppText.sectionTitle,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setSheetState(() {
                            draftCategory = null;
                            draftClientId = null;
                            draftStatus = ProjectStatusFilter.all;
                          });
                        },
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            ProjectStrings.reset,
                            style: AppText.bodyBold.copyWith(
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Category section
                  Text(
                    ProjectStrings.filterSectionCategory,
                    style: AppText.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppPill(
                        label: ProjectStrings.filterAll,
                        selected: draftCategory == null,
                        onTap: () => setSheetState(() => draftCategory = null),
                      ),
                      ...categories.map(
                        (String category) => AppPill(
                          label: category,
                          selected: draftCategory == category,
                          onTap: () =>
                              setSheetState(() => draftCategory = category),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Client section
                  Text(
                    ProjectStrings.filterSectionClient,
                    style: AppText.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppPill(
                        label: ProjectStrings.filterAll,
                        selected: draftClientId == null,
                        onTap: () => setSheetState(() => draftClientId = null),
                      ),
                      ...clients.map(
                        (Client client) => AppPill(
                          label: client.name,
                          selected: draftClientId == client.id,
                          onTap: () =>
                              setSheetState(() => draftClientId = client.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Status section
                  Text(
                    ProjectStrings.filterSectionStatus,
                    style: AppText.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppPill(
                        label: ProjectStrings.filterAll,
                        selected: draftStatus == ProjectStatusFilter.all,
                        onTap: () => setSheetState(
                          () => draftStatus = ProjectStatusFilter.all,
                        ),
                      ),
                      AppPill(
                        label: ProjectStrings.filterPlanned,
                        selected: draftStatus == ProjectStatusFilter.planned,
                        onTap: () => setSheetState(
                          () => draftStatus = ProjectStatusFilter.planned,
                        ),
                      ),
                      AppPill(
                        label: ProjectStrings.filterInProgress,
                        selected: draftStatus == ProjectStatusFilter.inProgress,
                        onTap: () => setSheetState(
                          () => draftStatus = ProjectStatusFilter.inProgress,
                        ),
                      ),
                      AppPill(
                        label: ProjectStrings.filterDone,
                        selected: draftStatus == ProjectStatusFilter.done,
                        onTap: () => setSheetState(
                          () => draftStatus = ProjectStatusFilter.done,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  PrimaryButton(
                    label: ProjectStrings.applyFilters,
                    onPressed: () {
                      setState(() {
                        _selectedCategory = draftCategory;
                        _selectedClientId = draftClientId;
                        _statusFilter = draftStatus;
                      });
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: ProjectStrings.cancel,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryTile({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: AppText.captionSm.copyWith(
                  color: AppColors.mute,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectsRepository repo, ProjectItem project) {
    final String clientName = repo.clientNameOf(project);
    final double paidAmount = repo.paid(project);
    final double remainingAmount = repo.remaining(project);
    final double paidFraction = repo.paidFraction(project);
    final bool isCleared = remainingAmount <= 0 && project.price > 0;
    final String deadlineText = project.endDate != null
        ? ProjectStrings.dueShort(formatShortDate(project.endDate!))
        : ProjectStrings.noDeadline;

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
            onTap: () => context.push('/projects/${project.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.label.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              project.name,
                              style: AppText.cardTitle.copyWith(fontSize: 19),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ProjectStatusChip(status: project.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Flexible(
                        child: ProjectCategoryChip(category: project.category),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          deadlineText,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(color: AppColors.mute),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ProjectStrings.paidAmount(formatMoney(paidAmount)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(color: AppColors.mute),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        isCleared
                            ? ProjectStrings.cleared
                            : ProjectStrings.dueAmount(
                                formatAmount(remainingAmount),
                              ),
                        style: AppText.label.copyWith(
                          color: isCleared ? AppColors.green : AppColors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.seg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: paidFraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCleared ? AppColors.green : AppColors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final List<ProjectItem> displayedProjects = _getFilteredAndSortedProjects(
      repo,
    );

    const List<(String, ProjectStatusFilter)> pillItems =
        <(String, ProjectStatusFilter)>[
          (ProjectStrings.filterAll, ProjectStatusFilter.all),
          (ProjectStrings.filterPlanned, ProjectStatusFilter.planned),
          (ProjectStrings.filterInProgress, ProjectStatusFilter.inProgress),
          (ProjectStrings.filterCompleted, ProjectStatusFilter.completed),
          (ProjectStrings.filterDelivered, ProjectStatusFilter.delivered),
        ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.projectsTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
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
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ProjectStrings.projectsTitle,
                                style: AppText.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hasActiveFilters
                                    ? ProjectStrings.projectsFound(
                                        displayedProjects.length,
                                      )
                                    : ProjectStrings.portfolioCount(
                                        repo.projects.length,
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
                              context.push(AppRoutes.addProjectPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Summary tiles
                    Row(
                      children: [
                        _buildSummaryTile(
                          label: ProjectStrings.summaryPortfolioValue,
                          value: formatCompactMoney(repo.portfolioValue),
                        ),
                        const SizedBox(width: 10),
                        _buildSummaryTile(
                          label: ProjectStrings.summaryAvgProgress,
                          value: '${repo.averageProgress}%',
                        ),
                        const SizedBox(width: 10),
                        _buildSummaryTile(
                          label: ProjectStrings.summaryActive,
                          value: '${repo.activeCount}',
                        ),
                      ],
                    ),
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
                          hintText: ProjectStrings.searchPlaceholder,
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

            // Horizontally scrollable status pills
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                key: const Key('project-status-pills'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < pillItems.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      AppPill(
                        label: pillItems[i].$1,
                        selected: _statusFilter == pillItems[i].$2,
                        onTap: () =>
                            setState(() => _statusFilter = pillItems[i].$2),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Count + Filter + Sort row
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
                        ProjectStrings.projectsListCount(
                          displayedProjects.length,
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
                      onTap: () => _openFilterSheet(repo, clientsRepo),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                        child: Text(
                          ProjectStrings.filterAction,
                          style: AppText.label.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: _openSortSheet,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${ProjectStrings.sortPrefix}$_sortShortLabel',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: AppText.label.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.mute,
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
                ),
              ),
            ),

            // Empty state or Project cards
            if (displayedProjects.isEmpty)
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
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              ProjectStrings.emptyTitle,
                              textAlign: TextAlign.center,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ProjectStrings.emptySubtitle,
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
                        label: ProjectStrings.clearFilters,
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
                      return _buildProjectCard(
                        context,
                        repo,
                        displayedProjects[index],
                      );
                    },
                    childCount: displayedProjects.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
