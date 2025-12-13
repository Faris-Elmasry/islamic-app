/// Azkar item model
class AzkarItem {
  final String text;
  final int count;
  final String? description;
  final String? reference;

  AzkarItem({
    required this.text,
    required this.count,
    this.description,
    this.reference,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    return AzkarItem(
      text: json['text'] ?? json['zekr'] ?? '',
      count: json['count'] ?? json['repeat'] ?? 1,
      description: json['description'] ?? json['bless'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'count': count,
      'description': description,
      'reference': reference,
    };
  }
}

/// Azkar category model
class AzkarCategory {
  final int id;
  final String name;
  final List<AzkarItem> items;

  AzkarCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    final itemsList = json['array'] as List<dynamic>? ?? [];
    return AzkarCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['category'] ?? '',
      items: itemsList.map((item) => AzkarItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'array': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// All azkar data
class AzkarData {
  final List<AzkarCategory> categories;

  AzkarData({required this.categories});

  factory AzkarData.fromJsonList(List<dynamic> jsonList) {
    return AzkarData(
      categories: jsonList.map((cat) => AzkarCategory.fromJson(cat)).toList(),
    );
  }

  /// Get category by ID
  AzkarCategory? getCategoryById(int id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get morning azkar (id: 1)
  AzkarCategory? get morningAzkar => getCategoryById(1);

  /// Get evening azkar (id: 2)
  AzkarCategory? get eveningAzkar => getCategoryById(2);

  /// Get prayer azkar (id: 3)
  AzkarCategory? get prayerAzkar => getCategoryById(3);

  /// Get sleep azkar (id: 4)
  AzkarCategory? get sleepAzkar => getCategoryById(4);

  /// Get ruqyah (id: 5)
  AzkarCategory? get ruqyah => getCategoryById(5);

  /// Get dua (id: 6)
  AzkarCategory? get dua => getCategoryById(6);
}
