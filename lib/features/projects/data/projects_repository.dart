import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/format.dart';
import '../../clients/data/data.dart';
import '../project_strings.dart';
import 'project.dart';

/// In-memory repository managing portfolio projects, tasks, payments, and client sync.
class ProjectsRepository extends ChangeNotifier {
  ProjectsRepository({
    ClientsRepository? clientsRepository,
    List<ProjectItem>? initialProjects,
    List<ProjectTask>? initialTasks,
    List<ProjectPayment>? initialPayments,
  }) : clientsRepository = clientsRepository ?? ClientsRepository(),
       _projects = List<ProjectItem>.of(
         initialProjects ?? _createInitialProjects(),
       ),
       _tasks = List<ProjectTask>.of(initialTasks ?? _createInitialTasks()),
       _payments = List<ProjectPayment>.of(
         initialPayments ?? _createInitialPayments(),
       ) {
    for (final ProjectItem project in _projects) {
      _projectClientHistory[project.id] = project.clientId;
    }
  }

  final ClientsRepository clientsRepository;
  final List<ProjectItem> _projects;
  final List<ProjectTask> _tasks;
  final List<ProjectPayment> _payments;
  final Map<String, String> _projectClientHistory = <String, String>{};
  int _idCounter = 100;

  List<ProjectItem> get projects => List<ProjectItem>.unmodifiable(_projects);

  List<ProjectTask> get tasks => List<ProjectTask>.unmodifiable(_tasks);

  List<ProjectPayment> get payments =>
      List<ProjectPayment>.unmodifiable(_payments);

  /// Finds a project by [id], returning `null` if not found.
  ProjectItem? byId(String id) {
    for (final ProjectItem project in _projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }

  /// Resolves the display name of the client owning [project].
  String clientNameOf(ProjectItem project) {
    return clientNameById(project.clientId);
  }

  /// Resolves the display name of a client by [clientId].
  String clientNameById(String clientId) {
    return clientsRepository.byId(clientId)?.name ??
        ProjectStrings.unknownClient;
  }

  /// Returns all tasks belonging to [projectId].
  List<ProjectTask> tasksOf(String projectId) {
    return _tasks
        .where((ProjectTask task) => task.projectId == projectId)
        .toList(growable: false);
  }

  /// Returns all payments recorded for [projectId].
  List<ProjectPayment> paymentsOf(String projectId) {
    return _payments
        .where((ProjectPayment payment) => payment.projectId == projectId)
        .toList(growable: false);
  }

  /// Adds a new project (and optional initial [tasks]) and syncs its client.
  void add(
    ProjectItem project, {
    List<ProjectTask> tasks = const <ProjectTask>[],
  }) {
    final ProjectItem normalized = _normalizeStatusProgress(project);
    _projects.add(normalized);
    _projectClientHistory[normalized.id] = normalized.clientId;
    if (tasks.isNotEmpty) {
      _tasks.addAll(tasks);
    }
    _syncClient(normalized.clientId);
    notifyListeners();
  }

  /// Updates an existing project and syncs affected client(s).
  void update(ProjectItem project) {
    final int index = _projects.indexWhere(
      (ProjectItem p) => p.id == project.id,
    );
    if (index == -1) {
      return;
    }
    final String previousClientId = _projects[index].clientId;
    final ProjectItem normalized = _normalizeStatusProgress(project);
    _projects[index] = normalized;
    _projectClientHistory[normalized.id] = normalized.clientId;

    if (previousClientId != normalized.clientId) {
      _syncClient(previousClientId);
    }
    _syncClient(normalized.clientId);
    notifyListeners();
  }

  /// Deletes a project and its tasks while retaining recorded ledger payments.
  void delete(String id) {
    final int index = _projects.indexWhere((ProjectItem p) => p.id == id);
    if (index == -1) {
      return;
    }
    final String clientId = _projects[index].clientId;
    _projectClientHistory[id] = clientId;
    _projects.removeAt(index);
    _tasks.removeWhere((ProjectTask t) => t.projectId == id);
    _syncClient(clientId);
    notifyListeners();
  }

  /// Toggles a task between [TaskStatus.complete] and [TaskStatus.nextUp].
  void toggleTask(String taskId) {
    final int index = _tasks.indexWhere((ProjectTask t) => t.id == taskId);
    if (index == -1) {
      return;
    }
    final ProjectTask current = _tasks[index];
    final TaskStatus nextStatus = current.status.isComplete
        ? TaskStatus.nextUp
        : TaskStatus.complete;
    _tasks[index] = current.copyWith(status: nextStatus);
    notifyListeners();
  }

  /// Appends a new task to [projectId] and notifies listeners.
  ProjectTask addTask(
    String projectId,
    String name, {
    DateTime? due,
    TaskStatus status = TaskStatus.nextUp,
  }) {
    _idCounter++;
    final ProjectTask task = ProjectTask(
      id: 't_$_idCounter',
      projectId: projectId,
      name: name.trim(),
      due: due,
      status: status,
    );
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  /// Updates [projectId]'s status; [ProjectStatus.completed] and [ProjectStatus.delivered] force progress to 100.
  void changeStatus(String projectId, ProjectStatus status) {
    final int index = _projects.indexWhere(
      (ProjectItem p) => p.id == projectId,
    );
    if (index == -1) {
      return;
    }
    final ProjectItem current = _projects[index];
    final int nextProgress = status.forcesFullProgress ? 100 : current.progress;
    final ProjectItem updated = current.copyWith(
      status: status,
      progress: nextProgress,
    );
    _projects[index] = updated;
    _syncClient(updated.clientId);
    notifyListeners();
  }

  /// Records a new [payment] and syncs the owning client's embedded payments list.
  void addPayment(ProjectPayment payment) {
    _payments.add(payment);
    final ProjectItem? project = byId(payment.projectId);
    final String? clientId =
        project?.clientId ?? _projectClientHistory[payment.projectId];
    if (clientId != null) {
      _syncClient(clientId);
    }
    notifyListeners();
  }

  /// Sum of recorded payments for [project].
  double paid(ProjectItem project) {
    return _payments
        .where((ProjectPayment p) => p.projectId == project.id)
        .fold<double>(0.0, (double sum, ProjectPayment p) => sum + p.amount);
  }

  /// Remaining balance due for [project] (`>= 0`).
  double remaining(ProjectItem project) {
    return math.max(0.0, project.price - paid(project));
  }

  /// Clamped fraction (`0.0..1.0`) of [project]'s budget that has been paid.
  double paidFraction(ProjectItem project) {
    if (project.price <= 0) {
      return 0.0;
    }
    return (paid(project) / project.price).clamp(0.0, 1.0);
  }

  /// Total contract value across all projects in the portfolio.
  double get portfolioValue {
    return _projects.fold<double>(
      0.0,
      (double sum, ProjectItem p) => sum + p.price,
    );
  }

  /// Rounded mean progress percentage (`0..100`) across all projects.
  int get averageProgress {
    if (_projects.isEmpty) {
      return 0;
    }
    final int total = _projects.fold<int>(
      0,
      (int sum, ProjectItem p) => sum + p.progress,
    );
    return (total / _projects.length).round();
  }

  /// Count of active projects (`In Progress` or `Waiting Client`).
  int get activeCount {
    return _projects.where((ProjectItem p) => p.status.isActive).length;
  }

  ProjectItem _normalizeStatusProgress(ProjectItem project) {
    final int clampedProgress = project.progress.clamp(0, 100);
    final int effectiveProgress = project.status.forcesFullProgress
        ? 100
        : clampedProgress;
    if (effectiveProgress == project.progress) {
      return project;
    }
    return project.copyWith(progress: effectiveProgress);
  }

  String? _ownerClientForProjectId(String projectId) {
    final ProjectItem? live = byId(projectId);
    if (live != null) {
      return live.clientId;
    }
    return _projectClientHistory[projectId];
  }

  void _syncClient(String clientId) {
    final Client? client = clientsRepository.byId(clientId);
    if (client == null) {
      return;
    }

    final List<Project> syncedProjects = _projects
        .where((ProjectItem p) => p.clientId == clientId)
        .map(
          (ProjectItem p) => Project(
            id: p.id,
            name: p.name,
            status: p.status.label,
            price: p.price,
            progress: p.progress,
          ),
        )
        .toList();

    final List<ProjectPayment> clientProjectPayments = _payments
        .where(
          (ProjectPayment pay) =>
              _ownerClientForProjectId(pay.projectId) == clientId,
        )
        .toList();

    // Preserve any legacy client-only payments not tracked in _payments.
    final List<Payment> retainedLegacyPayments = client.payments.where((
      Payment existing,
    ) {
      if (existing.projectId != null) {
        return false;
      }
      final bool matchedInRepo = _payments.any(
        (ProjectPayment p) =>
            formatDate(p.date) == existing.date &&
            p.reference == existing.reference &&
            p.amount == existing.amount,
      );
      return !matchedInRepo;
    }).toList();

    final List<Payment> syncedPayments = <Payment>[
      ...retainedLegacyPayments,
      ...clientProjectPayments.map(
        (ProjectPayment pay) => Payment(
          id: pay.id,
          projectId: pay.projectId,
          date: formatDate(pay.date),
          reference: pay.reference,
          amount: pay.amount,
        ),
      ),
    ];

    final double updatedBudget = syncedProjects.fold<double>(
      0.0,
      (double sum, Project p) => sum + p.price,
    );

    clientsRepository.update(
      client.copyWith(
        projects: syncedProjects,
        payments: syncedPayments,
        budget: updatedBudget,
      ),
    );
  }

  static List<ProjectItem> _createInitialProjects() {
    return <ProjectItem>[
      ProjectItem(
        id: 'p1',
        name: 'Fintask Landing Page',
        description:
            'Responsive marketing landing page with pricing, onboarding form '
            'and payment integration for the Fintask launch.',
        category: 'Development',
        clientId: 'c1',
        price: 450000.0,
        status: ProjectStatus.inProgress,
        progress: 65,
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 8, 30),
        createdAt: DateTime(2026, 7, 1),
      ),
      ProjectItem(
        id: 'p2',
        name: 'Brand Identity',
        description:
            'Complete visual identity system including logo suite, colour '
            'palette, typography guidelines and social templates.',
        category: 'Design',
        clientId: 'c2',
        price: 180000.0,
        status: ProjectStatus.waitingClient,
        progress: 40,
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 30),
        createdAt: DateTime(2026, 6, 20),
      ),
      ProjectItem(
        id: 'p3',
        name: 'Mobile App UI',
        description:
            'iOS and Android UI kit, interactive flows and design handoff '
            'specs for the companion mobile app.',
        category: 'Design',
        clientId: 'c1',
        price: 320000.0,
        status: ProjectStatus.completed,
        progress: 100,
        startDate: DateTime(2026, 4, 15),
        endDate: DateTime(2026, 6, 12),
        createdAt: DateTime(2026, 6, 1),
      ),
      ProjectItem(
        id: 'p4',
        name: 'Logo Pack',
        description:
            'Monogram mark, horizontal lockup and export-ready vector assets '
            'for print and digital.',
        category: 'Branding',
        clientId: 'c3',
        price: 40000.0,
        status: ProjectStatus.delivered,
        progress: 100,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 20),
        createdAt: DateTime(2026, 5, 10),
      ),
      ProjectItem(
        id: 'p5',
        name: 'Dashboard Redesign',
        description:
            'Analytics overview, reporting widgets and token audit for the '
            'client analytics web dashboard.',
        category: 'Design',
        clientId: 'c2',
        price: 95000.0,
        status: ProjectStatus.planned,
        progress: 0,
        startDate: DateTime(2026, 9, 10),
        endDate: DateTime(2026, 10, 25),
        createdAt: DateTime(2026, 4, 15),
      ),
    ];
  }

  static List<ProjectTask> _createInitialTasks() {
    return <ProjectTask>[
      // Fintask Landing Page (exact 4 tasks from P6)
      ProjectTask(
        id: 't1',
        projectId: 'p1',
        name: 'Wireframes approved',
        due: DateTime(2026, 6, 28),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't2',
        projectId: 'p1',
        name: 'Hero + pricing',
        due: DateTime(2026, 7, 20),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't3',
        projectId: 'p1',
        name: 'Onboarding form',
        due: DateTime(2026, 8, 12),
        status: TaskStatus.inProgress,
      ),
      ProjectTask(
        id: 't4',
        projectId: 'p1',
        name: 'Payment integration',
        due: DateTime(2026, 8, 25),
        status: TaskStatus.nextUp,
      ),

      // Brand Identity
      ProjectTask(
        id: 't5',
        projectId: 'p2',
        name: 'Moodboard & discovery',
        due: DateTime(2026, 8, 10),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't6',
        projectId: 'p2',
        name: 'Primary logo concepts',
        due: DateTime(2026, 8, 28),
        status: TaskStatus.inProgress,
      ),
      ProjectTask(
        id: 't7',
        projectId: 'p2',
        name: 'Brand guidelines book',
        due: DateTime(2026, 9, 25),
        status: TaskStatus.nextUp,
      ),

      // Mobile App UI
      ProjectTask(
        id: 't8',
        projectId: 'p3',
        name: 'User flow mapping',
        due: DateTime(2026, 4, 25),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't9',
        projectId: 'p3',
        name: 'High-fidelity screens',
        due: DateTime(2026, 5, 22),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't10',
        projectId: 'p3',
        name: 'Component library handoff',
        due: DateTime(2026, 6, 10),
        status: TaskStatus.complete,
      ),

      // Logo Pack
      ProjectTask(
        id: 't11',
        projectId: 'p4',
        name: 'Vector lockups',
        due: DateTime(2026, 5, 12),
        status: TaskStatus.complete,
      ),
      ProjectTask(
        id: 't12',
        projectId: 'p4',
        name: 'Final asset bundle',
        due: DateTime(2026, 5, 20),
        status: TaskStatus.complete,
      ),

      // Dashboard Redesign
      ProjectTask(
        id: 't13',
        projectId: 'p5',
        name: 'Audit existing charts',
        due: DateTime(2026, 9, 18),
        status: TaskStatus.nextUp,
      ),
      ProjectTask(
        id: 't14',
        projectId: 'p5',
        name: 'Design widget grid',
        due: DateTime(2026, 10, 10),
        status: TaskStatus.nextUp,
      ),
    ];
  }

  static List<ProjectPayment> _createInitialPayments() {
    return <ProjectPayment>[
      // Fintask Landing Page — exact 3 payments from P7 (sum: 245,000 DZ)
      ProjectPayment(
        id: 'pay1',
        projectId: 'p1',
        date: DateTime(2026, 4, 2),
        reference: '#A102',
        amount: 100000.0,
      ),
      ProjectPayment(
        id: 'pay2',
        projectId: 'p1',
        date: DateTime(2026, 5, 18),
        reference: '#A117',
        amount: 85000.0,
      ),
      ProjectPayment(
        id: 'pay3',
        projectId: 'p1',
        date: DateTime(2026, 7, 9),
        reference: '#A131',
        amount: 60000.0,
      ),

      // Brand Identity (paid: 60,000 DZ)
      ProjectPayment(
        id: 'pay4',
        projectId: 'p2',
        date: DateTime(2026, 8, 5),
        reference: '#A135',
        amount: 60000.0,
      ),

      // Mobile App UI (paid: 320,000 DZ)
      ProjectPayment(
        id: 'pay5',
        projectId: 'p3',
        date: DateTime(2026, 4, 20),
        reference: '#A105',
        amount: 160000.0,
      ),
      ProjectPayment(
        id: 'pay6',
        projectId: 'p3',
        date: DateTime(2026, 6, 12),
        reference: '#A122',
        amount: 160000.0,
      ),

      // Logo Pack (paid: 40,000 DZ)
      ProjectPayment(
        id: 'pay7',
        projectId: 'p4',
        date: DateTime(2026, 5, 20),
        reference: '#A118',
        amount: 40000.0,
      ),
    ];
  }
}
