class AppLocalizations {
  final String locale;
  const AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'Helpi',
      'hello': 'Hello',
      'financial_assistant': 'FINANCIAL ASSISTANT',
      'verified_needs': 'Verified financial needs. Secure giving.',
      'emergency_sos': 'Emergency SOS',
      'currency_converter': 'Currency Converter',
      'impact_report': 'Impact Report',
      'offline_sync': 'Offline Sync & Queue',
      'dark_mode': 'Dark Mode',
      'sign_out': 'Sign out',
    },
    'sw': {
      'app_title': 'Helpi',
      'hello': 'Habari',
      'financial_assistant': 'MSAADA WA KIFEDHA',
      'verified_needs': 'Mahitaji yaliyothibitishwa. Utowaji salama.',
      'emergency_sos': 'Dharura ya SOS',
      'currency_converter': 'Kigeuza Sarafu',
      'impact_report': 'Ripoti ya Athari',
      'offline_sync': 'Usawazishaji Nje ya Mtandao',
      'dark_mode': 'Hali ya Giza',
      'sign_out': 'Odoka',
    },
    'fr': {
      'app_title': 'Helpi',
      'hello': 'Bonjour',
      'financial_assistant': 'ASSISTANT FINANCIER',
      'verified_needs': 'Besoins financiers vérifiés. Don sécurisé.',
      'emergency_sos': 'SOS Urgence',
      'currency_converter': 'Convertisseur de Devises',
      'impact_report': "Rapport d'Impact",
      'offline_sync': 'Synchronisation Hors Ligne',
      'dark_mode': 'Mode Sombre',
      'sign_out': 'Se déconnecter',
    },
  };

  String get(String key) {
    return _translations[locale]?[key] ?? _translations['en']?[key] ?? key;
  }
}
