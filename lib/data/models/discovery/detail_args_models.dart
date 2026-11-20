class IdArgsModel {
  const IdArgsModel({required this.id, this.title});

  final int id;
  final String? title;
}

/// route argument for screens keyed by a slug (a job post)
class SlugArgsModel {
  const SlugArgsModel({required this.slug});

  final String slug;
}
