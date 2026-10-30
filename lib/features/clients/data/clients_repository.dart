import 'dart:async';

import 'package:flutter/foundation.dart';

import 'client.dart';
import 'clients_store.dart';

/// In-memory repository managing clients, projects, payments, and derived statistics.
class ClientsRepository extends ChangeNotifier {
  ClientsRepository({List<Client>? initialClients})
    : _clients = initialClients ?? _createInitialClients();

  final List<Client> _clients;
  ClientsStore? _store;
  StreamSubscription<List<Client>>? _subscription;
  bool _loading = false;
  Object? _syncError;

  /// True until the first snapshot of an attached store arrives.
  bool get isLoading => _loading;

  /// Last store error (read or write), if any.
  Object? get syncError => _syncError;

  bool get isAttached => _store != null;

  /// Switches to [store] as the source of truth: the demo data is dropped and
  /// the list follows the snapshots of the store. Local projects and payments
  /// of a client are kept until those modules sync too.
  void attachStore(ClientsStore store) {
    _subscription?.cancel();
    _store = store;
    _clients.clear();
    _loading = true;
    _syncError = null;
    notifyListeners();
    _subscription = store.watch().listen(
      (List<Client> remote) {
        final Map<String, Client> local = <String, Client>{
          for (final Client c in _clients) c.id: c,
        };
        _clients
          ..clear()
          ..addAll(
            remote.map((Client c) {
              final Client? old = local[c.id];
              return old == null
                  ? c
                  : c.copyWith(
                      projects: old.projects,
                      payments: old.payments,
                      budget: old.budget,
                      mockExpenses: old.mockExpenses,
                    );
            }),
          );
        _loading = false;
        _syncError = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _syncError = error;
        notifyListeners();
      },
    );
  }

  /// Stops following the store and empties the list (sign-out).
  void detachStore() {
    _subscription?.cancel();
    _subscription = null;
    _store = null;
    _loading = false;
    _syncError = null;
    _clients.clear();
    notifyListeners();
  }

  /// Deletes this user's clients from the store (before the account goes).
  Future<void> deleteRemoteData() async => _store?.deleteAll();

  void _write(Future<void> Function(ClientsStore store) op) {
    final ClientsStore? store = _store;
    if (store == null) return;
    op(store).catchError((Object error) {
      _syncError = error;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<Client> get clients => List<Client>.unmodifiable(_clients);

  /// Finds a client by [id], returning `null` if not found.
  Client? byId(String id) {
    try {
      return _clients.firstWhere((Client client) => client.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Adds a new client to the repository.
  void add(Client client) {
    _clients.add(client);
    notifyListeners();
    _write((ClientsStore s) => s.save(client));
  }

  /// Updates an existing client in the repository.
  void update(Client client) {
    final int index = _clients.indexWhere((Client c) => c.id == client.id);
    if (index != -1) {
      _clients[index] = client;
      notifyListeners();
      _write((ClientsStore s) => s.save(client));
    }
  }

  /// Removes a client by [id] from the repository.
  void delete(String id) {
    final int index = _clients.indexWhere((Client c) => c.id == id);
    if (index != -1) {
      _clients.removeAt(index);
      notifyListeners();
      _write((ClientsStore s) => s.delete(id));
    }
  }

  /// Total revenue: sum of all payments received for the client.
  double totalRevenue(Client client) {
    return client.payments.fold<double>(
      0.0,
      (double sum, Payment payment) => sum + payment.amount,
    );
  }

  /// Number of active projects (status: 'In Progress' or 'Waiting Client').
  int activeProjectsCount(Client client) {
    return client.projects.where((Project p) => p.isActive).length;
  }

  /// True if the client has at least one active project.
  bool isActive(Client client) {
    return activeProjectsCount(client) > 0;
  }

  /// Total contract budget.
  double budget(Client client) {
    if (client.budget != null) {
      return client.budget!;
    }
    if (client.projects.isEmpty) {
      return 0.0;
    }
    return client.projects.fold<double>(
      0.0,
      (double sum, Project project) => sum + project.price,
    );
  }

  /// Outstanding balance = budget - cleared payments.
  double outstanding(Client client) {
    return budget(client) - totalRevenue(client);
  }

  /// Net client profit = cleared revenue minus mock expense total.
  double netProfit(Client client) {
    final double cleared = totalRevenue(client);
    final double expense =
        client.mockExpenses ?? (cleared * 0.19183673469387755);
    return cleared - expense;
  }

  static List<Client> _createInitialClients() {
    return <Client>[
      Client(
        id: 'c1',
        name: 'Mohamed Bachir',
        email: 'bachir@novacorp.dz',
        phone: '0550 12 34 56',
        address: 'Algiers, Algeria',
        notes: 'Net 15 payment terms.',
        linkedin: '/in/bachir',
        twitter: '',
        github: '/bachir-dev',
        website: 'novacorp.dz',
        createdAt: DateTime(2026, 3, 14),
        avatarColorIndex: 0, // orange
        budget: 450000.0,
        mockExpenses: 47000.0,
        projects: const <Project>[
          Project(
            name: 'Fintask Landing Page',
            status: 'In Progress',
            price: 450000.0,
            progress: 65,
          ),
          Project(
            name: 'Brand Identity',
            status: 'Waiting Client',
            price: 180000.0,
            progress: 40,
          ),
          Project(
            name: 'Mobile App UI',
            status: 'Completed',
            price: 320000.0,
            progress: 100,
          ),
        ],
        payments: const <Payment>[
          Payment(date: '2026-04-02', reference: '#A102', amount: 100000.0),
          Payment(date: '2026-05-18', reference: '#A117', amount: 85000.0),
          Payment(date: '2026-07-09', reference: '#A131', amount: 60000.0),
        ],
      ),
      Client(
        id: 'c2',
        name: 'Sarah Benali',
        email: 'sarah@benali.design',
        phone: '0661 23 45 67',
        address: 'Oran, Algeria',
        notes: '',
        linkedin: '/in/sarahb',
        twitter: '@sarahb',
        github: '',
        website: '',
        createdAt: DateTime(2026, 5, 2),
        avatarColorIndex: 1, // purple
        budget: 120000.0,
        mockExpenses: 20000.0,
        projects: const <Project>[
          Project(
            name: 'Mobile App Redesign',
            status: 'In Progress',
            price: 120000.0,
            progress: 50,
          ),
        ],
        payments: const <Payment>[
          Payment(date: '2026-05-10', reference: '#A110', amount: 120000.0),
        ],
      ),
      Client(
        id: 'c3',
        name: 'Nova Studio',
        email: 'contact@novastudio.dz',
        phone: '0555 98 76 54',
        address: 'Constantine, Algeria',
        notes: 'Archived studio client.',
        linkedin: '',
        twitter: '',
        github: '',
        website: '',
        createdAt: DateTime(2026, 6, 20),
        avatarColorIndex: 2, // yellow
        budget: 0.0,
        mockExpenses: 0.0,
        projects: const <Project>[],
        payments: const <Payment>[],
      ),
      Client(
        id: 'c4',
        name: 'Karim Haddad',
        email: 'karim@haddad.dev',
        phone: '0770 11 22 33',
        address: 'Annaba, Algeria',
        notes: '',
        linkedin: '',
        twitter: '',
        github: 'karimh',
        website: '',
        createdAt: DateTime(2026, 8, 11),
        avatarColorIndex: 3, // coral
        budget: 68500.0,
        mockExpenses: 12000.0,
        projects: const <Project>[
          Project(
            name: 'API Integration',
            status: 'Completed',
            price: 68500.0,
            progress: 100,
          ),
        ],
        payments: const <Payment>[
          Payment(date: '2026-08-15', reference: '#A142', amount: 68500.0),
        ],
      ),
    ];
  }

  /// Clears all clients from the repository and notifies listeners.
  void clearAll() {
    _clients.clear();
    notifyListeners();
  }
}
