# CampusEats (Frontend Flutter)

Application mobile Android de gestion de cantine scolaire et universitaire (Burkina Faso).

## Démarrage rapide (< 10 min)

### 1. Installer les dépendances

```bash
cd app
flutter pub get
```

### 2. Lancer en mode mock (sans backend)

```bash
flutter run --dart-define=USE_MOCKS=true
```

### 3. Lancer avec l'API déployée

```bash
flutter run --dart-define=API_BASE_URL=https://api.campuseats.bf
```

### 4. Compiler l'APK release

Configurer `android/key.properties` (non versionné) si vous signez en release, puis :

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.campuseats.bf
```

## Comptes de test (`USE_MOCKS=true`)

| Rôle | Matricule | Mot de passe | Statut |
|---|---|---|---|
| Étudiant boursier | `STU001` / `ETU-2024-001` | `password123` | Actif |
| Étudiant abonné | `STU002` / `ETU-2024-002` | `password123` | Actif (abonnement valide) |
| Étudiant non-boursier / sans abonnement | `STU003` | `password123` | Actif (accès guichet) |
| Étudiant en attente | `PEND01` / `ETU-2024-003` | `password123` | En attente de validation |
| Personnel cantine | `STAFF01` / `STF-2024-001` | `password123` | Actif (Scanner & Guichet) |
| Administrateur | `ADMIN01` / `ADM-2024-001` | `password123` | Actif (Gestion complète) |

## Vérifications qualité

```bash
flutter analyze
dart format --set-exit-if-changed .
flutter test
```
