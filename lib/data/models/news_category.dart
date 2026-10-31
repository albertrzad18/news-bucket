/// Topic buckets used for filtering. Ids match `category` in
/// `assets/sources.json`.
enum NewsCategory {
  ai('ai', 'AI'),
  programming('programming', 'Programming'),
  security('security', 'Security'),
  markets('markets', 'Stocks & ETFs'),
  crypto('crypto', 'Crypto');

  const NewsCategory(this.id, this.label);

  final String id;
  final String label;

  static NewsCategory fromId(String id) =>
      values.firstWhere((category) => category.id == id);
}
