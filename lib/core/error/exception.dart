class HealAppExceptions implements Exception {
  final String message;
  const HealAppExceptions(this.message);
}

class RemoteException extends HealAppExceptions {
  const RemoteException(super.message);
}

class LocalException extends HealAppExceptions {
  const LocalException(super.message);
}
