import '../domain/models/reward_models.dart';
import 'reward_repository.dart';

/// In-memory ledger for the demo. Ledger is the source of truth.
class InMemoryRewardRepository implements RewardRepository {
  final List<RewardLedgerEntry> _entries = [];

  List<RewardLedgerEntry> get allEntries => List.unmodifiable(_entries);

  @override
  Future<void> addLedgerEntry(RewardLedgerEntry entry) async {
    // Hard guard: never allow a second earned entry for the same quotation.
    if (await hasEntryForQuotation(entry.quotationId)) {
      throw RewardException(
        'This quotation has already been marked as sold.',
      );
    }
    _entries.insert(0, entry);
  }

  @override
  Future<List<RewardLedgerEntry>> getLedgerEntriesForUser(
    String requesterId,
  ) async {
    final list =
        _entries.where((e) => e.requesterId == requesterId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<int> getBalanceForUser(String requesterId) async {
    var earned = 0;
    var redeemed = 0;
    for (final e in _entries) {
      if (e.requesterId != requesterId) continue;
      if (e.type == RewardLedgerType.earned) {
        earned += e.points;
      } else if (e.type == RewardLedgerType.redeemed) {
        redeemed += e.points;
      }
    }
    return earned - redeemed;
  }

  @override
  Future<bool> hasEntryForQuotation(String quotationId) async {
    return _entries.any((e) => e.quotationId == quotationId);
  }

  @override
  Future<RewardLedgerEntry?> entryForQuotation(String quotationId) async {
    for (final e in _entries) {
      if (e.quotationId == quotationId) return e;
    }
    return null;
  }

  void clear() => _entries.clear();
}
