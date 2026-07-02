// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _specificDateMeta = const VerificationMeta(
    'specificDate',
  );
  @override
  late final GeneratedColumn<DateTime> specificDate = GeneratedColumn<DateTime>(
    'specific_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    startMinutes,
    endMinutes,
    colorValue,
    isRecurring,
    weekdaysMask,
    specificDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('specific_date')) {
      context.handle(
        _specificDateMeta,
        specificDate.isAcceptableOrUnknown(
          data['specific_date']!,
          _specificDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      )!,
      specificDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}specific_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final int startMinutes;
  final int endMinutes;
  final int colorValue;
  final bool isRecurring;
  final int weekdaysMask;
  final DateTime? specificDate;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.startMinutes,
    required this.endMinutes,
    required this.colorValue,
    required this.isRecurring,
    required this.weekdaysMask,
    this.specificDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['color_value'] = Variable<int>(colorValue);
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['weekdays_mask'] = Variable<int>(weekdaysMask);
    if (!nullToAbsent || specificDate != null) {
      map['specific_date'] = Variable<DateTime>(specificDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      colorValue: Value(colorValue),
      isRecurring: Value(isRecurring),
      weekdaysMask: Value(weekdaysMask),
      specificDate: specificDate == null && nullToAbsent
          ? const Value.absent()
          : Value(specificDate),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      weekdaysMask: serializer.fromJson<int>(json['weekdaysMask']),
      specificDate: serializer.fromJson<DateTime?>(json['specificDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'colorValue': serializer.toJson<int>(colorValue),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'weekdaysMask': serializer.toJson<int>(weekdaysMask),
      'specificDate': serializer.toJson<DateTime?>(specificDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    int? startMinutes,
    int? endMinutes,
    int? colorValue,
    bool? isRecurring,
    int? weekdaysMask,
    Value<DateTime?> specificDate = const Value.absent(),
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    colorValue: colorValue ?? this.colorValue,
    isRecurring: isRecurring ?? this.isRecurring,
    weekdaysMask: weekdaysMask ?? this.weekdaysMask,
    specificDate: specificDate.present ? specificDate.value : this.specificDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      specificDate: data.specificDate.present
          ? data.specificDate.value
          : this.specificDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('colorValue: $colorValue, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('specificDate: $specificDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    startMinutes,
    endMinutes,
    colorValue,
    isRecurring,
    weekdaysMask,
    specificDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.colorValue == this.colorValue &&
          other.isRecurring == this.isRecurring &&
          other.weekdaysMask == this.weekdaysMask &&
          other.specificDate == this.specificDate &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<int> colorValue;
  final Value<bool> isRecurring;
  final Value<int> weekdaysMask;
  final Value<DateTime?> specificDate;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.specificDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int startMinutes,
    required int endMinutes,
    required int colorValue,
    this.isRecurring = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.specificDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       startMinutes = Value(startMinutes),
       endMinutes = Value(endMinutes),
       colorValue = Value(colorValue);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? colorValue,
    Expression<bool>? isRecurring,
    Expression<int>? weekdaysMask,
    Expression<DateTime>? specificDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (colorValue != null) 'color_value': colorValue,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (specificDate != null) 'specific_date': specificDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<int>? colorValue,
    Value<bool>? isRecurring,
    Value<int>? weekdaysMask,
    Value<DateTime?>? specificDate,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      colorValue: colorValue ?? this.colorValue,
      isRecurring: isRecurring ?? this.isRecurring,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      specificDate: specificDate ?? this.specificDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (specificDate.present) {
      map['specific_date'] = Variable<DateTime>(specificDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('colorValue: $colorValue, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('specificDate: $specificDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required int startMinutes,
      required int endMinutes,
      required int colorValue,
      Value<bool> isRecurring,
      Value<int> weekdaysMask,
      Value<DateTime?> specificDate,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<int> colorValue,
      Value<bool> isRecurring,
      Value<int> weekdaysMask,
      Value<DateTime?> specificDate,
      Value<DateTime> createdAt,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get specificDate => $composableBuilder(
    column: $table.specificDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get specificDate => $composableBuilder(
    column: $table.specificDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get specificDate => $composableBuilder(
    column: $table.specificDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<DateTime?> specificDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                colorValue: colorValue,
                isRecurring: isRecurring,
                weekdaysMask: weekdaysMask,
                specificDate: specificDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int startMinutes,
                required int endMinutes,
                required int colorValue,
                Value<bool> isRecurring = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<DateTime?> specificDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                colorValue: colorValue,
                isRecurring: isRecurring,
                weekdaysMask: weekdaysMask,
                specificDate: specificDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
