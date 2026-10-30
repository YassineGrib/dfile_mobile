import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/store_utils.dart';
import '../../clients/data/clients_store.dart' show avatarColorFor;
import 'friend.dart';
import 'friend_transaction.dart';
import 'friend_tx_type.dart';

/// Persistence behind [FriendsRepository]: live lists plus write operations
/// for friends, their transactions and the settlements of those transactions.
abstract class FriendsStore {
  Stream<List<Friend>> watchFriends();

  Stream<List<FriendTransaction>> watchTransactions();

  Stream<List<FriendSettlement>> watchSettlements();

  Future<void> saveFriend(Friend friend);

  Future<void> deleteFriend(String id);

  Future<void> saveTransaction(FriendTransaction transaction);

  Future<void> deleteTransaction(String id);

  Future<void> saveSettlement(FriendSettlement settlement);

  Future<void> deleteSettlement(String id);

  /// Removes every friend, transaction and settlement (account deletion).
  Future<void> deleteAll();
}

Object _textOrDelete(String v) => v.isEmpty ? FieldValue.delete() : v;

/// Maps a friend to the web document shape (`users/{uid}/friends/{id}`).
Map<String, Object?> friendToMap(Friend f) => <String, Object?>{
  'id': f.id,
  'name': f.name,
  'phone': _textOrDelete(f.phone),
  'notes': _textOrDelete(f.notes),
  'created_at': f.createdAt.toIso8601String(),
};

Friend friendFromMap(String docId, Map<String, Object?> data) {
  final String id = textOf(data['id']).isEmpty ? docId : textOf(data['id']);
  return Friend(
    id: id,
    name: textOf(data['name']),
    phone: textOf(data['phone']),
    notes: textOf(data['notes']),
    createdAt: parseDate(data['created_at']) ?? DateTime.now(),
    avatarColorIndex: avatarColorFor(id),
  );
}

String _statusToWeb(FriendTxStatus s) => switch (s) {
  FriendTxStatus.pending => 'pending',
  FriendTxStatus.partial => 'partially_paid',
  FriendTxStatus.settled => 'settled',
};

/// Maps a transaction to the web shape (`users/{uid}/friend_transactions/{id}`).
Map<String, Object?> friendTransactionToMap(
  FriendTransaction t,
) => <String, Object?>{
  'id': t.id,
  'friend_id': t.friendId,
  'type': t.type.name,
  'direction': t.direction.name,
  'amount': t.amount,
  'paid_amount': t.paidAmount,
  'description': t.description,
  'due_date': t.dueDate == null ? FieldValue.delete() : dateOnly(t.dueDate!),
  'status': _statusToWeb(t.status),
  'date': dateOnly(t.date),
  'created_at': t.createdAt.toIso8601String(),
};

FriendTransaction friendTransactionFromMap(
  String docId,
  Map<String, Object?> data,
) {
  final String id = textOf(data['id']).isEmpty ? docId : textOf(data['id']);
  final DateTime created = parseDate(data['created_at']) ?? DateTime.now();
  return FriendTransaction(
    id: id,
    friendId: textOf(data['friend_id']),
    type: FriendTxType.tryParse(textOf(data['type'])) ?? FriendTxType.money,
    direction:
        FriendTxDirection.tryParse(textOf(data['direction'])) ??
        FriendTxDirection.lent,
    amount: numberOf(data['amount']),
    paidAmount: numberOf(data['paid_amount']),
    description: textOf(data['description']),
    dueDate: parseDate(data['due_date']),
    date: parseDate(data['date']) ?? created,
    createdAt: created,
  );
}

String settleMethodToWeb(FriendSettleMethod m) => switch (m) {
  FriendSettleMethod.baridimob => 'baridimob',
  FriendSettleMethod.cash => 'cash',
  FriendSettleMethod.bank => 'bank_transfer',
  FriendSettleMethod.serviceOffset => 'service_offset',
};

FriendSettleMethod settleMethodFromWeb(Object? v) => switch (v) {
  'baridimob' => FriendSettleMethod.baridimob,
  'bank_transfer' => FriendSettleMethod.bank,
  'service_offset' => FriendSettleMethod.serviceOffset,
  _ => FriendSettleMethod.cash,
};

/// Maps a settlement to the web shape (`users/{uid}/friend_settlements/{id}`).
Map<String, Object?> friendSettlementToMap(FriendSettlement s) =>
    <String, Object?>{
      'id': s.id,
      'transaction_id': s.transactionId,
      'friend_id': s.friendId,
      'amount': s.amount,
      'payment_method': settleMethodToWeb(s.method),
      'notes': _textOrDelete(s.notes),
      'date': dateOnly(s.date),
      'created_at': s.createdAt.toIso8601String(),
    };

FriendSettlement friendSettlementFromMap(
  String docId,
  Map<String, Object?> data,
) {
  final String id = textOf(data['id']).isEmpty ? docId : textOf(data['id']);
  final DateTime created = parseDate(data['created_at']) ?? DateTime.now();
  return FriendSettlement(
    id: id,
    transactionId: textOf(data['transaction_id']),
    friendId: textOf(data['friend_id']),
    amount: numberOf(data['amount']),
    method: settleMethodFromWeb(data['payment_method']),
    notes: textOf(data['notes']),
    date: parseDate(data['date']) ?? created,
    createdAt: created,
  );
}

/// Firestore-backed store for one signed-in user. Writes merge, so fields only
/// the web app knows are never wiped.
class FirestoreFriendsStore implements FriendsStore {
  FirestoreFriendsStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(uid).collection(name);

  Stream<List<T>> _watch<T>(
    String name,
    T Function(String id, Map<String, Object?> data) parse,
  ) => _col(name).snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              parse(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  Future<void> _save(String name, String id, Map<String, Object?> data) =>
      _col(name).doc(id).set(data, SetOptions(merge: true));

  @override
  Stream<List<Friend>> watchFriends() => _watch('friends', friendFromMap);

  @override
  Stream<List<FriendTransaction>> watchTransactions() =>
      _watch('friend_transactions', friendTransactionFromMap);

  @override
  Stream<List<FriendSettlement>> watchSettlements() =>
      _watch('friend_settlements', friendSettlementFromMap);

  @override
  Future<void> saveFriend(Friend friend) =>
      _save('friends', friend.id, friendToMap(friend));

  @override
  Future<void> deleteFriend(String id) => _col('friends').doc(id).delete();

  @override
  Future<void> saveTransaction(FriendTransaction t) =>
      _save('friend_transactions', t.id, friendTransactionToMap(t));

  @override
  Future<void> deleteTransaction(String id) =>
      _col('friend_transactions').doc(id).delete();

  @override
  Future<void> saveSettlement(FriendSettlement s) =>
      _save('friend_settlements', s.id, friendSettlementToMap(s));

  @override
  Future<void> deleteSettlement(String id) =>
      _col('friend_settlements').doc(id).delete();

  @override
  Future<void> deleteAll() async {
    for (final String name in <String>[
      'friends',
      'friend_transactions',
      'friend_settlements',
    ]) {
      final QuerySnapshot<Map<String, dynamic>> snap = await _col(name).get();
      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}

/// In-memory store for tests.
class FakeFriendsStore implements FriendsStore {
  FakeFriendsStore({
    List<Friend> friends = const <Friend>[],
    List<FriendTransaction> transactions = const <FriendTransaction>[],
    List<FriendSettlement> settlements = const <FriendSettlement>[],
  }) : _friends = List<Friend>.of(friends),
       _transactions = List<FriendTransaction>.of(transactions),
       _settlements = List<FriendSettlement>.of(settlements);

  final List<Friend> _friends;
  final List<FriendTransaction> _transactions;
  final List<FriendSettlement> _settlements;
  final StreamController<List<Friend>> _fc =
      StreamController<List<Friend>>.broadcast();
  final StreamController<List<FriendTransaction>> _tc =
      StreamController<List<FriendTransaction>>.broadcast();
  final StreamController<List<FriendSettlement>> _sc =
      StreamController<List<FriendSettlement>>.broadcast();
  final List<String> log = <String>[];

  @override
  Stream<List<Friend>> watchFriends() async* {
    yield List<Friend>.of(_friends);
    yield* _fc.stream;
  }

  @override
  Stream<List<FriendTransaction>> watchTransactions() async* {
    yield List<FriendTransaction>.of(_transactions);
    yield* _tc.stream;
  }

  @override
  Stream<List<FriendSettlement>> watchSettlements() async* {
    yield List<FriendSettlement>.of(_settlements);
    yield* _sc.stream;
  }

  static void _upsert<T>(List<T> list, T item, bool Function(T) same) {
    final int i = list.indexWhere(same);
    if (i == -1) {
      list.add(item);
    } else {
      list[i] = item;
    }
  }

  @override
  Future<void> saveFriend(Friend friend) async {
    log.add('saveFriend:${friend.id}');
    _upsert(_friends, friend, (Friend f) => f.id == friend.id);
    _fc.add(List<Friend>.of(_friends));
  }

  @override
  Future<void> deleteFriend(String id) async {
    log.add('deleteFriend:$id');
    _friends.removeWhere((Friend f) => f.id == id);
    _fc.add(List<Friend>.of(_friends));
  }

  @override
  Future<void> saveTransaction(FriendTransaction t) async {
    log.add('saveTransaction:${t.id}');
    _upsert(_transactions, t, (FriendTransaction x) => x.id == t.id);
    _tc.add(List<FriendTransaction>.of(_transactions));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    log.add('deleteTransaction:$id');
    _transactions.removeWhere((FriendTransaction t) => t.id == id);
    _tc.add(List<FriendTransaction>.of(_transactions));
  }

  @override
  Future<void> saveSettlement(FriendSettlement s) async {
    log.add('saveSettlement:${s.id}');
    _upsert(_settlements, s, (FriendSettlement x) => x.id == s.id);
    _sc.add(List<FriendSettlement>.of(_settlements));
  }

  @override
  Future<void> deleteSettlement(String id) async {
    log.add('deleteSettlement:$id');
    _settlements.removeWhere((FriendSettlement s) => s.id == id);
    _sc.add(List<FriendSettlement>.of(_settlements));
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _friends.clear();
    _transactions.clear();
    _settlements.clear();
    _fc.add(const <Friend>[]);
    _tc.add(const <FriendTransaction>[]);
    _sc.add(const <FriendSettlement>[]);
  }
}
