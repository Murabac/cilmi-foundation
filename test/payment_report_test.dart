import 'package:flutter_test/flutter_test.dart';

import 'package:reer_sh_yoonis/models/models.dart';
import 'package:reer_sh_yoonis/models/payment_report.dart';

Profile _profile({
  required String id,
  Demographic demographic = Demographic.adult,
  String? fatherId,
}) =>
    Profile(
      id: id,
      fullName: id,
      role: UserRole.familyMember,
      demographic: demographic,
      careRating: 2,
      fatherId: fatherId,
    );

void main() {
  test('exempt row ignores contribution status', () {
    final row = MemberPaymentRow(
      profile: _profile(id: 'uncle'),
      paymentExempt: true,
      contribution: Contribution(
        id: 'c1',
        userId: 'uncle',
        billingMonth: 7,
        billingYear: 2026,
        amountDue: 50,
        amountPaid: 50,
        status: PaymentStatus.pending,
        transactionReference: 'ref',
      ),
    );

    expect(row.category, PaymentReportCategory.exempt);
    expect(row.matchesFilter(PaymentReportFilter.exempt), isTrue);
    expect(row.matchesFilter(PaymentReportFilter.unpaid), isFalse);
  });

  test('unpaid adult without contribution is not billed', () {
    final row = MemberPaymentRow(
      profile: _profile(id: 'adult'),
      paymentExempt: false,
    );

    expect(row.category, PaymentReportCategory.notBilled);
    expect(row.matchesFilter(PaymentReportFilter.unpaid), isTrue);
  });
}
