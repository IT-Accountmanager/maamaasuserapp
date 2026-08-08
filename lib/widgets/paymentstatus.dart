enum PaymentStatus {
  created,
  authenticated,
  authorized,
  captured,
  failed,
  refunded,
  unknown,
}

enum PaymentOverlayState {
  none,
  placingOrder,
  openingGateway,
  processing,
  success,
}


PaymentStatus _parsePaymentStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'created':
      return PaymentStatus.created;

    case 'authenticated':
      return PaymentStatus.authenticated;

    case 'authorized':
      return PaymentStatus.authorized;

    case 'captured':
      return PaymentStatus.captured;

    case 'failed':
      return PaymentStatus.failed;

    case 'refunded':
      return PaymentStatus.refunded;

    default:
      return PaymentStatus.unknown;
  }
}