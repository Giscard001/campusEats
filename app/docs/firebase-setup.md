# Configuration Firebase Push & Notifications (CampusEats)

Guide d'intégration des notifications push pour l'environnement de production.

---

## 1. Fichiers de configuration requis

1. **Android** :
   - Placer le fichier `google-services.json` généré depuis la console Firebase dans le dossier `app/android/app/`.
   - Le package Android est configuré sur `com.campuseats.app`.

2. **iOS (le cas échéant)** :
   - Placer `GoogleService-Info.plist` dans `app/ios/Runner/`.

## 2. Comportement du service Push (`PushService`)

- En l'absence de fichier Firebase valide ou en mode mock (`USE_MOCKS=true`), `PushService` bascule automatiquement sur un mode gracieux (fallback) sans planter l'application.
- Les notifications locales d'alerte (repas prêt, compte à rebours 10h00) sont présentées au premier plan via `flutter_local_notifications`.
