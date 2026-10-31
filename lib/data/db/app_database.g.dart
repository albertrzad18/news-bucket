// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentsUrlMeta = const VerificationMeta(
    'commentsUrl',
  );
  @override
  late final GeneratedColumn<String> commentsUrl = GeneratedColumn<String>(
    'comments_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSavedMeta = const VerificationMeta(
    'isSaved',
  );
  @override
  late final GeneratedColumn<bool> isSaved = GeneratedColumn<bool>(
    'is_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notifiedMeta = const VerificationMeta(
    'notified',
  );
  @override
  late final GeneratedColumn<bool> notified = GeneratedColumn<bool>(
    'notified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    category,
    title,
    url,
    snippet,
    author,
    score,
    commentCount,
    commentsUrl,
    publishedAt,
    fetchedAt,
    isRead,
    isSaved,
    notified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    }
    if (data.containsKey('comments_url')) {
      context.handle(
        _commentsUrlMeta,
        commentsUrl.isAcceptableOrUnknown(
          data['comments_url']!,
          _commentsUrlMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_saved')) {
      context.handle(
        _isSavedMeta,
        isSaved.isAcceptableOrUnknown(data['is_saved']!, _isSavedMeta),
      );
    }
    if (data.containsKey('notified')) {
      context.handle(
        _notifiedMeta,
        notified.isAcceptableOrUnknown(data['notified']!, _notifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      ),
      commentsUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comments_url'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_saved'],
      )!,
      notified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notified'],
      )!,
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class ArticleRow extends DataClass implements Insertable<ArticleRow> {
  /// Normalized URL.
  final String id;
  final String sourceId;
  final String category;
  final String title;
  final String url;
  final String? snippet;
  final String? author;
  final int? score;
  final int? commentCount;
  final String? commentsUrl;
  final DateTime publishedAt;

  /// When the article was first seen; drives retention.
  final DateTime fetchedAt;
  final bool isRead;
  final bool isSaved;

  /// Set once a notification mentioned this article (used in a later phase).
  final bool notified;
  const ArticleRow({
    required this.id,
    required this.sourceId,
    required this.category,
    required this.title,
    required this.url,
    this.snippet,
    this.author,
    this.score,
    this.commentCount,
    this.commentsUrl,
    required this.publishedAt,
    required this.fetchedAt,
    required this.isRead,
    required this.isSaved,
    required this.notified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || snippet != null) {
      map['snippet'] = Variable<String>(snippet);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || commentCount != null) {
      map['comment_count'] = Variable<int>(commentCount);
    }
    if (!nullToAbsent || commentsUrl != null) {
      map['comments_url'] = Variable<String>(commentsUrl);
    }
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['is_read'] = Variable<bool>(isRead);
    map['is_saved'] = Variable<bool>(isSaved);
    map['notified'] = Variable<bool>(notified);
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      category: Value(category),
      title: Value(title),
      url: Value(url),
      snippet: snippet == null && nullToAbsent
          ? const Value.absent()
          : Value(snippet),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      commentCount: commentCount == null && nullToAbsent
          ? const Value.absent()
          : Value(commentCount),
      commentsUrl: commentsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(commentsUrl),
      publishedAt: Value(publishedAt),
      fetchedAt: Value(fetchedAt),
      isRead: Value(isRead),
      isSaved: Value(isSaved),
      notified: Value(notified),
    );
  }

  factory ArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      snippet: serializer.fromJson<String?>(json['snippet']),
      author: serializer.fromJson<String?>(json['author']),
      score: serializer.fromJson<int?>(json['score']),
      commentCount: serializer.fromJson<int?>(json['commentCount']),
      commentsUrl: serializer.fromJson<String?>(json['commentsUrl']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isSaved: serializer.fromJson<bool>(json['isSaved']),
      notified: serializer.fromJson<bool>(json['notified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'snippet': serializer.toJson<String?>(snippet),
      'author': serializer.toJson<String?>(author),
      'score': serializer.toJson<int?>(score),
      'commentCount': serializer.toJson<int?>(commentCount),
      'commentsUrl': serializer.toJson<String?>(commentsUrl),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isSaved': serializer.toJson<bool>(isSaved),
      'notified': serializer.toJson<bool>(notified),
    };
  }

  ArticleRow copyWith({
    String? id,
    String? sourceId,
    String? category,
    String? title,
    String? url,
    Value<String?> snippet = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<int?> score = const Value.absent(),
    Value<int?> commentCount = const Value.absent(),
    Value<String?> commentsUrl = const Value.absent(),
    DateTime? publishedAt,
    DateTime? fetchedAt,
    bool? isRead,
    bool? isSaved,
    bool? notified,
  }) => ArticleRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    category: category ?? this.category,
    title: title ?? this.title,
    url: url ?? this.url,
    snippet: snippet.present ? snippet.value : this.snippet,
    author: author.present ? author.value : this.author,
    score: score.present ? score.value : this.score,
    commentCount: commentCount.present ? commentCount.value : this.commentCount,
    commentsUrl: commentsUrl.present ? commentsUrl.value : this.commentsUrl,
    publishedAt: publishedAt ?? this.publishedAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    isRead: isRead ?? this.isRead,
    isSaved: isSaved ?? this.isSaved,
    notified: notified ?? this.notified,
  );
  ArticleRow copyWithCompanion(ArticlesCompanion data) {
    return ArticleRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      author: data.author.present ? data.author.value : this.author,
      score: data.score.present ? data.score.value : this.score,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      commentsUrl: data.commentsUrl.present
          ? data.commentsUrl.value
          : this.commentsUrl,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isSaved: data.isSaved.present ? data.isSaved.value : this.isSaved,
      notified: data.notified.present ? data.notified.value : this.notified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('snippet: $snippet, ')
          ..write('author: $author, ')
          ..write('score: $score, ')
          ..write('commentCount: $commentCount, ')
          ..write('commentsUrl: $commentsUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isSaved: $isSaved, ')
          ..write('notified: $notified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    category,
    title,
    url,
    snippet,
    author,
    score,
    commentCount,
    commentsUrl,
    publishedAt,
    fetchedAt,
    isRead,
    isSaved,
    notified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.category == this.category &&
          other.title == this.title &&
          other.url == this.url &&
          other.snippet == this.snippet &&
          other.author == this.author &&
          other.score == this.score &&
          other.commentCount == this.commentCount &&
          other.commentsUrl == this.commentsUrl &&
          other.publishedAt == this.publishedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.isRead == this.isRead &&
          other.isSaved == this.isSaved &&
          other.notified == this.notified);
}

class ArticlesCompanion extends UpdateCompanion<ArticleRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> category;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> snippet;
  final Value<String?> author;
  final Value<int?> score;
  final Value<int?> commentCount;
  final Value<String?> commentsUrl;
  final Value<DateTime> publishedAt;
  final Value<DateTime> fetchedAt;
  final Value<bool> isRead;
  final Value<bool> isSaved;
  final Value<bool> notified;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.snippet = const Value.absent(),
    this.author = const Value.absent(),
    this.score = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.commentsUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.notified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required String sourceId,
    required String category,
    required String title,
    required String url,
    this.snippet = const Value.absent(),
    this.author = const Value.absent(),
    this.score = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.commentsUrl = const Value.absent(),
    required DateTime publishedAt,
    required DateTime fetchedAt,
    this.isRead = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.notified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       category = Value(category),
       title = Value(title),
       url = Value(url),
       publishedAt = Value(publishedAt),
       fetchedAt = Value(fetchedAt);
  static Insertable<ArticleRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? snippet,
    Expression<String>? author,
    Expression<int>? score,
    Expression<int>? commentCount,
    Expression<String>? commentsUrl,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? fetchedAt,
    Expression<bool>? isRead,
    Expression<bool>? isSaved,
    Expression<bool>? notified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (snippet != null) 'snippet': snippet,
      if (author != null) 'author': author,
      if (score != null) 'score': score,
      if (commentCount != null) 'comment_count': commentCount,
      if (commentsUrl != null) 'comments_url': commentsUrl,
      if (publishedAt != null) 'published_at': publishedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (isRead != null) 'is_read': isRead,
      if (isSaved != null) 'is_saved': isSaved,
      if (notified != null) 'notified': notified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? category,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? snippet,
    Value<String?>? author,
    Value<int?>? score,
    Value<int?>? commentCount,
    Value<String?>? commentsUrl,
    Value<DateTime>? publishedAt,
    Value<DateTime>? fetchedAt,
    Value<bool>? isRead,
    Value<bool>? isSaved,
    Value<bool>? notified,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      category: category ?? this.category,
      title: title ?? this.title,
      url: url ?? this.url,
      snippet: snippet ?? this.snippet,
      author: author ?? this.author,
      score: score ?? this.score,
      commentCount: commentCount ?? this.commentCount,
      commentsUrl: commentsUrl ?? this.commentsUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isRead: isRead ?? this.isRead,
      isSaved: isSaved ?? this.isSaved,
      notified: notified ?? this.notified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (commentsUrl.present) {
      map['comments_url'] = Variable<String>(commentsUrl.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isSaved.present) {
      map['is_saved'] = Variable<bool>(isSaved.value);
    }
    if (notified.present) {
      map['notified'] = Variable<bool>(notified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('snippet: $snippet, ')
          ..write('author: $author, ')
          ..write('score: $score, ')
          ..write('commentCount: $commentCount, ')
          ..write('commentsUrl: $commentsUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isSaved: $isSaved, ')
          ..write('notified: $notified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceStatesTable extends SourceStates
    with TableInfo<$SourceStatesTable, SourceStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastItemCountMeta = const VerificationMeta(
    'lastItemCount',
  );
  @override
  late final GeneratedColumn<int> lastItemCount = GeneratedColumn<int>(
    'last_item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    lastAttemptAt,
    lastSuccessAt,
    lastError,
    lastItemCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAttemptAtMeta);
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('last_item_count')) {
      context.handle(
        _lastItemCountMeta,
        lastItemCount.isAcceptableOrUnknown(
          data['last_item_count']!,
          _lastItemCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  SourceStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceStateRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      lastItemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_item_count'],
      )!,
    );
  }

  @override
  $SourceStatesTable createAlias(String alias) {
    return $SourceStatesTable(attachedDatabase, alias);
  }
}

class SourceStateRow extends DataClass implements Insertable<SourceStateRow> {
  final String sourceId;
  final DateTime lastAttemptAt;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final int lastItemCount;
  const SourceStateRow({
    required this.sourceId,
    required this.lastAttemptAt,
    this.lastSuccessAt,
    this.lastError,
    required this.lastItemCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['last_item_count'] = Variable<int>(lastItemCount);
    return map;
  }

  SourceStatesCompanion toCompanion(bool nullToAbsent) {
    return SourceStatesCompanion(
      sourceId: Value(sourceId),
      lastAttemptAt: Value(lastAttemptAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      lastItemCount: Value(lastItemCount),
    );
  }

  factory SourceStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceStateRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      lastAttemptAt: serializer.fromJson<DateTime>(json['lastAttemptAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastItemCount: serializer.fromJson<int>(json['lastItemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'lastAttemptAt': serializer.toJson<DateTime>(lastAttemptAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastError': serializer.toJson<String?>(lastError),
      'lastItemCount': serializer.toJson<int>(lastItemCount),
    };
  }

  SourceStateRow copyWith({
    String? sourceId,
    DateTime? lastAttemptAt,
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? lastItemCount,
  }) => SourceStateRow(
    sourceId: sourceId ?? this.sourceId,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    lastItemCount: lastItemCount ?? this.lastItemCount,
  );
  SourceStateRow copyWithCompanion(SourceStatesCompanion data) {
    return SourceStateRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastItemCount: data.lastItemCount.present
          ? data.lastItemCount.value
          : this.lastItemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceStateRow(')
          ..write('sourceId: $sourceId, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastItemCount: $lastItemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    lastAttemptAt,
    lastSuccessAt,
    lastError,
    lastItemCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceStateRow &&
          other.sourceId == this.sourceId &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastError == this.lastError &&
          other.lastItemCount == this.lastItemCount);
}

class SourceStatesCompanion extends UpdateCompanion<SourceStateRow> {
  final Value<String> sourceId;
  final Value<DateTime> lastAttemptAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> lastError;
  final Value<int> lastItemCount;
  final Value<int> rowid;
  const SourceStatesCompanion({
    this.sourceId = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastItemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceStatesCompanion.insert({
    required String sourceId,
    required DateTime lastAttemptAt,
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastItemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       lastAttemptAt = Value(lastAttemptAt);
  static Insertable<SourceStateRow> custom({
    Expression<String>? sourceId,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? lastError,
    Expression<int>? lastItemCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastError != null) 'last_error': lastError,
      if (lastItemCount != null) 'last_item_count': lastItemCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceStatesCompanion copyWith({
    Value<String>? sourceId,
    Value<DateTime>? lastAttemptAt,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? lastError,
    Value<int>? lastItemCount,
    Value<int>? rowid,
  }) {
    return SourceStatesCompanion(
      sourceId: sourceId ?? this.sourceId,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastError: lastError ?? this.lastError,
      lastItemCount: lastItemCount ?? this.lastItemCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastItemCount.present) {
      map['last_item_count'] = Variable<int>(lastItemCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceStatesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastItemCount: $lastItemCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $SourceStatesTable sourceStates = $SourceStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [articles, sourceStates];
}

typedef $$ArticlesTableCreateCompanionBuilder = ArticlesCompanion Function({
  required String id,
  required String sourceId,
  required String category,
  required String title,
  required String url,
  Value<String?> snippet,
  Value<String?> author,
  Value<int?> score,
  Value<int?> commentCount,
  Value<String?> commentsUrl,
  required DateTime publishedAt,
  required DateTime fetchedAt,
  Value<bool> isRead,
  Value<bool> isSaved,
  Value<bool> notified,
  Value<int> rowid,
});
typedef $$ArticlesTableUpdateCompanionBuilder = ArticlesCompanion Function({
  Value<String> id,
  Value<String> sourceId,
  Value<String> category,
  Value<String> title,
  Value<String> url,
  Value<String?> snippet,
  Value<String?> author,
  Value<int?> score,
  Value<int?> commentCount,
  Value<String?> commentsUrl,
  Value<DateTime> publishedAt,
  Value<DateTime> fetchedAt,
  Value<bool> isRead,
  Value<bool> isSaved,
  Value<bool> notified,
  Value<int> rowid,
});

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentsUrl => $composableBuilder(
    column: $table.commentsUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notified => $composableBuilder(
    column: $table.notified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentsUrl => $composableBuilder(
    column: $table.commentsUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notified => $composableBuilder(
    column: $table.notified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commentsUrl => $composableBuilder(
    column: $table.commentsUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isSaved =>
      $composableBuilder(column: $table.isSaved, builder: (column) => column);

  GeneratedColumn<bool> get notified =>
      $composableBuilder(column: $table.notified, builder: (column) => column);
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleRow,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (
            ArticleRow,
            BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>,
          ),
          ArticleRow,
          PrefetchHooks Function()
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> snippet = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int?> commentCount = const Value.absent(),
                Value<String?> commentsUrl = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<bool> notified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                sourceId: sourceId,
                category: category,
                title: title,
                url: url,
                snippet: snippet,
                author: author,
                score: score,
                commentCount: commentCount,
                commentsUrl: commentsUrl,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                isRead: isRead,
                isSaved: isSaved,
                notified: notified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String category,
                required String title,
                required String url,
                Value<String?> snippet = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int?> commentCount = const Value.absent(),
                Value<String?> commentsUrl = const Value.absent(),
                required DateTime publishedAt,
                required DateTime fetchedAt,
                Value<bool> isRead = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<bool> notified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                sourceId: sourceId,
                category: category,
                title: title,
                url: url,
                snippet: snippet,
                author: author,
                score: score,
                commentCount: commentCount,
                commentsUrl: commentsUrl,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                isRead: isRead,
                isSaved: isSaved,
                notified: notified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticlesTable, ArticleRow>(table),
                  BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleRow,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleRow, BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>),
      ArticleRow,
      PrefetchHooks Function()
    >;
typedef $$SourceStatesTableCreateCompanionBuilder =
    SourceStatesCompanion Function({
      required String sourceId,
      required DateTime lastAttemptAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<int> lastItemCount,
      Value<int> rowid,
    });
typedef $$SourceStatesTableUpdateCompanionBuilder =
    SourceStatesCompanion Function({
      Value<String> sourceId,
      Value<DateTime> lastAttemptAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<int> lastItemCount,
      Value<int> rowid,
    });

class $$SourceStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SourceStatesTable> {
  $$SourceStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastItemCount => $composableBuilder(
    column: $table.lastItemCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourceStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceStatesTable> {
  $$SourceStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastItemCount => $composableBuilder(
    column: $table.lastItemCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceStatesTable> {
  $$SourceStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get lastItemCount => $composableBuilder(
    column: $table.lastItemCount,
    builder: (column) => column,
  );
}

class $$SourceStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceStatesTable,
          SourceStateRow,
          $$SourceStatesTableFilterComposer,
          $$SourceStatesTableOrderingComposer,
          $$SourceStatesTableAnnotationComposer,
          $$SourceStatesTableCreateCompanionBuilder,
          $$SourceStatesTableUpdateCompanionBuilder,
          (
            SourceStateRow,
            BaseReferences<_$AppDatabase, $SourceStatesTable, SourceStateRow>,
          ),
          SourceStateRow,
          PrefetchHooks Function()
        > {
  $$SourceStatesTableTableManager(_$AppDatabase db, $SourceStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<DateTime> lastAttemptAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> lastItemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceStatesCompanion(
                sourceId: sourceId,
                lastAttemptAt: lastAttemptAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                lastItemCount: lastItemCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required DateTime lastAttemptAt,
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> lastItemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceStatesCompanion.insert(
                sourceId: sourceId,
                lastAttemptAt: lastAttemptAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                lastItemCount: lastItemCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceStatesTable, SourceStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SourceStatesTable,
                    SourceStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourceStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceStatesTable,
      SourceStateRow,
      $$SourceStatesTableFilterComposer,
      $$SourceStatesTableOrderingComposer,
      $$SourceStatesTableAnnotationComposer,
      $$SourceStatesTableCreateCompanionBuilder,
      $$SourceStatesTableUpdateCompanionBuilder,
      (
        SourceStateRow,
        BaseReferences<_$AppDatabase, $SourceStatesTable, SourceStateRow>,
      ),
      SourceStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$SourceStatesTableTableManager get sourceStates =>
      $$SourceStatesTableTableManager(_db, _db.sourceStates);
}
