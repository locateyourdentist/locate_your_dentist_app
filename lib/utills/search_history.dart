import 'package:locate_your_dentist/api/api.dart';

class SearchHistoryEntry {
  final String label;
  final String term;
  final String? state;
  final List<String> districts;
  final List<String> talukas;
  final List<String> villages;
  final double distanceKm;

  SearchHistoryEntry({
    required this.label,
    this.term = '',
    this.state,
    this.districts = const [],
    this.talukas = const [],
    this.villages = const [],
    this.distanceKm = 0,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'term': term,
    'state': state,
    'districts': districts,
    'talukas': talukas,
    'villages': villages,
    'distanceKm': distanceKm,
  };

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      label: json['label']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      state: json['state']?.toString(),
      districts: (json['districts'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      talukas: (json['talukas'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      villages: (json['villages'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SearchHistoryStore {
  static const int maxEntries = 8;

  static List<SearchHistoryEntry> getHistory(String storageKey) {
    final raw = Api.userInfo.read(storageKey);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => SearchHistoryEntry.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    return [];
  }

  static List<SearchHistoryEntry> addSearch(
    String storageKey, {
    String term = '',
    String? state,
    List<String> districts = const [],
    List<String> talukas = const [],
    List<String> villages = const [],
    double distanceKm = 0,
  }) {
    final trimmedTerm = term.trim();
    final bool hasAnyFilter =
        trimmedTerm.isNotEmpty ||
        (state != null && state.isNotEmpty) ||
        districts.isNotEmpty ||
        talukas.isNotEmpty ||
        villages.isNotEmpty ||
        distanceKm > 0;
    final history = getHistory(storageKey);
    if (!hasAnyFilter) return history;

    final label = _buildLabel(
      term: trimmedTerm,
      state: state,
      districts: districts,
      talukas: talukas,
      villages: villages,
      distanceKm: distanceKm,
    );

    final entry = SearchHistoryEntry(
      label: label,
      term: trimmedTerm,
      state: state,
      districts: districts,
      talukas: talukas,
      villages: villages,
      distanceKm: distanceKm,
    );

    history.removeWhere((e) => e.label.toLowerCase() == label.toLowerCase());
    history.insert(0, entry);
    final capped = history.take(maxEntries).toList();

    Api.userInfo.write(storageKey, capped.map((e) => e.toJson()).toList());
    return capped;
  }

  static String _buildLabel({
    required String term,
    String? state,
    List<String> districts = const [],
    List<String> talukas = const [],
    List<String> villages = const [],
    double distanceKm = 0,
  }) {
    final parts = <String>[];
    if (term.isNotEmpty) parts.add(term);

    if (villages.isNotEmpty) {
      parts.add(
        villages.length == 1
            ? villages.first
            : "${villages.first} +${villages.length - 1}",
      );
    } else if (talukas.isNotEmpty) {
      parts.add(
        talukas.length == 1
            ? talukas.first
            : "${talukas.first} +${talukas.length - 1}",
      );
    } else if (districts.isNotEmpty) {
      parts.add(
        districts.length == 1
            ? districts.first
            : "${districts.first} +${districts.length - 1}",
      );
    } else if (state != null && state.isNotEmpty) {
      parts.add(state);
    }

    if (distanceKm > 0) parts.add("${distanceKm.round()} Km");

    if (parts.isEmpty) return "All Clinics";
    return parts.join(' · ');
  }

  static void removeEntry(String storageKey, SearchHistoryEntry entry) {
    final history = getHistory(storageKey);
    history.removeWhere(
      (e) => e.label.toLowerCase() == entry.label.toLowerCase(),
    );
    Api.userInfo.write(storageKey, history.map((e) => e.toJson()).toList());
  }

  static void clear(String storageKey) {
    Api.userInfo.remove(storageKey);
  }
}
