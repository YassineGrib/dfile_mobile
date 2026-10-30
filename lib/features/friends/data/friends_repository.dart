import 'dart:async';

import 'package:flutter/foundation.dart';

import 'friend.dart';
import 'friend_transaction.dart';
import 'friend_tx_type.dart';
import 'friends_store.dart';

/// Pure filtering function for friends per `docs/design/SPEC.md` (FD1).
///
/// Matches [query] across name, phone, and notes.
/// Filters by [filter] using resolved [FriendBalance].
List<Friend> filterFriends(
  List<Friend> friends, {
  String? query,
  FriendNetFilter filter = FriendNetFilter.all,
  FriendBalance Function(String friendId)? balanceLookup,
  Map<String, FriendBalance>? balances,
}) {
  final String normalizedQuery = (query ?? '').trim().toLowerCase();

  return friends.where((Friend friend) {
    // 1. Text Search Filter
    if (normalizedQuery.isNotEmpty) {
      final bool matchesName = friend.name.toLowerCase().contains(
        normalizedQuery,
      );
      final bool matchesPhone = friend.phone.toLowerCase().contains(
        normalizedQuery,
      );
      final bool matchesNotes = friend.notes.toLowerCase().contains(
        normalizedQuery,
      );
      if (!matchesName && !matchesPhone && !matchesNotes) {
        return false;
      }
    }

    // 2. Net Filter
    if (filter != FriendNetFilter.all) {
      final FriendBalance? balance =
          balanceLookup?.call(friend.id) ??
          balances?[friend.id] ??
          friend.balance;
      final double net = balance?.net ?? 0.0;

      switch (filter) {
        case FriendNetFilter.all:
          break;
        case FriendNetFilter.owedToMe:
          if (net <= 0.0) return false;
          break;
        case FriendNetFilter.iOwe:
          if (net >= 0.0) return false;
          break;
        case FriendNetFilter.settled:
          if (net != 0.0) return false;
          break;
      }
    }

    return true;
  }).toList();
}

/// Pure filtering function for debt transactions per `docs/design/SPEC.md` (FD8, FD9).
///
/// Filters by:
/// - [query]: matches [tx.description] or friend's name via [nameOf]
/// - [directions]: matches [FriendTxDirection] or [FriendDirectionFilter]
/// - [status]: matches [FriendTxStatus] or [FriendStatusFilter]
/// - [type]: matches [FriendTxType] or [FriendTypeFilter]
List<FriendTransaction> filterTransactions(
  List<FriendTransaction> transactions, {
  String? query,
  dynamic directions,
  dynamic status,
  dynamic type,
  String Function(String friendId)? nameOf,
}) {
  final String normalizedQuery = (query ?? '').trim().toLowerCase();

  return transactions.where((FriendTransaction tx) {
    // 1. Text Search Filter
    if (normalizedQuery.isNotEmpty) {
      final bool matchesDesc = tx.description.toLowerCase().contains(
        normalizedQuery,
      );
      final String friendName = nameOf?.call(tx.friendId) ?? '';
      final bool matchesFriend = friendName.toLowerCase().contains(
        normalizedQuery,
      );
      if (!matchesDesc && !matchesFriend) {
        return false;
      }
    }

    // 2. Direction Filter
    if (directions != null) {
      if (directions is FriendTxDirection) {
        if (tx.direction != directions) return false;
      } else if (directions is FriendDirectionFilter) {
        switch (directions) {
          case FriendDirectionFilter.all:
            break;
          case FriendDirectionFilter.owedToMe:
            if (tx.direction != FriendTxDirection.lent) return false;
            break;
          case FriendDirectionFilter.iOwe:
            if (tx.direction != FriendTxDirection.borrowed) return false;
            break;
        }
      } else if (directions is Iterable<FriendTxDirection>) {
        if (!directions.contains(tx.direction)) return false;
      }
    }

    // 3. Status Filter
    if (status != null) {
      if (status is FriendTxStatus) {
        if (tx.status != status) return false;
      } else if (status is FriendStatusFilter) {
        switch (status) {
          case FriendStatusFilter.all:
            break;
          case FriendStatusFilter.pending:
            if (tx.status != FriendTxStatus.pending) return false;
            break;
          case FriendStatusFilter.partial:
            if (tx.status != FriendTxStatus.partial) return false;
            break;
          case FriendStatusFilter.settled:
            if (tx.status != FriendTxStatus.settled) return false;
            break;
        }
      } else if (status is Iterable<FriendTxStatus>) {
        if (!status.contains(tx.status)) return false;
      }
    }

    // 4. Type/Nature Filter
    if (type != null) {
      if (type is FriendTxType) {
        if (tx.type != type) return false;
      } else if (type is FriendTypeFilter) {
        switch (type) {
          case FriendTypeFilter.all:
            break;
          case FriendTypeFilter.money:
            if (tx.type != FriendTxType.money) return false;
            break;
          case FriendTypeFilter.service:
            if (tx.type != FriendTxType.service) return false;
            break;
          case FriendTypeFilter.expense:
            if (tx.type != FriendTxType.expense) return false;
            break;
        }
      } else if (type is Iterable<FriendTxType>) {
        if (!type.contains(tx.type)) return false;
      }
    }

    return true;
  }).toList();
}

/// In-memory repository managing friends, debt transactions, and settlements
/// per `docs/design/SPEC.md`.
class FriendsRepository extends ChangeNotifier {
  FriendsRepository({
    List<Friend>? initialFriends,
    List<FriendTransaction>? initialTransactions,
    List<FriendSettlement>? initialSettlements,
  }) : _friends = List<Friend>.of(initialFriends ?? _createInitialFriends()),
       _transactions = List<FriendTransaction>.of(
         initialTransactions ?? _createInitialTransactions(),
       ),
       _settlements = List<FriendSettlement>.of(
         initialSettlements ?? _createInitialSettlements(),
       );

  final List<Friend> _friends;
  final List<FriendTransaction> _transactions;
  final List<FriendSettlement> _settlements;
  FriendsStore? _store;
  StreamSubscription<List<Friend>>? _friendsSub;
  StreamSubscription<List<FriendTransaction>>? _transactionsSub;
  StreamSubscription<List<FriendSettlement>>? _settlementsSub;
  bool _friendsLoaded = false;
  bool _transactionsLoaded = false;
  bool _settlementsLoaded = false;
  Object? _syncError;

  /// True until the first snapshots of an attached store arrive.
  bool get isLoading =>
      _store != null &&
      !(_friendsLoaded && _transactionsLoaded && _settlementsLoaded);

  /// Last store error (read or write), if any.
  Object? get syncError => _syncError;

  bool get isAttached => _store != null;

  /// Switches to [store] as the source of truth: demo data is dropped and the
  /// lists follow the snapshots.
  void attachStore(FriendsStore store) {
    _detach();
    _store = store;
    _friends.clear();
    _transactions.clear();
    _settlements.clear();
    _syncError = null;
    notifyListeners();
    _friendsSub = store.watchFriends().listen((List<Friend> remote) {
      _friends
        ..clear()
        ..addAll(remote);
      _friendsLoaded = true;
      notifyListeners();
    }, onError: _onStoreError);
    _transactionsSub = store.watchTransactions().listen((
      List<FriendTransaction> remote,
    ) {
      _transactions
        ..clear()
        ..addAll(remote);
      _transactionsLoaded = true;
      notifyListeners();
    }, onError: _onStoreError);
    _settlementsSub = store.watchSettlements().listen((
      List<FriendSettlement> remote,
    ) {
      _settlements
        ..clear()
        ..addAll(remote);
      _settlementsLoaded = true;
      notifyListeners();
    }, onError: _onStoreError);
  }

  /// Stops following the store and empties the lists (sign-out).
  void detachStore() {
    _detach();
    _friends.clear();
    _transactions.clear();
    _settlements.clear();
    notifyListeners();
  }

  void _detach() {
    _friendsSub?.cancel();
    _transactionsSub?.cancel();
    _settlementsSub?.cancel();
    _friendsSub = null;
    _transactionsSub = null;
    _settlementsSub = null;
    _store = null;
    _friendsLoaded = false;
    _transactionsLoaded = false;
    _settlementsLoaded = false;
  }

  void _onStoreError(Object error) {
    _syncError = error;
    _friendsLoaded = true;
    _transactionsLoaded = true;
    _settlementsLoaded = true;
    notifyListeners();
  }

  void _write(Future<void> Function(FriendsStore store) op) {
    final FriendsStore? store = _store;
    if (store == null) return;
    op(store).catchError((Object error) {
      _syncError = error;
      notifyListeners();
    });
  }

  /// Deletes this user's friends data from the store (before the account goes).
  Future<void> deleteRemoteData() async => _store?.deleteAll();

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  /// Unmodifiable view of all registered friends with attached balance statistics.
  List<Friend> get friends => List<Friend>.unmodifiable(
    _friends.map((Friend f) => f.copyWith(balance: friendBalance(f.id))),
  );

  /// Unmodifiable view of raw registered friends without computed balance metadata.
  List<Friend> get rawFriends => List<Friend>.unmodifiable(_friends);

  /// Unmodifiable view of all recorded transactions.
  List<FriendTransaction> get transactions =>
      List<FriendTransaction>.unmodifiable(_transactions);

  /// Unmodifiable view of all recorded settlements.
  List<FriendSettlement> get settlements =>
      List<FriendSettlement>.unmodifiable(_settlements);

  /// Finds a friend by [id], returning `null` if not found.
  Friend? friendById(String id) {
    for (final Friend friend in _friends) {
      if (friend.id == id) {
        return friend.copyWith(balance: friendBalance(id));
      }
    }
    return null;
  }

  /// Finds a transaction by [id], returning `null` if not found.
  FriendTransaction? transactionById(String id) {
    for (final FriendTransaction tx in _transactions) {
      if (tx.id == id) {
        return tx;
      }
    }
    return null;
  }

  /// Appends [friend] and notifies listeners.
  void addFriend(Friend friend) {
    _friends.add(friend);
    notifyListeners();
    _write((FriendsStore s) => s.saveFriend(friend));
  }

  /// Updates an existing friend record matching [friend.id] and notifies listeners.
  bool updateFriend(Friend friend) {
    final int index = _friends.indexWhere((Friend f) => f.id == friend.id);
    if (index != -1) {
      _friends[index] = friend;
      notifyListeners();
      _write((FriendsStore s) => s.saveFriend(friend));
      return true;
    }
    return false;
  }

  /// Deletes [friendId] and cascades deletion to all associated transactions
  /// and settlements, then notifies listeners.
  bool deleteFriend(String friendId) {
    final int index = _friends.indexWhere((Friend f) => f.id == friendId);
    if (index == -1) return false;

    _friends.removeAt(index);

    // Cascade delete transactions and settlements
    final List<String> txIdsToRemove = _transactions
        .where((FriendTransaction tx) => tx.friendId == friendId)
        .map((FriendTransaction tx) => tx.id)
        .toList();

    _transactions.removeWhere(
      (FriendTransaction tx) => tx.friendId == friendId,
    );
    final List<String> settlementIdsToRemove = _settlements
        .where(
          (FriendSettlement s) =>
              s.friendId == friendId || txIdsToRemove.contains(s.transactionId),
        )
        .map((FriendSettlement s) => s.id)
        .toList();
    _settlements.removeWhere(
      (FriendSettlement s) =>
          s.friendId == friendId || txIdsToRemove.contains(s.transactionId),
    );

    notifyListeners();
    _write((FriendsStore st) async {
      await st.deleteFriend(friendId);
      for (final String id in txIdsToRemove) {
        await st.deleteTransaction(id);
      }
      for (final String id in settlementIdsToRemove) {
        await st.deleteSettlement(id);
      }
    });
    return true;
  }

  /// Appends [transaction] and notifies listeners.
  void addTransaction(FriendTransaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
    _write((FriendsStore s) => s.saveTransaction(transaction));
  }

  /// Updates an existing transaction matching [transaction.id] and notifies listeners.
  bool updateTransaction(FriendTransaction transaction) {
    final int index = _transactions.indexWhere(
      (FriendTransaction t) => t.id == transaction.id,
    );
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
      _write((FriendsStore s) => s.saveTransaction(transaction));
      return true;
    }
    return false;
  }

  /// Deletes [transactionId] and cascades deletion to all associated settlements,
  /// then notifies listeners.
  bool deleteTransaction(String transactionId) {
    final int index = _transactions.indexWhere(
      (FriendTransaction t) => t.id == transactionId,
    );
    if (index == -1) return false;

    _transactions.removeAt(index);
    final List<String> removedSettlements = _settlements
        .where((FriendSettlement s) => s.transactionId == transactionId)
        .map((FriendSettlement s) => s.id)
        .toList();
    _settlements.removeWhere(
      (FriendSettlement s) => s.transactionId == transactionId,
    );

    notifyListeners();
    _write((FriendsStore st) async {
      await st.deleteTransaction(transactionId);
      for (final String id in removedSettlements) {
        await st.deleteSettlement(id);
      }
    });
    return true;
  }

  /// Records a settlement payment towards [transactionId].
  ///
  /// Validates:
  /// - [amount] > 0
  /// - [amount] <= transaction.remaining
  ///
  /// Throws [ArgumentError] if the transaction does not exist or if [amount] is invalid.
  FriendSettlement settle(
    String transactionId,
    double amount,
    FriendSettleMethod method, [
    String notes = '',
    DateTime? date,
  ]) {
    final int txIndex = _transactions.indexWhere(
      (FriendTransaction t) => t.id == transactionId,
    );
    if (txIndex == -1) {
      throw ArgumentError('Transaction not found: $transactionId');
    }

    final FriendTransaction tx = _transactions[txIndex];
    if (amount <= 0.0) {
      throw ArgumentError('Settlement amount must be greater than 0: $amount');
    }
    if (amount > tx.remaining) {
      throw ArgumentError(
        'Settlement amount ($amount) exceeds remaining debt (${tx.remaining})',
      );
    }

    final DateTime settlementDate = date ?? DateTime.now();
    final FriendSettlement settlement = FriendSettlement(
      id: 'set_${DateTime.now().millisecondsSinceEpoch}_${_settlements.length + 1}',
      transactionId: transactionId,
      friendId: tx.friendId,
      amount: amount,
      method: method,
      notes: notes,
      date: settlementDate,
      createdAt: DateTime.now(),
    );

    _settlements.add(settlement);
    final FriendTransaction updatedTx = tx.copyWith(
      paidAmount: tx.paidAmount + amount,
    );
    _transactions[txIndex] = updatedTx;

    notifyListeners();
    _write((FriendsStore st) async {
      await st.saveSettlement(settlement);
      await st.saveTransaction(updatedTx);
    });
    return settlement;
  }

  /// Returns unmodifiable list of settlements belonging to [transactionId].
  List<FriendSettlement> settlementsOf(String transactionId) {
    return List<FriendSettlement>.unmodifiable(
      _settlements.where(
        (FriendSettlement s) => s.transactionId == transactionId,
      ),
    );
  }

  /// Returns unmodifiable list of transactions belonging to [friendId].
  List<FriendTransaction> transactionsOf(String friendId) {
    return List<FriendTransaction>.unmodifiable(
      _transactions.where((FriendTransaction t) => t.friendId == friendId),
    );
  }

  /// Computes the derived balance for [friendId] per `docs/design/SPEC.md`.
  FriendBalance friendBalance(String friendId) {
    double owedToYou = 0.0;
    double youOwe = 0.0;
    int activeCount = 0;
    int settledCount = 0;
    DateTime? lastActivity;

    for (final FriendTransaction tx in _transactions) {
      if (tx.friendId != friendId) continue;

      if (tx.direction == FriendTxDirection.lent) {
        owedToYou += tx.remaining;
      } else {
        youOwe += tx.remaining;
      }

      if (tx.status == FriendTxStatus.settled) {
        settledCount++;
      } else {
        activeCount++;
      }

      if (lastActivity == null || tx.date.isAfter(lastActivity)) {
        lastActivity = tx.date;
      }
    }

    for (final FriendSettlement s in _settlements) {
      if (s.friendId != friendId) continue;
      if (lastActivity == null || s.date.isAfter(lastActivity)) {
        lastActivity = s.date;
      }
    }

    final double net = owedToYou - youOwe;

    return FriendBalance(
      net: net,
      owedToYou: owedToYou,
      youOwe: youOwe,
      active: activeCount,
      settled: settledCount,
      lastActivity: lastActivity,
    );
  }

  /// Computes the overall portfolio-wide balance per `docs/design/SPEC.md`:
  /// - `owedToYou`: sum of remaining on lent transactions across all friends
  /// - `youOwe`: sum of remaining on borrowed transactions across all friends
  /// - `net`: `owedToYou - youOwe`
  OverallBalance overallBalance() {
    double owedToYou = 0.0;
    double youOwe = 0.0;

    for (final FriendTransaction tx in _transactions) {
      if (tx.direction == FriendTxDirection.lent) {
        owedToYou += tx.remaining;
      } else {
        youOwe += tx.remaining;
      }
    }

    return OverallBalance(
      net: owedToYou - youOwe,
      owedToYou: owedToYou,
      youOwe: youOwe,
    );
  }

  // ---------------------------------------------------------------------------
  // Canonical SPEC.md Mock Data
  // ---------------------------------------------------------------------------

  static List<Friend> _createInitialFriends() {
    return <Friend>[
      Friend(
        id: 'fr1',
        name: 'Karim Boualam',
        phone: '+213 550 12 34 56',
        avatarColorIndex: 0,
        createdAt: DateTime(2026, 8, 1),
      ),
      Friend(
        id: 'fr2',
        name: 'Yacine Mebarki',
        phone: '+213 661 45 78 90',
        avatarColorIndex: 1,
        createdAt: DateTime(2026, 8, 5),
      ),
      Friend(
        id: 'fr3',
        name: 'Amine Saidi',
        phone: '+213 770 33 21 08',
        avatarColorIndex: 2,
        createdAt: DateTime(2026, 8, 10),
      ),
      Friend(
        id: 'fr4',
        name: 'Lina Cherif',
        phone: '+213 555 98 76 54',
        avatarColorIndex: 3,
        createdAt: DateTime(2026, 8, 12),
      ),
    ];
  }

  static List<FriendTransaction> _createInitialTransactions() {
    return <FriendTransaction>[
      FriendTransaction(
        id: 'tx1',
        friendId: 'fr1',
        type: FriendTxType.money,
        direction: FriendTxDirection.lent,
        amount: 50000.0,
        paidAmount: 20000.0,
        description: 'Cash via BaridiMob',
        date: DateTime(2026, 9, 2),
        dueDate: DateTime(2026, 11, 2),
      ),
      FriendTransaction(
        id: 'tx2',
        friendId: 'fr1',
        type: FriendTxType.service,
        direction: FriendTxDirection.lent,
        amount: 15000.0,
        paidAmount: 0.0,
        description: 'Frontend UI design',
        date: DateTime(2026, 10, 5),
        dueDate: null,
      ),
      FriendTransaction(
        id: 'tx3',
        friendId: 'fr3',
        type: FriendTxType.money,
        direction: FriendTxDirection.borrowed,
        amount: 12000.0,
        paidAmount: 0.0,
        description: 'Hosting bill split',
        date: DateTime(2026, 10, 10),
        dueDate: DateTime(2026, 11, 10),
      ),
      FriendTransaction(
        id: 'tx4',
        friendId: 'fr4',
        type: FriendTxType.money,
        direction: FriendTxDirection.lent,
        amount: 8000.0,
        paidAmount: 8000.0,
        description: 'Lunch and taxi',
        date: DateTime(2026, 8, 14),
        dueDate: null,
      ),
      FriendTransaction(
        id: 'tx5',
        friendId: 'fr2',
        type: FriendTxType.expense,
        direction: FriendTxDirection.lent,
        amount: 25000.0,
        paidAmount: 0.0,
        description: 'Server hosting bill',
        date: DateTime(2026, 10, 20),
        dueDate: DateTime(2026, 11, 20),
      ),
    ];
  }

  static List<FriendSettlement> _createInitialSettlements() {
    return <FriendSettlement>[
      FriendSettlement(
        id: 's1',
        transactionId: 'tx1',
        friendId: 'fr1',
        amount: 12000.0,
        method: FriendSettleMethod.baridimob,
        date: DateTime(2026, 9, 20),
      ),
      FriendSettlement(
        id: 's2',
        transactionId: 'tx1',
        friendId: 'fr1',
        amount: 8000.0,
        method: FriendSettleMethod.cash,
        date: DateTime(2026, 10, 1),
      ),
      FriendSettlement(
        id: 's3',
        transactionId: 'tx4',
        friendId: 'fr4',
        amount: 8000.0,
        method: FriendSettleMethod.cash,
        date: DateTime(2026, 8, 20),
      ),
    ];
  }

  /// Clears all friends, transactions, and settlements from the repository.
  void clearAll() {
    _friends.clear();
    _transactions.clear();
    _settlements.clear();
    notifyListeners();
  }
}
