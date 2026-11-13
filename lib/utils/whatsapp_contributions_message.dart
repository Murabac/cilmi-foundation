import '../models/models.dart';
import '../models/payment_report.dart';
import 'somali_search.dart';

/// Builds the monthly contributions message for the family WhatsApp group,
/// in the same format the finance admin already posts:
///
///   *Qaadhaanka Bisha 11aad*
///   ZAAD = 484594 – EDAHAB = 764043
///   *AHMED CILMI GROUP*
///
///   1. Cismaan C/qaadir = $ 10 ✅
///   ...
///   22. Khalid C/rashiid = $ 5 ⏳
///
///   *TOTAL PAID = $ 175*
///
/// Every member on the payers list is included: ✅ paid, ⏳ not paid yet.
/// Paid members come first, in the order they paid.
String buildContributionsWhatsAppMessage({
  required MonthlyPaymentReport report,
  required GlobalSettings settings,
  required List<Profile> allProfiles,
}) {
  final byId = {for (final p in allProfiles) p.id: p};
  final payers = report.rows.where((r) => !r.paymentExempt).toList();

  final paid = payers
      .where((r) => r.category == PaymentReportCategory.paid)
      .toList()
    ..sort((a, b) {
      final at = a.contribution?.verifiedAt ?? a.contribution?.createdAt;
      final bt = b.contribution?.verifiedAt ?? b.contribution?.createdAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return at.compareTo(bt);
    });
  final waiting =
      payers.where((r) => r.category != PaymentReportCategory.paid).toList();

  String nameOf(Profile p) {
    final father = p.fatherId == null ? null : byId[p.fatherId!];
    return shortSomaliName(p.fullName, fatherFullName: father?.fullName);
  }

  final lines = <String>[];
  var n = 0;
  var total = 0.0;
  for (final r in paid) {
    n++;
    final amount = (r.contribution?.amountPaid ?? 0) > 0
        ? r.contribution!.amountPaid
        : (r.profile.monthlyAmount ?? r.contribution?.amountDue ?? 0);
    total += amount;
    lines.add('$n. ${nameOf(r.profile)} = \$ ${formatUsd(amount)} ✅');
  }
  for (final r in waiting) {
    n++;
    final amount = r.profile.monthlyAmount ?? r.contribution?.amountDue ?? 0;
    lines.add('$n. ${nameOf(r.profile)} = \$ ${formatUsd(amount)} ⏳');
  }

  return [
    '*Qaadhaanka Bisha ${report.month}aad*',
    'ZAAD = ${settings.paymentMerchantId} – EDAHAB = ${settings.edahabMerchantId}',
    '*${settings.whatsappGroupTitle}*',
    '',
    ...lines,
    '',
    '*TOTAL PAID = \$ ${formatUsd(total)}*',
  ].join('\n');
}

/// 10 -> "10", 7.5 -> "7.50".
String formatUsd(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
