import '../models/models.dart';

enum PaymentProvider { zaad, edahab }

/// Mobile money USSD payment (e.g. *883*484594*50#).
class PaymentConfig {
  static const defaultZaadUssdServiceCode = '883';
  static const defaultZaadMerchantId = '484594';
  static const defaultEdahabUssdServiceCode = '789';
  static const defaultEdahabMerchantId = '764043';

  /// Kept for older call sites (ZAAD defaults).
  static const defaultUssdServiceCode = defaultZaadUssdServiceCode;
  static const defaultMerchantId = defaultZaadMerchantId;

  static String ussdCode({
    required double amount,
    required String merchantId,
    String ussdServiceCode = defaultZaadUssdServiceCode,
  }) {
    final amountStr = amount.round().toString();
    return '*$ussdServiceCode*$merchantId*$amountStr#';
  }

  /// `tel:` URI with `#` encoded for the dialer.
  static Uri ussdDialUri({
    required double amount,
    required String merchantId,
    String ussdServiceCode = defaultZaadUssdServiceCode,
  }) {
    final code = ussdCode(
      amount: amount,
      merchantId: merchantId,
      ussdServiceCode: ussdServiceCode,
    );
    return Uri.parse('tel:${code.replaceAll('#', '%23')}');
  }
}

extension GlobalSettingsPayment on GlobalSettings {
  String merchantIdFor(PaymentProvider provider) => switch (provider) {
        PaymentProvider.zaad => paymentMerchantId,
        PaymentProvider.edahab => edahabMerchantId,
      };

  String ussdServiceCodeFor(PaymentProvider provider) => switch (provider) {
        PaymentProvider.zaad => ussdServiceCode,
        PaymentProvider.edahab => edahabUssdServiceCode,
      };

  String ussdCodeFor(
    double amount, {
    PaymentProvider provider = PaymentProvider.zaad,
  }) =>
      PaymentConfig.ussdCode(
        amount: amount,
        merchantId: merchantIdFor(provider),
        ussdServiceCode: ussdServiceCodeFor(provider),
      );

  Uri ussdDialUriFor(
    double amount, {
    PaymentProvider provider = PaymentProvider.zaad,
  }) =>
      PaymentConfig.ussdDialUri(
        amount: amount,
        merchantId: merchantIdFor(provider),
        ussdServiceCode: ussdServiceCodeFor(provider),
      );
}
