/// Default bucket-list categories. Stored as plain strings on the item so
/// new categories can be added later without a schema migration.
enum ItemCategory { travel, experience, personal, career, education, adventure, other }

extension ItemCategoryX on ItemCategory {
  String get label => switch (this) {
        ItemCategory.travel => 'Travel',
        ItemCategory.experience => 'Experience',
        ItemCategory.personal => 'Personal',
        ItemCategory.career => 'Career',
        ItemCategory.education => 'Education',
        ItemCategory.adventure => 'Adventure',
        ItemCategory.other => 'Other',
      };

  static ItemCategory fromLabel(String value) => ItemCategory.values.firstWhere(
        (c) => c.label == value,
        orElse: () => ItemCategory.other,
      );
}

enum ItemPriority { low, medium, high }

extension ItemPriorityX on ItemPriority {
  String get label => switch (this) {
        ItemPriority.low => 'Low',
        ItemPriority.medium => 'Medium',
        ItemPriority.high => 'High',
      };

  static ItemPriority fromLabel(String value) => ItemPriority.values.firstWhere(
        (p) => p.label == value,
        orElse: () => ItemPriority.medium,
      );
}
