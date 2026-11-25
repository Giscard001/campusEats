abstract final class Validators {
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label est requis.';
    }
    return null;
  }

  static String? matricule(String? value) {
    final req = requiredField(value, 'Le matricule');
    if (req != null) return req;
    if (value!.trim().length < 4) {
      return 'Matricule invalide (4 caractères minimum).';
    }
    return null;
  }

  static String? password(String? value) {
    final req = requiredField(value, 'Le mot de passe');
    if (req != null) return req;
    if (value!.length < 8) {
      return 'Au moins 8 caractères requis.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = requiredField(value, 'La confirmation');
    if (req != null) return req;
    if (value != password) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
