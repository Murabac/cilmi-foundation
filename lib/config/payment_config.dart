import '../models/models.dart';

/// Mobile money USSD payment (e.g. *883*123456*50#).
class PaymentConfig {
  static const defaultUssdServiceCode = '883';
  static const defaultMerchantId = '123456';

  static String ussdCode({
    required double amount,
    required String merchantId,
    String ussdServiceCode = defaultUssdServiceCode,
  }) {
    final amountStr = amount.round().toString();
    return '*$ussdServiceCode*$merchantId*$amountStr#';
  }

  /// `tel:` URI with `#` encoded for the dialer.
  static Uri ussdDialUri({
    required double amount,
    required String merchantId,
    String ussdServiceCode = defaultUssdServiceCode,
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
  String ussdCodeFor(double amount) => PaymentConfig.ussdCode(
        amount: amount,
        merchantId: paymentMerchantId,
        ussdServiceCode: ussdServiceCode,
      );

  Uri ussdDialUriFor(double amount) => PaymentConfig.ussdDialUri(
        amount: amount,
        merchantId: paymentMerchantId,
        ussdServiceCode: ussdServiceCode,
      );
}
