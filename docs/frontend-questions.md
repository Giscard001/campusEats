# Questions pour l'équipe API / Backend (CampusEats)

Ce document répertorie les points d'alignement entre le frontend Flutter et les endpoints backend de l'équipe API.

---

### 1. Clôture des commandes à 10h00
- **Règle métier** : Les commandes et annulations ferment strictement à 10h00 UTC+0 pour le repas du midi.
- **Header client** : Le client envoie `X-Client-Timestamp` sur chaque requête.
- **Question** : Si un étudiant initie une commande à 09h59m58s et que la requête arrive sur le serveur à 10h00m02s en raison de latence réseau mobile, le serveur applique-t-il une marge de grâce de 30 secondes ou un rejet strict HTTP 409 ?

### 2. Format de l'en-tête et codes de réponse
- **Vérification boursier (`POST /scholarships/check`)** :
  - Corps attendu : `{"matricule": "STU001", "lastName": "SAWADOGO"}`
  - Réponse confirmée : `{"found": true, "isScholarship": true}`
- **Code QR de retrait (`POST /orders/scan`)** :
  - Le scan valide retourne `{"status": "valid", "order": {...}}`.
  - En cas de double passage, le serveur renvoie `{"status": "already_served", "servedAt": "..."}` avec HTTP 200 (ou HTTP 409) ? Le frontend gère les deux formats.

### 3. Pagination et volumétrie
- Les endpoints `/orders`, `/users` et `/scholarships` utilisent la structure standard `PagedResult<T>` :
  `{"items": [...], "total": 120, "page": 1, "limit": 20, "totalPages": 6}`.
