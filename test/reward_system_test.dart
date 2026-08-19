import 'package:customerapp/features/catalog/domain/models/catalog_models.dart';
import 'package:customerapp/features/rewards/data/in_memory_reward_repository.dart';
import 'package:customerapp/features/rewards/domain/reward_calculator.dart';
import 'package:customerapp/features/rewards/domain/reward_service.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/features/rewards/domain/models/reward_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RewardCalculator', () {
    test('floor(grandTotal / 100)', () {
      expect(RewardCalculator.pointsFromGrandTotal(100), 1);
      expect(RewardCalculator.pointsFromGrandTotal(500), 5);
      expect(RewardCalculator.pointsFromGrandTotal(10000), 100);
      expect(RewardCalculator.pointsFromGrandTotal(143000), 1430);
      expect(RewardCalculator.pointsFromGrandTotal(99), 0);
      expect(RewardCalculator.pointsFromGrandTotal(0), 0);
    });
  });

  group('RewardService markQuotationAsSold', () {
    late QuotationController quotations;
    late InMemoryRewardRepository repository;
    late RewardService service;

    setUp(() {
      quotations = QuotationController();
      repository = InMemoryRewardRepository();
      service = RewardService(
        quotationController: quotations,
        rewardRepository: repository,
      );
    });

    test('pending quotation earns no ledger until sold', () async {
      final q = quotations.byId('qt-demo-143000')!;
      expect(q.isPending, isTrue);
      expect(await repository.getLedgerEntriesForUser(q.requesterId), isEmpty);
    });

    test('mark sold credits floor(total/100) once', () async {
      final result = await service.markQuotationAsSold('qt-demo-143000');
      expect(result.pointsCredited, 1430);
      expect(result.quotation.isSold, isTrue);
      expect(result.quotation.soldAt, isNotNull);

      final entries =
          await repository.getLedgerEntriesForUser(AppUserProfile.demo.id);
      expect(entries.length, 1);
      expect(entries.first.points, 1430);

      final balance =
          await repository.getBalanceForUser(AppUserProfile.demo.id);
      expect(balance, 1430);
    });

    test('duplicate mark sold is rejected', () async {
      await service.markQuotationAsSold('qt-demo-143000');
      await expectLater(
        service.markQuotationAsSold('qt-demo-143000'),
        throwsA(isA<RewardException>()),
      );
      final entries =
          await repository.getLedgerEntriesForUser(AppUserProfile.demo.id);
      expect(entries.length, 1);
    });

    test('second quotation adds points without affecting other users', () async {
      await service.markQuotationAsSold('qt-demo-143000');
      await service.markQuotationAsSold('qt-demo-50000');

      final rajesh =
          await repository.getBalanceForUser(AppUserProfile.demo.id);
      expect(rajesh, 1930);

      final amit = await repository.getBalanceForUser('user-amit');
      expect(amit, 0);

      await service.markQuotationAsSold('qt-demo-25000');
      expect(await repository.getBalanceForUser('user-amit'), 250);
      expect(await repository.getBalanceForUser(AppUserProfile.demo.id), 1930);
    });

    test('missing quotation throws', () async {
      await expectLater(
        service.markQuotationAsSold('missing'),
        throwsA(
          isA<RewardException>().having(
            (e) => e.message,
            'message',
            'Quotation not found.',
          ),
        ),
      );
    });
  });
}
