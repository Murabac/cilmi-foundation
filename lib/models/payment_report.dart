import 'models.dart';

enum PaymentReportFilter { all, paid, pending, unpaid, exempt }

enum PaymentReportCategory {
  paid,
  pendingVerification,
  unpaid,
  rejected,
  exempt,
  notBilled,
}

class MemberPaymentRow {
  const MemberPaymentRow({
    required this.profile,
    this.contribution,
    this.paymentExempt = false,
  });

  final Profile profile;
  final Contribution? contribution;
  final bool paymentExempt;

  PaymentReportCategory get category {
    if (paymentExempt) {
      return PaymentReportCategory.exempt;
    }
    if (contribution == null) {
      return PaymentReportCategory.notBilled;
    }
    return switch (contribution!.status) {
      PaymentStatus.approved => PaymentReportCategory.paid,
      PaymentStatus.rejected => PaymentReportCategory.rejected,
      PaymentStatus.pending when contribution!.transactionReference != null =>
        PaymentReportCategory.pendingVerification,
      PaymentStatus.pending => PaymentReportCategory.unpaid,
    };
  }

  bool matchesFilter(PaymentReportFilter filter) {
    return switch (filter) {
      PaymentReportFilter.all => true,
      PaymentReportFilter.paid => category == PaymentReportCategory.paid,
      PaymentReportFilter.pending =>
        category == PaymentReportCategory.pendingVerification,
      PaymentReportFilter.unpaid =>
        category == PaymentReportCategory.unpaid ||
        category == PaymentReportCategory.notBilled ||
        category == PaymentReportCategory.rejected,
      PaymentReportFilter.exempt => category == PaymentReportCategory.exempt,
    };
  }
}

class MonthlyPaymentReport {
  const MonthlyPaymentReport({
    required this.month,
    required this.year,
    required this.rows,
    required this.adultRate,
  });

  final int month;
  final int year;
  final List<MemberPaymentRow> rows;
  final double adultRate;

  int count(PaymentReportCategory cat) =>
      rows.where((r) => r.category == cat).length;

  int get paidCount => count(PaymentReportCategory.paid);
  int get pendingCount => count(PaymentReportCategory.pendingVerification);
  int get unpaidCount =>
      count(PaymentReportCategory.unpaid) +
      count(PaymentReportCategory.notBilled) +
      count(PaymentReportCategory.rejected);
  int get exemptCount => count(PaymentReportCategory.exempt);

  double get collectedAmount => rows
      .where((r) => r.category == PaymentReportCategory.paid)
      .fold(0.0, (sum, r) => sum + (r.contribution?.amountPaid ?? 0));

  double get expectedAdultTotal =>
      rows.where((r) => !r.paymentExempt).length * adultRate;
}
