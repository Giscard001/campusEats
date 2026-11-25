/// Horloge synchronisée avec le temps serveur (UTC+0, Burkina Faso).
/// Permet de calculer le compte à rebours avant clôture sans dépendre de l'horloge du téléphone.
class ServerClock {
  Duration _offset = Duration.zero;

  DateTime now() => DateTime.now().toUtc().add(_offset);

  void updateFromServerTime(DateTime serverTime) {
    final utcServer = serverTime.toUtc();
    _offset = utcServer.difference(DateTime.now().toUtc());
  }

  void updateFromIsoString(String? iso) {
    if (iso == null || iso.isEmpty) return;
    final parsed = DateTime.tryParse(iso);
    if (parsed != null) {
      updateFromServerTime(parsed);
    }
  }

  void reset() {
    _offset = Duration.zero;
  }
}
