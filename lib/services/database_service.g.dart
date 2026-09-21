// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    exerciseName,
    weight,
    reps,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final String userId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime date;
  final DateTime createdAt;
  const WorkoutSet({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      userId: Value(userId),
      exerciseName: Value(exerciseName),
      weight: Value(weight),
      reps: Value(reps),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkoutSet copyWith({
    int? id,
    String? userId,
    String? exerciseName,
    double? weight,
    int? reps,
    DateTime? date,
    DateTime? createdAt,
  }) => WorkoutSet(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    exerciseName: exerciseName ?? this.exerciseName,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, exerciseName, weight, reps, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.exerciseName == this.exerciseName &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> exerciseName;
  final Value<double> weight;
  final Value<int> reps;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
    required DateTime date,
    required DateTime createdAt,
  }) : userId = Value(userId),
       exerciseName = Value(exerciseName),
       weight = Value(weight),
       reps = Value(reps),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? exerciseName,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? exerciseName,
    Value<double>? weight,
    Value<int>? reps,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExerciseLibraryTable extends ExerciseLibrary
    with TableInfo<$ExerciseLibraryTable, ExerciseLibraryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseLibraryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    exerciseName,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_library';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseLibraryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseLibraryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseLibraryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExerciseLibraryTable createAlias(String alias) {
    return $ExerciseLibraryTable(attachedDatabase, alias);
  }
}

class ExerciseLibraryData extends DataClass
    implements Insertable<ExerciseLibraryData> {
  final int id;
  final String userId;
  final String exerciseName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExerciseLibraryData({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExerciseLibraryCompanion toCompanion(bool nullToAbsent) {
    return ExerciseLibraryCompanion(
      id: Value(id),
      userId: Value(userId),
      exerciseName: Value(exerciseName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExerciseLibraryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseLibraryData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExerciseLibraryData copyWith({
    int? id,
    String? userId,
    String? exerciseName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExerciseLibraryData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    exerciseName: exerciseName ?? this.exerciseName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExerciseLibraryData copyWithCompanion(ExerciseLibraryCompanion data) {
    return ExerciseLibraryData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLibraryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, exerciseName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseLibraryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.exerciseName == this.exerciseName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExerciseLibraryCompanion extends UpdateCompanion<ExerciseLibraryData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> exerciseName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ExerciseLibraryCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExerciseLibraryCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String exerciseName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       exerciseName = Value(exerciseName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExerciseLibraryData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? exerciseName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExerciseLibraryCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? exerciseName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ExerciseLibraryCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLibraryCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutRoutinesTable extends WorkoutRoutines
    with TableInfo<$WorkoutRoutinesTable, WorkoutRoutine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutRoutinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineNameMeta = const VerificationMeta(
    'routineName',
  );
  @override
  late final GeneratedColumn<String> routineName = GeneratedColumn<String>(
    'routine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    routineName,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('routine_name')) {
      context.handle(
        _routineNameMeta,
        routineName.isAcceptableOrUnknown(
          data['routine_name']!,
          _routineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRoutine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRoutine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      routineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutRoutinesTable createAlias(String alias) {
    return $WorkoutRoutinesTable(attachedDatabase, alias);
  }
}

class WorkoutRoutine extends DataClass implements Insertable<WorkoutRoutine> {
  final int id;
  final String userId;
  final DateTime date;
  final String routineName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkoutRoutine({
    required this.id,
    required this.userId,
    required this.date,
    required this.routineName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['routine_name'] = Variable<String>(routineName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutRoutinesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutRoutinesCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      routineName: Value(routineName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRoutine(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      routineName: serializer.fromJson<String>(json['routineName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'routineName': serializer.toJson<String>(routineName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutRoutine copyWith({
    int? id,
    String? userId,
    DateTime? date,
    String? routineName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkoutRoutine(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    routineName: routineName ?? this.routineName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutRoutine copyWithCompanion(WorkoutRoutinesCompanion data) {
    return WorkoutRoutine(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      routineName: data.routineName.present
          ? data.routineName.value
          : this.routineName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRoutine(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('routineName: $routineName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, date, routineName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRoutine &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.routineName == this.routineName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutRoutinesCompanion extends UpdateCompanion<WorkoutRoutine> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String> routineName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WorkoutRoutinesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.routineName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WorkoutRoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required DateTime date,
    required String routineName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       date = Value(date),
       routineName = Value(routineName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutRoutine> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? routineName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (routineName != null) 'routine_name': routineName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WorkoutRoutinesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String>? routineName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WorkoutRoutinesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      routineName: routineName ?? this.routineName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (routineName.present) {
      map['routine_name'] = Variable<String>(routineName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('routineName: $routineName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoutineSetsTable extends RoutineSets
    with TableInfo<$RoutineSetsTable, RoutineSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    exerciseName,
    setNumber,
    weight,
    reps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
    );
  }

  @override
  $RoutineSetsTable createAlias(String alias) {
    return $RoutineSetsTable(attachedDatabase, alias);
  }
}

class RoutineSet extends DataClass implements Insertable<RoutineSet> {
  final int id;
  final int routineId;
  final String exerciseName;
  final int setNumber;
  final double weight;
  final int reps;
  const RoutineSet({
    required this.id,
    required this.routineId,
    required this.exerciseName,
    required this.setNumber,
    required this.weight,
    required this.reps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['set_number'] = Variable<int>(setNumber);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    return map;
  }

  RoutineSetsCompanion toCompanion(bool nullToAbsent) {
    return RoutineSetsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      exerciseName: Value(exerciseName),
      setNumber: Value(setNumber),
      weight: Value(weight),
      reps: Value(reps),
    );
  }

  factory RoutineSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineSet(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'setNumber': serializer.toJson<int>(setNumber),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
    };
  }

  RoutineSet copyWith({
    int? id,
    int? routineId,
    String? exerciseName,
    int? setNumber,
    double? weight,
    int? reps,
  }) => RoutineSet(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    exerciseName: exerciseName ?? this.exerciseName,
    setNumber: setNumber ?? this.setNumber,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
  );
  RoutineSet copyWithCompanion(RoutineSetsCompanion data) {
    return RoutineSet(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSet(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routineId, exerciseName, setNumber, weight, reps);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineSet &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.exerciseName == this.exerciseName &&
          other.setNumber == this.setNumber &&
          other.weight == this.weight &&
          other.reps == this.reps);
}

class RoutineSetsCompanion extends UpdateCompanion<RoutineSet> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<String> exerciseName;
  final Value<int> setNumber;
  final Value<double> weight;
  final Value<int> reps;
  const RoutineSetsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
  });
  RoutineSetsCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required String exerciseName,
    required int setNumber,
    required double weight,
    required int reps,
  }) : routineId = Value(routineId),
       exerciseName = Value(exerciseName),
       setNumber = Value(setNumber),
       weight = Value(weight),
       reps = Value(reps);
  static Insertable<RoutineSet> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<String>? exerciseName,
    Expression<int>? setNumber,
    Expression<double>? weight,
    Expression<int>? reps,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (setNumber != null) 'set_number': setNumber,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
    });
  }

  RoutineSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<String>? exerciseName,
    Value<int>? setNumber,
    Value<double>? weight,
    Value<int>? reps,
  }) {
    return RoutineSetsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSetsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps')
          ..write(')'))
        .toString();
  }
}

class $DailyDataTable extends DailyData
    with TableInfo<$DailyDataTable, DailyDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyDataTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calorieTargetMeta = const VerificationMeta(
    'calorieTarget',
  );
  @override
  late final GeneratedColumn<double> calorieTarget = GeneratedColumn<double>(
    'calorie_target',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2500),
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stepTargetMeta = const VerificationMeta(
    'stepTarget',
  );
  @override
  late final GeneratedColumn<int> stepTarget = GeneratedColumn<int>(
    'step_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000),
  );
  static const VerificationMeta _recoveryScoreMeta = const VerificationMeta(
    'recoveryScore',
  );
  @override
  late final GeneratedColumn<double> recoveryScore = GeneratedColumn<double>(
    'recovery_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _effortScoreMeta = const VerificationMeta(
    'effortScore',
  );
  @override
  late final GeneratedColumn<double> effortScore = GeneratedColumn<double>(
    'effort_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    calories,
    calorieTarget,
    steps,
    stepTarget,
    recoveryScore,
    effortScore,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('calorie_target')) {
      context.handle(
        _calorieTargetMeta,
        calorieTarget.isAcceptableOrUnknown(
          data['calorie_target']!,
          _calorieTargetMeta,
        ),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('step_target')) {
      context.handle(
        _stepTargetMeta,
        stepTarget.isAcceptableOrUnknown(data['step_target']!, _stepTargetMeta),
      );
    }
    if (data.containsKey('recovery_score')) {
      context.handle(
        _recoveryScoreMeta,
        recoveryScore.isAcceptableOrUnknown(
          data['recovery_score']!,
          _recoveryScoreMeta,
        ),
      );
    }
    if (data.containsKey('effort_score')) {
      context.handle(
        _effortScoreMeta,
        effortScore.isAcceptableOrUnknown(
          data['effort_score']!,
          _effortScoreMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      calorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calorie_target'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      stepTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_target'],
      )!,
      recoveryScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_score'],
      )!,
      effortScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}effort_score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyDataTable createAlias(String alias) {
    return $DailyDataTable(attachedDatabase, alias);
  }
}

class DailyDataData extends DataClass implements Insertable<DailyDataData> {
  final int id;
  final String userId;
  final DateTime date;
  final double calories;
  final double calorieTarget;
  final int steps;
  final int stepTarget;
  final double recoveryScore;
  final double effortScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyDataData({
    required this.id,
    required this.userId,
    required this.date,
    required this.calories,
    required this.calorieTarget,
    required this.steps,
    required this.stepTarget,
    required this.recoveryScore,
    required this.effortScore,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['calories'] = Variable<double>(calories);
    map['calorie_target'] = Variable<double>(calorieTarget);
    map['steps'] = Variable<int>(steps);
    map['step_target'] = Variable<int>(stepTarget);
    map['recovery_score'] = Variable<double>(recoveryScore);
    map['effort_score'] = Variable<double>(effortScore);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyDataCompanion toCompanion(bool nullToAbsent) {
    return DailyDataCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      calories: Value(calories),
      calorieTarget: Value(calorieTarget),
      steps: Value(steps),
      stepTarget: Value(stepTarget),
      recoveryScore: Value(recoveryScore),
      effortScore: Value(effortScore),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyDataData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      calories: serializer.fromJson<double>(json['calories']),
      calorieTarget: serializer.fromJson<double>(json['calorieTarget']),
      steps: serializer.fromJson<int>(json['steps']),
      stepTarget: serializer.fromJson<int>(json['stepTarget']),
      recoveryScore: serializer.fromJson<double>(json['recoveryScore']),
      effortScore: serializer.fromJson<double>(json['effortScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'calories': serializer.toJson<double>(calories),
      'calorieTarget': serializer.toJson<double>(calorieTarget),
      'steps': serializer.toJson<int>(steps),
      'stepTarget': serializer.toJson<int>(stepTarget),
      'recoveryScore': serializer.toJson<double>(recoveryScore),
      'effortScore': serializer.toJson<double>(effortScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyDataData copyWith({
    int? id,
    String? userId,
    DateTime? date,
    double? calories,
    double? calorieTarget,
    int? steps,
    int? stepTarget,
    double? recoveryScore,
    double? effortScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyDataData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    calories: calories ?? this.calories,
    calorieTarget: calorieTarget ?? this.calorieTarget,
    steps: steps ?? this.steps,
    stepTarget: stepTarget ?? this.stepTarget,
    recoveryScore: recoveryScore ?? this.recoveryScore,
    effortScore: effortScore ?? this.effortScore,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyDataData copyWithCompanion(DailyDataCompanion data) {
    return DailyDataData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      calories: data.calories.present ? data.calories.value : this.calories,
      calorieTarget: data.calorieTarget.present
          ? data.calorieTarget.value
          : this.calorieTarget,
      steps: data.steps.present ? data.steps.value : this.steps,
      stepTarget: data.stepTarget.present
          ? data.stepTarget.value
          : this.stepTarget,
      recoveryScore: data.recoveryScore.present
          ? data.recoveryScore.value
          : this.recoveryScore,
      effortScore: data.effortScore.present
          ? data.effortScore.value
          : this.effortScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyDataData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('steps: $steps, ')
          ..write('stepTarget: $stepTarget, ')
          ..write('recoveryScore: $recoveryScore, ')
          ..write('effortScore: $effortScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    calories,
    calorieTarget,
    steps,
    stepTarget,
    recoveryScore,
    effortScore,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyDataData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.calories == this.calories &&
          other.calorieTarget == this.calorieTarget &&
          other.steps == this.steps &&
          other.stepTarget == this.stepTarget &&
          other.recoveryScore == this.recoveryScore &&
          other.effortScore == this.effortScore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyDataCompanion extends UpdateCompanion<DailyDataData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<double> calories;
  final Value<double> calorieTarget;
  final Value<int> steps;
  final Value<int> stepTarget;
  final Value<double> recoveryScore;
  final Value<double> effortScore;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyDataCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.calories = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepTarget = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.effortScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyDataCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required DateTime date,
    this.calories = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepTarget = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.effortScore = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyDataData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<double>? calories,
    Expression<double>? calorieTarget,
    Expression<int>? steps,
    Expression<int>? stepTarget,
    Expression<double>? recoveryScore,
    Expression<double>? effortScore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (calories != null) 'calories': calories,
      if (calorieTarget != null) 'calorie_target': calorieTarget,
      if (steps != null) 'steps': steps,
      if (stepTarget != null) 'step_target': stepTarget,
      if (recoveryScore != null) 'recovery_score': recoveryScore,
      if (effortScore != null) 'effort_score': effortScore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyDataCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<double>? calories,
    Value<double>? calorieTarget,
    Value<int>? steps,
    Value<int>? stepTarget,
    Value<double>? recoveryScore,
    Value<double>? effortScore,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DailyDataCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      calories: calories ?? this.calories,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      steps: steps ?? this.steps,
      stepTarget: stepTarget ?? this.stepTarget,
      recoveryScore: recoveryScore ?? this.recoveryScore,
      effortScore: effortScore ?? this.effortScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (calorieTarget.present) {
      map['calorie_target'] = Variable<double>(calorieTarget.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (stepTarget.present) {
      map['step_target'] = Variable<int>(stepTarget.value);
    }
    if (recoveryScore.present) {
      map['recovery_score'] = Variable<double>(recoveryScore.value);
    }
    if (effortScore.present) {
      map['effort_score'] = Variable<double>(effortScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyDataCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('steps: $steps, ')
          ..write('stepTarget: $stepTarget, ')
          ..write('recoveryScore: $recoveryScore, ')
          ..write('effortScore: $effortScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DietEntriesTable extends DietEntries
    with TableInfo<$DietEntriesTable, DietEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedQuantityMeta = const VerificationMeta(
    'plannedQuantity',
  );
  @override
  late final GeneratedColumn<double> plannedQuantity = GeneratedColumn<double>(
    'planned_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedCaloriesMeta = const VerificationMeta(
    'plannedCalories',
  );
  @override
  late final GeneratedColumn<double> plannedCalories = GeneratedColumn<double>(
    'planned_calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualQuantityMeta = const VerificationMeta(
    'actualQuantity',
  );
  @override
  late final GeneratedColumn<double> actualQuantity = GeneratedColumn<double>(
    'actual_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actualCaloriesMeta = const VerificationMeta(
    'actualCalories',
  );
  @override
  late final GeneratedColumn<double> actualCalories = GeneratedColumn<double>(
    'actual_calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _eatenMeta = const VerificationMeta('eaten');
  @override
  late final GeneratedColumn<bool> eaten = GeneratedColumn<bool>(
    'eaten',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("eaten" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    meal,
    foodName,
    plannedQuantity,
    quantityUnit,
    plannedCalories,
    actualQuantity,
    actualCalories,
    eaten,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diet_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('planned_quantity')) {
      context.handle(
        _plannedQuantityMeta,
        plannedQuantity.isAcceptableOrUnknown(
          data['planned_quantity']!,
          _plannedQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedQuantityMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('planned_calories')) {
      context.handle(
        _plannedCaloriesMeta,
        plannedCalories.isAcceptableOrUnknown(
          data['planned_calories']!,
          _plannedCaloriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedCaloriesMeta);
    }
    if (data.containsKey('actual_quantity')) {
      context.handle(
        _actualQuantityMeta,
        actualQuantity.isAcceptableOrUnknown(
          data['actual_quantity']!,
          _actualQuantityMeta,
        ),
      );
    }
    if (data.containsKey('actual_calories')) {
      context.handle(
        _actualCaloriesMeta,
        actualCalories.isAcceptableOrUnknown(
          data['actual_calories']!,
          _actualCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('eaten')) {
      context.handle(
        _eatenMeta,
        eaten.isAcceptableOrUnknown(data['eaten']!, _eatenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DietEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      plannedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_quantity'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      plannedCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_calories'],
      )!,
      actualQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_quantity'],
      )!,
      actualCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_calories'],
      )!,
      eaten: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}eaten'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DietEntriesTable createAlias(String alias) {
    return $DietEntriesTable(attachedDatabase, alias);
  }
}

class DietEntry extends DataClass implements Insertable<DietEntry> {
  final int id;
  final String userId;
  final DateTime date;
  final String meal;
  final String foodName;
  final double plannedQuantity;
  final String quantityUnit;
  final double plannedCalories;
  final double actualQuantity;
  final double actualCalories;
  final bool eaten;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DietEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.meal,
    required this.foodName,
    required this.plannedQuantity,
    required this.quantityUnit,
    required this.plannedCalories,
    required this.actualQuantity,
    required this.actualCalories,
    required this.eaten,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['meal'] = Variable<String>(meal);
    map['food_name'] = Variable<String>(foodName);
    map['planned_quantity'] = Variable<double>(plannedQuantity);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    map['planned_calories'] = Variable<double>(plannedCalories);
    map['actual_quantity'] = Variable<double>(actualQuantity);
    map['actual_calories'] = Variable<double>(actualCalories);
    map['eaten'] = Variable<bool>(eaten);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DietEntriesCompanion toCompanion(bool nullToAbsent) {
    return DietEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      meal: Value(meal),
      foodName: Value(foodName),
      plannedQuantity: Value(plannedQuantity),
      quantityUnit: Value(quantityUnit),
      plannedCalories: Value(plannedCalories),
      actualQuantity: Value(actualQuantity),
      actualCalories: Value(actualCalories),
      eaten: Value(eaten),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DietEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietEntry(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      meal: serializer.fromJson<String>(json['meal']),
      foodName: serializer.fromJson<String>(json['foodName']),
      plannedQuantity: serializer.fromJson<double>(json['plannedQuantity']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      plannedCalories: serializer.fromJson<double>(json['plannedCalories']),
      actualQuantity: serializer.fromJson<double>(json['actualQuantity']),
      actualCalories: serializer.fromJson<double>(json['actualCalories']),
      eaten: serializer.fromJson<bool>(json['eaten']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'meal': serializer.toJson<String>(meal),
      'foodName': serializer.toJson<String>(foodName),
      'plannedQuantity': serializer.toJson<double>(plannedQuantity),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'plannedCalories': serializer.toJson<double>(plannedCalories),
      'actualQuantity': serializer.toJson<double>(actualQuantity),
      'actualCalories': serializer.toJson<double>(actualCalories),
      'eaten': serializer.toJson<bool>(eaten),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DietEntry copyWith({
    int? id,
    String? userId,
    DateTime? date,
    String? meal,
    String? foodName,
    double? plannedQuantity,
    String? quantityUnit,
    double? plannedCalories,
    double? actualQuantity,
    double? actualCalories,
    bool? eaten,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DietEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    meal: meal ?? this.meal,
    foodName: foodName ?? this.foodName,
    plannedQuantity: plannedQuantity ?? this.plannedQuantity,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    plannedCalories: plannedCalories ?? this.plannedCalories,
    actualQuantity: actualQuantity ?? this.actualQuantity,
    actualCalories: actualCalories ?? this.actualCalories,
    eaten: eaten ?? this.eaten,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DietEntry copyWithCompanion(DietEntriesCompanion data) {
    return DietEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      plannedQuantity: data.plannedQuantity.present
          ? data.plannedQuantity.value
          : this.plannedQuantity,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      plannedCalories: data.plannedCalories.present
          ? data.plannedCalories.value
          : this.plannedCalories,
      actualQuantity: data.actualQuantity.present
          ? data.actualQuantity.value
          : this.actualQuantity,
      actualCalories: data.actualCalories.present
          ? data.actualCalories.value
          : this.actualCalories,
      eaten: data.eaten.present ? data.eaten.value : this.eaten,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('plannedQuantity: $plannedQuantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('plannedCalories: $plannedCalories, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('actualCalories: $actualCalories, ')
          ..write('eaten: $eaten, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    meal,
    foodName,
    plannedQuantity,
    quantityUnit,
    plannedCalories,
    actualQuantity,
    actualCalories,
    eaten,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.foodName == this.foodName &&
          other.plannedQuantity == this.plannedQuantity &&
          other.quantityUnit == this.quantityUnit &&
          other.plannedCalories == this.plannedCalories &&
          other.actualQuantity == this.actualQuantity &&
          other.actualCalories == this.actualCalories &&
          other.eaten == this.eaten &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DietEntriesCompanion extends UpdateCompanion<DietEntry> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String> meal;
  final Value<String> foodName;
  final Value<double> plannedQuantity;
  final Value<String> quantityUnit;
  final Value<double> plannedCalories;
  final Value<double> actualQuantity;
  final Value<double> actualCalories;
  final Value<bool> eaten;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DietEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodName = const Value.absent(),
    this.plannedQuantity = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.plannedCalories = const Value.absent(),
    this.actualQuantity = const Value.absent(),
    this.actualCalories = const Value.absent(),
    this.eaten = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DietEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required DateTime date,
    required String meal,
    required String foodName,
    required double plannedQuantity,
    required String quantityUnit,
    required double plannedCalories,
    this.actualQuantity = const Value.absent(),
    this.actualCalories = const Value.absent(),
    this.eaten = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       date = Value(date),
       meal = Value(meal),
       foodName = Value(foodName),
       plannedQuantity = Value(plannedQuantity),
       quantityUnit = Value(quantityUnit),
       plannedCalories = Value(plannedCalories),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DietEntry> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? meal,
    Expression<String>? foodName,
    Expression<double>? plannedQuantity,
    Expression<String>? quantityUnit,
    Expression<double>? plannedCalories,
    Expression<double>? actualQuantity,
    Expression<double>? actualCalories,
    Expression<bool>? eaten,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (foodName != null) 'food_name': foodName,
      if (plannedQuantity != null) 'planned_quantity': plannedQuantity,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (plannedCalories != null) 'planned_calories': plannedCalories,
      if (actualQuantity != null) 'actual_quantity': actualQuantity,
      if (actualCalories != null) 'actual_calories': actualCalories,
      if (eaten != null) 'eaten': eaten,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DietEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String>? meal,
    Value<String>? foodName,
    Value<double>? plannedQuantity,
    Value<String>? quantityUnit,
    Value<double>? plannedCalories,
    Value<double>? actualQuantity,
    Value<double>? actualCalories,
    Value<bool>? eaten,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DietEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      foodName: foodName ?? this.foodName,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      plannedCalories: plannedCalories ?? this.plannedCalories,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      actualCalories: actualCalories ?? this.actualCalories,
      eaten: eaten ?? this.eaten,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (plannedQuantity.present) {
      map['planned_quantity'] = Variable<double>(plannedQuantity.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (plannedCalories.present) {
      map['planned_calories'] = Variable<double>(plannedCalories.value);
    }
    if (actualQuantity.present) {
      map['actual_quantity'] = Variable<double>(actualQuantity.value);
    }
    if (actualCalories.present) {
      map['actual_calories'] = Variable<double>(actualCalories.value);
    }
    if (eaten.present) {
      map['eaten'] = Variable<bool>(eaten.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('plannedQuantity: $plannedQuantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('plannedCalories: $plannedCalories, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('actualCalories: $actualCalories, ')
          ..write('eaten: $eaten, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExtraCaloriesEntriesTable extends ExtraCaloriesEntries
    with TableInfo<$ExtraCaloriesEntriesTable, ExtraCaloriesEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtraCaloriesEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    calories,
    description,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extra_calories_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtraCaloriesEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtraCaloriesEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtraCaloriesEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExtraCaloriesEntriesTable createAlias(String alias) {
    return $ExtraCaloriesEntriesTable(attachedDatabase, alias);
  }
}

class ExtraCaloriesEntry extends DataClass
    implements Insertable<ExtraCaloriesEntry> {
  final int id;
  final String userId;
  final DateTime date;
  final double calories;
  final String description;
  final DateTime createdAt;
  const ExtraCaloriesEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.calories,
    required this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['calories'] = Variable<double>(calories);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExtraCaloriesEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExtraCaloriesEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      calories: Value(calories),
      description: Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory ExtraCaloriesEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtraCaloriesEntry(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      calories: serializer.fromJson<double>(json['calories']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'calories': serializer.toJson<double>(calories),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExtraCaloriesEntry copyWith({
    int? id,
    String? userId,
    DateTime? date,
    double? calories,
    String? description,
    DateTime? createdAt,
  }) => ExtraCaloriesEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    calories: calories ?? this.calories,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  ExtraCaloriesEntry copyWithCompanion(ExtraCaloriesEntriesCompanion data) {
    return ExtraCaloriesEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      calories: data.calories.present ? data.calories.value : this.calories,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtraCaloriesEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, date, calories, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtraCaloriesEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.calories == this.calories &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class ExtraCaloriesEntriesCompanion
    extends UpdateCompanion<ExtraCaloriesEntry> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<double> calories;
  final Value<String> description;
  final Value<DateTime> createdAt;
  const ExtraCaloriesEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.calories = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExtraCaloriesEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required DateTime date,
    required double calories,
    this.description = const Value.absent(),
    required DateTime createdAt,
  }) : userId = Value(userId),
       date = Value(date),
       calories = Value(calories),
       createdAt = Value(createdAt);
  static Insertable<ExtraCaloriesEntry> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<double>? calories,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (calories != null) 'calories': calories,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExtraCaloriesEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<double>? calories,
    Value<String>? description,
    Value<DateTime>? createdAt,
  }) {
    return ExtraCaloriesEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      calories: calories ?? this.calories,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtraCaloriesEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyTargetsTable extends DailyTargets
    with TableInfo<$DailyTargetsTable, DailyTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTargetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calorieTargetMeta = const VerificationMeta(
    'calorieTarget',
  );
  @override
  late final GeneratedColumn<double> calorieTarget = GeneratedColumn<double>(
    'calorie_target',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2500),
  );
  static const VerificationMeta _stepTargetMeta = const VerificationMeta(
    'stepTarget',
  );
  @override
  late final GeneratedColumn<int> stepTarget = GeneratedColumn<int>(
    'step_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    calorieTarget,
    stepTarget,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('calorie_target')) {
      context.handle(
        _calorieTargetMeta,
        calorieTarget.isAcceptableOrUnknown(
          data['calorie_target']!,
          _calorieTargetMeta,
        ),
      );
    }
    if (data.containsKey('step_target')) {
      context.handle(
        _stepTargetMeta,
        stepTarget.isAcceptableOrUnknown(data['step_target']!, _stepTargetMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      calorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calorie_target'],
      )!,
      stepTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_target'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyTargetsTable createAlias(String alias) {
    return $DailyTargetsTable(attachedDatabase, alias);
  }
}

class DailyTarget extends DataClass implements Insertable<DailyTarget> {
  final int id;
  final String userId;
  final double calorieTarget;
  final int stepTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyTarget({
    required this.id,
    required this.userId,
    required this.calorieTarget,
    required this.stepTarget,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['calorie_target'] = Variable<double>(calorieTarget);
    map['step_target'] = Variable<int>(stepTarget);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyTargetsCompanion toCompanion(bool nullToAbsent) {
    return DailyTargetsCompanion(
      id: Value(id),
      userId: Value(userId),
      calorieTarget: Value(calorieTarget),
      stepTarget: Value(stepTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTarget(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      calorieTarget: serializer.fromJson<double>(json['calorieTarget']),
      stepTarget: serializer.fromJson<int>(json['stepTarget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'calorieTarget': serializer.toJson<double>(calorieTarget),
      'stepTarget': serializer.toJson<int>(stepTarget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyTarget copyWith({
    int? id,
    String? userId,
    double? calorieTarget,
    int? stepTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyTarget(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    calorieTarget: calorieTarget ?? this.calorieTarget,
    stepTarget: stepTarget ?? this.stepTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyTarget copyWithCompanion(DailyTargetsCompanion data) {
    return DailyTarget(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      calorieTarget: data.calorieTarget.present
          ? data.calorieTarget.value
          : this.calorieTarget,
      stepTarget: data.stepTarget.present
          ? data.stepTarget.value
          : this.stepTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTarget(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('stepTarget: $stepTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, calorieTarget, stepTarget, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTarget &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.calorieTarget == this.calorieTarget &&
          other.stepTarget == this.stepTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyTargetsCompanion extends UpdateCompanion<DailyTarget> {
  final Value<int> id;
  final Value<String> userId;
  final Value<double> calorieTarget;
  final Value<int> stepTarget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyTargetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.stepTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyTargetsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.calorieTarget = const Value.absent(),
    this.stepTarget = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyTarget> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<double>? calorieTarget,
    Expression<int>? stepTarget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (calorieTarget != null) 'calorie_target': calorieTarget,
      if (stepTarget != null) 'step_target': stepTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyTargetsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<double>? calorieTarget,
    Value<int>? stepTarget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DailyTargetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      stepTarget: stepTarget ?? this.stepTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (calorieTarget.present) {
      map['calorie_target'] = Variable<double>(calorieTarget.value);
    }
    if (stepTarget.present) {
      map['step_target'] = Variable<int>(stepTarget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTargetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('stepTarget: $stepTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FoodLibraryTable extends FoodLibrary
    with TableInfo<$FoodLibraryTable, FoodLibraryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLibraryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultMealMeta = const VerificationMeta(
    'defaultMeal',
  );
  @override
  late final GeneratedColumn<String> defaultMeal = GeneratedColumn<String>(
    'default_meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    foodName,
    defaultMeal,
    quantity,
    quantityUnit,
    calories,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_library';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLibraryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('default_meal')) {
      context.handle(
        _defaultMealMeta,
        defaultMeal.isAcceptableOrUnknown(
          data['default_meal']!,
          _defaultMealMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultMealMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLibraryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLibraryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      defaultMeal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_meal'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodLibraryTable createAlias(String alias) {
    return $FoodLibraryTable(attachedDatabase, alias);
  }
}

class FoodLibraryData extends DataClass implements Insertable<FoodLibraryData> {
  final int id;
  final String userId;
  final String foodName;
  final String defaultMeal;
  final double quantity;
  final String quantityUnit;
  final double calories;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FoodLibraryData({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.defaultMeal,
    required this.quantity,
    required this.quantityUnit,
    required this.calories,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['food_name'] = Variable<String>(foodName);
    map['default_meal'] = Variable<String>(defaultMeal);
    map['quantity'] = Variable<double>(quantity);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    map['calories'] = Variable<double>(calories);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodLibraryCompanion toCompanion(bool nullToAbsent) {
    return FoodLibraryCompanion(
      id: Value(id),
      userId: Value(userId),
      foodName: Value(foodName),
      defaultMeal: Value(defaultMeal),
      quantity: Value(quantity),
      quantityUnit: Value(quantityUnit),
      calories: Value(calories),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoodLibraryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLibraryData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      defaultMeal: serializer.fromJson<String>(json['defaultMeal']),
      quantity: serializer.fromJson<double>(json['quantity']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      calories: serializer.fromJson<double>(json['calories']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'foodName': serializer.toJson<String>(foodName),
      'defaultMeal': serializer.toJson<String>(defaultMeal),
      'quantity': serializer.toJson<double>(quantity),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'calories': serializer.toJson<double>(calories),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FoodLibraryData copyWith({
    int? id,
    String? userId,
    String? foodName,
    String? defaultMeal,
    double? quantity,
    String? quantityUnit,
    double? calories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FoodLibraryData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    foodName: foodName ?? this.foodName,
    defaultMeal: defaultMeal ?? this.defaultMeal,
    quantity: quantity ?? this.quantity,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    calories: calories ?? this.calories,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FoodLibraryData copyWithCompanion(FoodLibraryCompanion data) {
    return FoodLibraryData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      defaultMeal: data.defaultMeal.present
          ? data.defaultMeal.value
          : this.defaultMeal,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      calories: data.calories.present ? data.calories.value : this.calories,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLibraryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('foodName: $foodName, ')
          ..write('defaultMeal: $defaultMeal, ')
          ..write('quantity: $quantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('calories: $calories, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    foodName,
    defaultMeal,
    quantity,
    quantityUnit,
    calories,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLibraryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.foodName == this.foodName &&
          other.defaultMeal == this.defaultMeal &&
          other.quantity == this.quantity &&
          other.quantityUnit == this.quantityUnit &&
          other.calories == this.calories &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodLibraryCompanion extends UpdateCompanion<FoodLibraryData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> foodName;
  final Value<String> defaultMeal;
  final Value<double> quantity;
  final Value<String> quantityUnit;
  final Value<double> calories;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FoodLibraryCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.defaultMeal = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.calories = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoodLibraryCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String foodName,
    required String defaultMeal,
    required double quantity,
    required String quantityUnit,
    required double calories,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       foodName = Value(foodName),
       defaultMeal = Value(defaultMeal),
       quantity = Value(quantity),
       quantityUnit = Value(quantityUnit),
       calories = Value(calories),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FoodLibraryData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? foodName,
    Expression<String>? defaultMeal,
    Expression<double>? quantity,
    Expression<String>? quantityUnit,
    Expression<double>? calories,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (foodName != null) 'food_name': foodName,
      if (defaultMeal != null) 'default_meal': defaultMeal,
      if (quantity != null) 'quantity': quantity,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (calories != null) 'calories': calories,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoodLibraryCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? foodName,
    Value<String>? defaultMeal,
    Value<double>? quantity,
    Value<String>? quantityUnit,
    Value<double>? calories,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FoodLibraryCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      defaultMeal: defaultMeal ?? this.defaultMeal,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (defaultMeal.present) {
      map['default_meal'] = Variable<String>(defaultMeal.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLibraryCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('foodName: $foodName, ')
          ..write('defaultMeal: $defaultMeal, ')
          ..write('quantity: $quantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('calories: $calories, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyDietPlansTable extends WeeklyDietPlans
    with TableInfo<$WeeklyDietPlansTable, WeeklyDietPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyDietPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCaloriesMeta = const VerificationMeta(
    'targetCalories',
  );
  @override
  late final GeneratedColumn<double> targetCalories = GeneratedColumn<double>(
    'target_calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2500),
  );
  static const VerificationMeta _targetProteinMeta = const VerificationMeta(
    'targetProtein',
  );
  @override
  late final GeneratedColumn<double> targetProtein = GeneratedColumn<double>(
    'target_protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    dayOfWeek,
    targetCalories,
    targetProtein,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_diet_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyDietPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('target_calories')) {
      context.handle(
        _targetCaloriesMeta,
        targetCalories.isAcceptableOrUnknown(
          data['target_calories']!,
          _targetCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('target_protein')) {
      context.handle(
        _targetProteinMeta,
        targetProtein.isAcceptableOrUnknown(
          data['target_protein']!,
          _targetProteinMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyDietPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyDietPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      targetCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_calories'],
      )!,
      targetProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_protein'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeeklyDietPlansTable createAlias(String alias) {
    return $WeeklyDietPlansTable(attachedDatabase, alias);
  }
}

class WeeklyDietPlan extends DataClass implements Insertable<WeeklyDietPlan> {
  final int id;
  final String userId;
  final int dayOfWeek;
  final double targetCalories;
  final double targetProtein;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyDietPlan({
    required this.id,
    required this.userId,
    required this.dayOfWeek,
    required this.targetCalories,
    required this.targetProtein,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['target_calories'] = Variable<double>(targetCalories);
    map['target_protein'] = Variable<double>(targetProtein);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklyDietPlansCompanion toCompanion(bool nullToAbsent) {
    return WeeklyDietPlansCompanion(
      id: Value(id),
      userId: Value(userId),
      dayOfWeek: Value(dayOfWeek),
      targetCalories: Value(targetCalories),
      targetProtein: Value(targetProtein),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklyDietPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyDietPlan(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      targetCalories: serializer.fromJson<double>(json['targetCalories']),
      targetProtein: serializer.fromJson<double>(json['targetProtein']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'targetCalories': serializer.toJson<double>(targetCalories),
      'targetProtein': serializer.toJson<double>(targetProtein),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyDietPlan copyWith({
    int? id,
    String? userId,
    int? dayOfWeek,
    double? targetCalories,
    double? targetProtein,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyDietPlan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    targetCalories: targetCalories ?? this.targetCalories,
    targetProtein: targetProtein ?? this.targetProtein,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyDietPlan copyWithCompanion(WeeklyDietPlansCompanion data) {
    return WeeklyDietPlan(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      targetCalories: data.targetCalories.present
          ? data.targetCalories.value
          : this.targetCalories,
      targetProtein: data.targetProtein.present
          ? data.targetProtein.value
          : this.targetProtein,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyDietPlan(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('targetProtein: $targetProtein, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    dayOfWeek,
    targetCalories,
    targetProtein,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyDietPlan &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.targetCalories == this.targetCalories &&
          other.targetProtein == this.targetProtein &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyDietPlansCompanion extends UpdateCompanion<WeeklyDietPlan> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> dayOfWeek;
  final Value<double> targetCalories;
  final Value<double> targetProtein;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeeklyDietPlansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.targetProtein = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklyDietPlansCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int dayOfWeek,
    this.targetCalories = const Value.absent(),
    this.targetProtein = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       dayOfWeek = Value(dayOfWeek),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyDietPlan> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? dayOfWeek,
    Expression<double>? targetCalories,
    Expression<double>? targetProtein,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (targetCalories != null) 'target_calories': targetCalories,
      if (targetProtein != null) 'target_protein': targetProtein,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklyDietPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? dayOfWeek,
    Value<double>? targetCalories,
    Value<double>? targetProtein,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklyDietPlansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (targetCalories.present) {
      map['target_calories'] = Variable<double>(targetCalories.value);
    }
    if (targetProtein.present) {
      map['target_protein'] = Variable<double>(targetProtein.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyDietPlansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('targetProtein: $targetProtein, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyDietItemsTable extends WeeklyDietItems
    with TableInfo<$WeeklyDietItemsTable, WeeklyDietItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyDietItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    meal,
    foodName,
    quantity,
    quantityUnit,
    calories,
    protein,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_diet_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyDietItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyDietItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyDietItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeeklyDietItemsTable createAlias(String alias) {
    return $WeeklyDietItemsTable(attachedDatabase, alias);
  }
}

class WeeklyDietItem extends DataClass implements Insertable<WeeklyDietItem> {
  final int id;
  final int planId;
  final String meal;
  final String foodName;
  final double quantity;
  final String quantityUnit;
  final double calories;
  final double protein;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyDietItem({
    required this.id,
    required this.planId,
    required this.meal,
    required this.foodName,
    required this.quantity,
    required this.quantityUnit,
    required this.calories,
    required this.protein,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['meal'] = Variable<String>(meal);
    map['food_name'] = Variable<String>(foodName);
    map['quantity'] = Variable<double>(quantity);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklyDietItemsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyDietItemsCompanion(
      id: Value(id),
      planId: Value(planId),
      meal: Value(meal),
      foodName: Value(foodName),
      quantity: Value(quantity),
      quantityUnit: Value(quantityUnit),
      calories: Value(calories),
      protein: Value(protein),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklyDietItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyDietItem(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      meal: serializer.fromJson<String>(json['meal']),
      foodName: serializer.fromJson<String>(json['foodName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'meal': serializer.toJson<String>(meal),
      'foodName': serializer.toJson<String>(foodName),
      'quantity': serializer.toJson<double>(quantity),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyDietItem copyWith({
    int? id,
    int? planId,
    String? meal,
    String? foodName,
    double? quantity,
    String? quantityUnit,
    double? calories,
    double? protein,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyDietItem(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    meal: meal ?? this.meal,
    foodName: foodName ?? this.foodName,
    quantity: quantity ?? this.quantity,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyDietItem copyWithCompanion(WeeklyDietItemsCompanion data) {
    return WeeklyDietItem(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyDietItem(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('quantity: $quantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    meal,
    foodName,
    quantity,
    quantityUnit,
    calories,
    protein,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyDietItem &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.meal == this.meal &&
          other.foodName == this.foodName &&
          other.quantity == this.quantity &&
          other.quantityUnit == this.quantityUnit &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyDietItemsCompanion extends UpdateCompanion<WeeklyDietItem> {
  final Value<int> id;
  final Value<int> planId;
  final Value<String> meal;
  final Value<String> foodName;
  final Value<double> quantity;
  final Value<String> quantityUnit;
  final Value<double> calories;
  final Value<double> protein;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeeklyDietItemsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklyDietItemsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required String meal,
    required String foodName,
    required double quantity,
    required String quantityUnit,
    required double calories,
    this.protein = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : planId = Value(planId),
       meal = Value(meal),
       foodName = Value(foodName),
       quantity = Value(quantity),
       quantityUnit = Value(quantityUnit),
       calories = Value(calories),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyDietItem> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<String>? meal,
    Expression<String>? foodName,
    Expression<double>? quantity,
    Expression<String>? quantityUnit,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (meal != null) 'meal': meal,
      if (foodName != null) 'food_name': foodName,
      if (quantity != null) 'quantity': quantity,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklyDietItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<String>? meal,
    Value<String>? foodName,
    Value<double>? quantity,
    Value<String>? quantityUnit,
    Value<double>? calories,
    Value<double>? protein,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklyDietItemsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      meal: meal ?? this.meal,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyDietItemsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('quantity: $quantity, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $ExerciseLibraryTable exerciseLibrary = $ExerciseLibraryTable(
    this,
  );
  late final $WorkoutRoutinesTable workoutRoutines = $WorkoutRoutinesTable(
    this,
  );
  late final $RoutineSetsTable routineSets = $RoutineSetsTable(this);
  late final $DailyDataTable dailyData = $DailyDataTable(this);
  late final $DietEntriesTable dietEntries = $DietEntriesTable(this);
  late final $ExtraCaloriesEntriesTable extraCaloriesEntries =
      $ExtraCaloriesEntriesTable(this);
  late final $DailyTargetsTable dailyTargets = $DailyTargetsTable(this);
  late final $FoodLibraryTable foodLibrary = $FoodLibraryTable(this);
  late final $WeeklyDietPlansTable weeklyDietPlans = $WeeklyDietPlansTable(
    this,
  );
  late final $WeeklyDietItemsTable weeklyDietItems = $WeeklyDietItemsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workoutSets,
    exerciseLibrary,
    workoutRoutines,
    routineSets,
    dailyData,
    dietEntries,
    extraCaloriesEntries,
    dailyTargets,
    foodLibrary,
    weeklyDietPlans,
    weeklyDietItems,
  ];
}

typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      required String userId,
      required String exerciseName,
      required double weight,
      required int reps,
      required DateTime date,
      required DateTime createdAt,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> exerciseName,
      Value<double> weight,
      Value<int> reps,
      Value<DateTime> date,
      Value<DateTime> createdAt,
    });

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (
            WorkoutSet,
            BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet>,
          ),
          WorkoutSet,
          PrefetchHooks Function()
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                userId: userId,
                exerciseName: exerciseName,
                weight: weight,
                reps: reps,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String exerciseName,
                required double weight,
                required int reps,
                required DateTime date,
                required DateTime createdAt,
              }) => WorkoutSetsCompanion.insert(
                id: id,
                userId: userId,
                exerciseName: exerciseName,
                weight: weight,
                reps: reps,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSetsTable, WorkoutSet>(table),
                  BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet>(
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

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (
        WorkoutSet,
        BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet>,
      ),
      WorkoutSet,
      PrefetchHooks Function()
    >;
typedef $$ExerciseLibraryTableCreateCompanionBuilder =
    ExerciseLibraryCompanion Function({
      Value<int> id,
      required String userId,
      required String exerciseName,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ExerciseLibraryTableUpdateCompanionBuilder =
    ExerciseLibraryCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> exerciseName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ExerciseLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseLibraryTable> {
  $$ExerciseLibraryTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseLibraryTable> {
  $$ExerciseLibraryTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseLibraryTable> {
  $$ExerciseLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExerciseLibraryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseLibraryTable,
          ExerciseLibraryData,
          $$ExerciseLibraryTableFilterComposer,
          $$ExerciseLibraryTableOrderingComposer,
          $$ExerciseLibraryTableAnnotationComposer,
          $$ExerciseLibraryTableCreateCompanionBuilder,
          $$ExerciseLibraryTableUpdateCompanionBuilder,
          (
            ExerciseLibraryData,
            BaseReferences<
              _$AppDatabase,
              $ExerciseLibraryTable,
              ExerciseLibraryData
            >,
          ),
          ExerciseLibraryData,
          PrefetchHooks Function()
        > {
  $$ExerciseLibraryTableTableManager(
    _$AppDatabase db,
    $ExerciseLibraryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExerciseLibraryCompanion(
                id: id,
                userId: userId,
                exerciseName: exerciseName,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String exerciseName,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ExerciseLibraryCompanion.insert(
                id: id,
                userId: userId,
                exerciseName: exerciseName,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseLibraryTable, ExerciseLibraryData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ExerciseLibraryTable,
                    ExerciseLibraryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseLibraryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseLibraryTable,
      ExerciseLibraryData,
      $$ExerciseLibraryTableFilterComposer,
      $$ExerciseLibraryTableOrderingComposer,
      $$ExerciseLibraryTableAnnotationComposer,
      $$ExerciseLibraryTableCreateCompanionBuilder,
      $$ExerciseLibraryTableUpdateCompanionBuilder,
      (
        ExerciseLibraryData,
        BaseReferences<
          _$AppDatabase,
          $ExerciseLibraryTable,
          ExerciseLibraryData
        >,
      ),
      ExerciseLibraryData,
      PrefetchHooks Function()
    >;
typedef $$WorkoutRoutinesTableCreateCompanionBuilder =
    WorkoutRoutinesCompanion Function({
      Value<int> id,
      required String userId,
      required DateTime date,
      required String routineName,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WorkoutRoutinesTableUpdateCompanionBuilder =
    WorkoutRoutinesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String> routineName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WorkoutRoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutRoutinesTable> {
  $$WorkoutRoutinesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutRoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutRoutinesTable> {
  $$WorkoutRoutinesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutRoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutRoutinesTable> {
  $$WorkoutRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkoutRoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutRoutinesTable,
          WorkoutRoutine,
          $$WorkoutRoutinesTableFilterComposer,
          $$WorkoutRoutinesTableOrderingComposer,
          $$WorkoutRoutinesTableAnnotationComposer,
          $$WorkoutRoutinesTableCreateCompanionBuilder,
          $$WorkoutRoutinesTableUpdateCompanionBuilder,
          (
            WorkoutRoutine,
            BaseReferences<
              _$AppDatabase,
              $WorkoutRoutinesTable,
              WorkoutRoutine
            >,
          ),
          WorkoutRoutine,
          PrefetchHooks Function()
        > {
  $$WorkoutRoutinesTableTableManager(
    _$AppDatabase db,
    $WorkoutRoutinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> routineName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutRoutinesCompanion(
                id: id,
                userId: userId,
                date: date,
                routineName: routineName,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required DateTime date,
                required String routineName,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WorkoutRoutinesCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                routineName: routineName,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutRoutinesTable, WorkoutRoutine>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutRoutinesTable,
                    WorkoutRoutine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutRoutinesTable,
      WorkoutRoutine,
      $$WorkoutRoutinesTableFilterComposer,
      $$WorkoutRoutinesTableOrderingComposer,
      $$WorkoutRoutinesTableAnnotationComposer,
      $$WorkoutRoutinesTableCreateCompanionBuilder,
      $$WorkoutRoutinesTableUpdateCompanionBuilder,
      (
        WorkoutRoutine,
        BaseReferences<_$AppDatabase, $WorkoutRoutinesTable, WorkoutRoutine>,
      ),
      WorkoutRoutine,
      PrefetchHooks Function()
    >;
typedef $$RoutineSetsTableCreateCompanionBuilder =
    RoutineSetsCompanion Function({
      Value<int> id,
      required int routineId,
      required String exerciseName,
      required int setNumber,
      required double weight,
      required int reps,
    });
typedef $$RoutineSetsTableUpdateCompanionBuilder =
    RoutineSetsCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<String> exerciseName,
      Value<int> setNumber,
      Value<double> weight,
      Value<int> reps,
    });

class $$RoutineSetsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableFilterComposer({
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

  ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableOrderingComposer({
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

  ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);
}

class $$RoutineSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineSetsTable,
          RoutineSet,
          $$RoutineSetsTableFilterComposer,
          $$RoutineSetsTableOrderingComposer,
          $$RoutineSetsTableAnnotationComposer,
          $$RoutineSetsTableCreateCompanionBuilder,
          $$RoutineSetsTableUpdateCompanionBuilder,
          (
            RoutineSet,
            BaseReferences<_$AppDatabase, $RoutineSetsTable, RoutineSet>,
          ),
          RoutineSet,
          PrefetchHooks Function()
        > {
  $$RoutineSetsTableTableManager(_$AppDatabase db, $RoutineSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
              }) => RoutineSetsCompanion(
                id: id,
                routineId: routineId,
                exerciseName: exerciseName,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                required String exerciseName,
                required int setNumber,
                required double weight,
                required int reps,
              }) => RoutineSetsCompanion.insert(
                id: id,
                routineId: routineId,
                exerciseName: exerciseName,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineSetsTable, RoutineSet>(table),
                  BaseReferences<_$AppDatabase, $RoutineSetsTable, RoutineSet>(
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

typedef $$RoutineSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineSetsTable,
      RoutineSet,
      $$RoutineSetsTableFilterComposer,
      $$RoutineSetsTableOrderingComposer,
      $$RoutineSetsTableAnnotationComposer,
      $$RoutineSetsTableCreateCompanionBuilder,
      $$RoutineSetsTableUpdateCompanionBuilder,
      (
        RoutineSet,
        BaseReferences<_$AppDatabase, $RoutineSetsTable, RoutineSet>,
      ),
      RoutineSet,
      PrefetchHooks Function()
    >;
typedef $$DailyDataTableCreateCompanionBuilder =
    DailyDataCompanion Function({
      Value<int> id,
      required String userId,
      required DateTime date,
      Value<double> calories,
      Value<double> calorieTarget,
      Value<int> steps,
      Value<int> stepTarget,
      Value<double> recoveryScore,
      Value<double> effortScore,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DailyDataTableUpdateCompanionBuilder =
    DailyDataCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<double> calories,
      Value<double> calorieTarget,
      Value<int> steps,
      Value<int> stepTarget,
      Value<double> recoveryScore,
      Value<double> effortScore,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DailyDataTableFilterComposer
    extends Composer<_$AppDatabase, $DailyDataTable> {
  $$DailyDataTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effortScore => $composableBuilder(
    column: $table.effortScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyDataTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyDataTable> {
  $$DailyDataTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effortScore => $composableBuilder(
    column: $table.effortScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyDataTable> {
  $$DailyDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effortScore => $composableBuilder(
    column: $table.effortScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyDataTable,
          DailyDataData,
          $$DailyDataTableFilterComposer,
          $$DailyDataTableOrderingComposer,
          $$DailyDataTableAnnotationComposer,
          $$DailyDataTableCreateCompanionBuilder,
          $$DailyDataTableUpdateCompanionBuilder,
          (
            DailyDataData,
            BaseReferences<_$AppDatabase, $DailyDataTable, DailyDataData>,
          ),
          DailyDataData,
          PrefetchHooks Function()
        > {
  $$DailyDataTableTableManager(_$AppDatabase db, $DailyDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> calorieTarget = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> stepTarget = const Value.absent(),
                Value<double> recoveryScore = const Value.absent(),
                Value<double> effortScore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyDataCompanion(
                id: id,
                userId: userId,
                date: date,
                calories: calories,
                calorieTarget: calorieTarget,
                steps: steps,
                stepTarget: stepTarget,
                recoveryScore: recoveryScore,
                effortScore: effortScore,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required DateTime date,
                Value<double> calories = const Value.absent(),
                Value<double> calorieTarget = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> stepTarget = const Value.absent(),
                Value<double> recoveryScore = const Value.absent(),
                Value<double> effortScore = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DailyDataCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                calories: calories,
                calorieTarget: calorieTarget,
                steps: steps,
                stepTarget: stepTarget,
                recoveryScore: recoveryScore,
                effortScore: effortScore,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyDataTable, DailyDataData>(table),
                  BaseReferences<_$AppDatabase, $DailyDataTable, DailyDataData>(
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

typedef $$DailyDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyDataTable,
      DailyDataData,
      $$DailyDataTableFilterComposer,
      $$DailyDataTableOrderingComposer,
      $$DailyDataTableAnnotationComposer,
      $$DailyDataTableCreateCompanionBuilder,
      $$DailyDataTableUpdateCompanionBuilder,
      (
        DailyDataData,
        BaseReferences<_$AppDatabase, $DailyDataTable, DailyDataData>,
      ),
      DailyDataData,
      PrefetchHooks Function()
    >;
typedef $$DietEntriesTableCreateCompanionBuilder =
    DietEntriesCompanion Function({
      Value<int> id,
      required String userId,
      required DateTime date,
      required String meal,
      required String foodName,
      required double plannedQuantity,
      required String quantityUnit,
      required double plannedCalories,
      Value<double> actualQuantity,
      Value<double> actualCalories,
      Value<bool> eaten,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DietEntriesTableUpdateCompanionBuilder =
    DietEntriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String> meal,
      Value<String> foodName,
      Value<double> plannedQuantity,
      Value<String> quantityUnit,
      Value<double> plannedCalories,
      Value<double> actualQuantity,
      Value<double> actualCalories,
      Value<bool> eaten,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DietEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DietEntriesTable> {
  $$DietEntriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedQuantity => $composableBuilder(
    column: $table.plannedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedCalories => $composableBuilder(
    column: $table.plannedCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualQuantity => $composableBuilder(
    column: $table.actualQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualCalories => $composableBuilder(
    column: $table.actualCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get eaten => $composableBuilder(
    column: $table.eaten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DietEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DietEntriesTable> {
  $$DietEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedQuantity => $composableBuilder(
    column: $table.plannedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedCalories => $composableBuilder(
    column: $table.plannedCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualQuantity => $composableBuilder(
    column: $table.actualQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualCalories => $composableBuilder(
    column: $table.actualCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get eaten => $composableBuilder(
    column: $table.eaten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DietEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietEntriesTable> {
  $$DietEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<double> get plannedQuantity => $composableBuilder(
    column: $table.plannedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedCalories => $composableBuilder(
    column: $table.plannedCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualQuantity => $composableBuilder(
    column: $table.actualQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualCalories => $composableBuilder(
    column: $table.actualCalories,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get eaten =>
      $composableBuilder(column: $table.eaten, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DietEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietEntriesTable,
          DietEntry,
          $$DietEntriesTableFilterComposer,
          $$DietEntriesTableOrderingComposer,
          $$DietEntriesTableAnnotationComposer,
          $$DietEntriesTableCreateCompanionBuilder,
          $$DietEntriesTableUpdateCompanionBuilder,
          (
            DietEntry,
            BaseReferences<_$AppDatabase, $DietEntriesTable, DietEntry>,
          ),
          DietEntry,
          PrefetchHooks Function()
        > {
  $$DietEntriesTableTableManager(_$AppDatabase db, $DietEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<double> plannedQuantity = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double> plannedCalories = const Value.absent(),
                Value<double> actualQuantity = const Value.absent(),
                Value<double> actualCalories = const Value.absent(),
                Value<bool> eaten = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DietEntriesCompanion(
                id: id,
                userId: userId,
                date: date,
                meal: meal,
                foodName: foodName,
                plannedQuantity: plannedQuantity,
                quantityUnit: quantityUnit,
                plannedCalories: plannedCalories,
                actualQuantity: actualQuantity,
                actualCalories: actualCalories,
                eaten: eaten,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required DateTime date,
                required String meal,
                required String foodName,
                required double plannedQuantity,
                required String quantityUnit,
                required double plannedCalories,
                Value<double> actualQuantity = const Value.absent(),
                Value<double> actualCalories = const Value.absent(),
                Value<bool> eaten = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DietEntriesCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                meal: meal,
                foodName: foodName,
                plannedQuantity: plannedQuantity,
                quantityUnit: quantityUnit,
                plannedCalories: plannedCalories,
                actualQuantity: actualQuantity,
                actualCalories: actualCalories,
                eaten: eaten,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DietEntriesTable, DietEntry>(table),
                  BaseReferences<_$AppDatabase, $DietEntriesTable, DietEntry>(
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

typedef $$DietEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietEntriesTable,
      DietEntry,
      $$DietEntriesTableFilterComposer,
      $$DietEntriesTableOrderingComposer,
      $$DietEntriesTableAnnotationComposer,
      $$DietEntriesTableCreateCompanionBuilder,
      $$DietEntriesTableUpdateCompanionBuilder,
      (DietEntry, BaseReferences<_$AppDatabase, $DietEntriesTable, DietEntry>),
      DietEntry,
      PrefetchHooks Function()
    >;
typedef $$ExtraCaloriesEntriesTableCreateCompanionBuilder =
    ExtraCaloriesEntriesCompanion Function({
      Value<int> id,
      required String userId,
      required DateTime date,
      required double calories,
      Value<String> description,
      required DateTime createdAt,
    });
typedef $$ExtraCaloriesEntriesTableUpdateCompanionBuilder =
    ExtraCaloriesEntriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<double> calories,
      Value<String> description,
      Value<DateTime> createdAt,
    });

class $$ExtraCaloriesEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExtraCaloriesEntriesTable> {
  $$ExtraCaloriesEntriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtraCaloriesEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExtraCaloriesEntriesTable> {
  $$ExtraCaloriesEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtraCaloriesEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExtraCaloriesEntriesTable> {
  $$ExtraCaloriesEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExtraCaloriesEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExtraCaloriesEntriesTable,
          ExtraCaloriesEntry,
          $$ExtraCaloriesEntriesTableFilterComposer,
          $$ExtraCaloriesEntriesTableOrderingComposer,
          $$ExtraCaloriesEntriesTableAnnotationComposer,
          $$ExtraCaloriesEntriesTableCreateCompanionBuilder,
          $$ExtraCaloriesEntriesTableUpdateCompanionBuilder,
          (
            ExtraCaloriesEntry,
            BaseReferences<
              _$AppDatabase,
              $ExtraCaloriesEntriesTable,
              ExtraCaloriesEntry
            >,
          ),
          ExtraCaloriesEntry,
          PrefetchHooks Function()
        > {
  $$ExtraCaloriesEntriesTableTableManager(
    _$AppDatabase db,
    $ExtraCaloriesEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtraCaloriesEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtraCaloriesEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExtraCaloriesEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExtraCaloriesEntriesCompanion(
                id: id,
                userId: userId,
                date: date,
                calories: calories,
                description: description,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required DateTime date,
                required double calories,
                Value<String> description = const Value.absent(),
                required DateTime createdAt,
              }) => ExtraCaloriesEntriesCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                calories: calories,
                description: description,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtraCaloriesEntriesTable, ExtraCaloriesEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ExtraCaloriesEntriesTable,
                    ExtraCaloriesEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtraCaloriesEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExtraCaloriesEntriesTable,
      ExtraCaloriesEntry,
      $$ExtraCaloriesEntriesTableFilterComposer,
      $$ExtraCaloriesEntriesTableOrderingComposer,
      $$ExtraCaloriesEntriesTableAnnotationComposer,
      $$ExtraCaloriesEntriesTableCreateCompanionBuilder,
      $$ExtraCaloriesEntriesTableUpdateCompanionBuilder,
      (
        ExtraCaloriesEntry,
        BaseReferences<
          _$AppDatabase,
          $ExtraCaloriesEntriesTable,
          ExtraCaloriesEntry
        >,
      ),
      ExtraCaloriesEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyTargetsTableCreateCompanionBuilder =
    DailyTargetsCompanion Function({
      Value<int> id,
      required String userId,
      Value<double> calorieTarget,
      Value<int> stepTarget,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DailyTargetsTableUpdateCompanionBuilder =
    DailyTargetsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<double> calorieTarget,
      Value<int> stepTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DailyTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTargetsTable> {
  $$DailyTargetsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTargetsTable> {
  $$DailyTargetsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTargetsTable> {
  $$DailyTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stepTarget => $composableBuilder(
    column: $table.stepTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyTargetsTable,
          DailyTarget,
          $$DailyTargetsTableFilterComposer,
          $$DailyTargetsTableOrderingComposer,
          $$DailyTargetsTableAnnotationComposer,
          $$DailyTargetsTableCreateCompanionBuilder,
          $$DailyTargetsTableUpdateCompanionBuilder,
          (
            DailyTarget,
            BaseReferences<_$AppDatabase, $DailyTargetsTable, DailyTarget>,
          ),
          DailyTarget,
          PrefetchHooks Function()
        > {
  $$DailyTargetsTableTableManager(_$AppDatabase db, $DailyTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> calorieTarget = const Value.absent(),
                Value<int> stepTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyTargetsCompanion(
                id: id,
                userId: userId,
                calorieTarget: calorieTarget,
                stepTarget: stepTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                Value<double> calorieTarget = const Value.absent(),
                Value<int> stepTarget = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DailyTargetsCompanion.insert(
                id: id,
                userId: userId,
                calorieTarget: calorieTarget,
                stepTarget: stepTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyTargetsTable, DailyTarget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyTargetsTable,
                    DailyTarget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyTargetsTable,
      DailyTarget,
      $$DailyTargetsTableFilterComposer,
      $$DailyTargetsTableOrderingComposer,
      $$DailyTargetsTableAnnotationComposer,
      $$DailyTargetsTableCreateCompanionBuilder,
      $$DailyTargetsTableUpdateCompanionBuilder,
      (
        DailyTarget,
        BaseReferences<_$AppDatabase, $DailyTargetsTable, DailyTarget>,
      ),
      DailyTarget,
      PrefetchHooks Function()
    >;
typedef $$FoodLibraryTableCreateCompanionBuilder =
    FoodLibraryCompanion Function({
      Value<int> id,
      required String userId,
      required String foodName,
      required String defaultMeal,
      required double quantity,
      required String quantityUnit,
      required double calories,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FoodLibraryTableUpdateCompanionBuilder =
    FoodLibraryCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> foodName,
      Value<String> defaultMeal,
      Value<double> quantity,
      Value<String> quantityUnit,
      Value<double> calories,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FoodLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLibraryTable> {
  $$FoodLibraryTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultMeal => $composableBuilder(
    column: $table.defaultMeal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLibraryTable> {
  $$FoodLibraryTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultMeal => $composableBuilder(
    column: $table.defaultMeal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLibraryTable> {
  $$FoodLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get defaultMeal => $composableBuilder(
    column: $table.defaultMeal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoodLibraryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLibraryTable,
          FoodLibraryData,
          $$FoodLibraryTableFilterComposer,
          $$FoodLibraryTableOrderingComposer,
          $$FoodLibraryTableAnnotationComposer,
          $$FoodLibraryTableCreateCompanionBuilder,
          $$FoodLibraryTableUpdateCompanionBuilder,
          (
            FoodLibraryData,
            BaseReferences<_$AppDatabase, $FoodLibraryTable, FoodLibraryData>,
          ),
          FoodLibraryData,
          PrefetchHooks Function()
        > {
  $$FoodLibraryTableTableManager(_$AppDatabase db, $FoodLibraryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> defaultMeal = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodLibraryCompanion(
                id: id,
                userId: userId,
                foodName: foodName,
                defaultMeal: defaultMeal,
                quantity: quantity,
                quantityUnit: quantityUnit,
                calories: calories,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String foodName,
                required String defaultMeal,
                required double quantity,
                required String quantityUnit,
                required double calories,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FoodLibraryCompanion.insert(
                id: id,
                userId: userId,
                foodName: foodName,
                defaultMeal: defaultMeal,
                quantity: quantity,
                quantityUnit: quantityUnit,
                calories: calories,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodLibraryTable, FoodLibraryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FoodLibraryTable,
                    FoodLibraryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLibraryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLibraryTable,
      FoodLibraryData,
      $$FoodLibraryTableFilterComposer,
      $$FoodLibraryTableOrderingComposer,
      $$FoodLibraryTableAnnotationComposer,
      $$FoodLibraryTableCreateCompanionBuilder,
      $$FoodLibraryTableUpdateCompanionBuilder,
      (
        FoodLibraryData,
        BaseReferences<_$AppDatabase, $FoodLibraryTable, FoodLibraryData>,
      ),
      FoodLibraryData,
      PrefetchHooks Function()
    >;
typedef $$WeeklyDietPlansTableCreateCompanionBuilder =
    WeeklyDietPlansCompanion Function({
      Value<int> id,
      required String userId,
      required int dayOfWeek,
      Value<double> targetCalories,
      Value<double> targetProtein,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WeeklyDietPlansTableUpdateCompanionBuilder =
    WeeklyDietPlansCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> dayOfWeek,
      Value<double> targetCalories,
      Value<double> targetProtein,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WeeklyDietPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyDietPlansTable> {
  $$WeeklyDietPlansTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetProtein => $composableBuilder(
    column: $table.targetProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyDietPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyDietPlansTable> {
  $$WeeklyDietPlansTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetProtein => $composableBuilder(
    column: $table.targetProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyDietPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyDietPlansTable> {
  $$WeeklyDietPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<double> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetProtein => $composableBuilder(
    column: $table.targetProtein,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeeklyDietPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyDietPlansTable,
          WeeklyDietPlan,
          $$WeeklyDietPlansTableFilterComposer,
          $$WeeklyDietPlansTableOrderingComposer,
          $$WeeklyDietPlansTableAnnotationComposer,
          $$WeeklyDietPlansTableCreateCompanionBuilder,
          $$WeeklyDietPlansTableUpdateCompanionBuilder,
          (
            WeeklyDietPlan,
            BaseReferences<
              _$AppDatabase,
              $WeeklyDietPlansTable,
              WeeklyDietPlan
            >,
          ),
          WeeklyDietPlan,
          PrefetchHooks Function()
        > {
  $$WeeklyDietPlansTableTableManager(
    _$AppDatabase db,
    $WeeklyDietPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyDietPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyDietPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyDietPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<double> targetCalories = const Value.absent(),
                Value<double> targetProtein = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklyDietPlansCompanion(
                id: id,
                userId: userId,
                dayOfWeek: dayOfWeek,
                targetCalories: targetCalories,
                targetProtein: targetProtein,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int dayOfWeek,
                Value<double> targetCalories = const Value.absent(),
                Value<double> targetProtein = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WeeklyDietPlansCompanion.insert(
                id: id,
                userId: userId,
                dayOfWeek: dayOfWeek,
                targetCalories: targetCalories,
                targetProtein: targetProtein,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyDietPlansTable, WeeklyDietPlan>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeeklyDietPlansTable,
                    WeeklyDietPlan
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyDietPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyDietPlansTable,
      WeeklyDietPlan,
      $$WeeklyDietPlansTableFilterComposer,
      $$WeeklyDietPlansTableOrderingComposer,
      $$WeeklyDietPlansTableAnnotationComposer,
      $$WeeklyDietPlansTableCreateCompanionBuilder,
      $$WeeklyDietPlansTableUpdateCompanionBuilder,
      (
        WeeklyDietPlan,
        BaseReferences<_$AppDatabase, $WeeklyDietPlansTable, WeeklyDietPlan>,
      ),
      WeeklyDietPlan,
      PrefetchHooks Function()
    >;
typedef $$WeeklyDietItemsTableCreateCompanionBuilder =
    WeeklyDietItemsCompanion Function({
      Value<int> id,
      required int planId,
      required String meal,
      required String foodName,
      required double quantity,
      required String quantityUnit,
      required double calories,
      Value<double> protein,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WeeklyDietItemsTableUpdateCompanionBuilder =
    WeeklyDietItemsCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<String> meal,
      Value<String> foodName,
      Value<double> quantity,
      Value<String> quantityUnit,
      Value<double> calories,
      Value<double> protein,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WeeklyDietItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyDietItemsTable> {
  $$WeeklyDietItemsTableFilterComposer({
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

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyDietItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyDietItemsTable> {
  $$WeeklyDietItemsTableOrderingComposer({
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

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyDietItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyDietItemsTable> {
  $$WeeklyDietItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeeklyDietItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyDietItemsTable,
          WeeklyDietItem,
          $$WeeklyDietItemsTableFilterComposer,
          $$WeeklyDietItemsTableOrderingComposer,
          $$WeeklyDietItemsTableAnnotationComposer,
          $$WeeklyDietItemsTableCreateCompanionBuilder,
          $$WeeklyDietItemsTableUpdateCompanionBuilder,
          (
            WeeklyDietItem,
            BaseReferences<
              _$AppDatabase,
              $WeeklyDietItemsTable,
              WeeklyDietItem
            >,
          ),
          WeeklyDietItem,
          PrefetchHooks Function()
        > {
  $$WeeklyDietItemsTableTableManager(
    _$AppDatabase db,
    $WeeklyDietItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyDietItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyDietItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyDietItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklyDietItemsCompanion(
                id: id,
                planId: planId,
                meal: meal,
                foodName: foodName,
                quantity: quantity,
                quantityUnit: quantityUnit,
                calories: calories,
                protein: protein,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required String meal,
                required String foodName,
                required double quantity,
                required String quantityUnit,
                required double calories,
                Value<double> protein = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WeeklyDietItemsCompanion.insert(
                id: id,
                planId: planId,
                meal: meal,
                foodName: foodName,
                quantity: quantity,
                quantityUnit: quantityUnit,
                calories: calories,
                protein: protein,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyDietItemsTable, WeeklyDietItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeeklyDietItemsTable,
                    WeeklyDietItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyDietItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyDietItemsTable,
      WeeklyDietItem,
      $$WeeklyDietItemsTableFilterComposer,
      $$WeeklyDietItemsTableOrderingComposer,
      $$WeeklyDietItemsTableAnnotationComposer,
      $$WeeklyDietItemsTableCreateCompanionBuilder,
      $$WeeklyDietItemsTableUpdateCompanionBuilder,
      (
        WeeklyDietItem,
        BaseReferences<_$AppDatabase, $WeeklyDietItemsTable, WeeklyDietItem>,
      ),
      WeeklyDietItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$ExerciseLibraryTableTableManager get exerciseLibrary =>
      $$ExerciseLibraryTableTableManager(_db, _db.exerciseLibrary);
  $$WorkoutRoutinesTableTableManager get workoutRoutines =>
      $$WorkoutRoutinesTableTableManager(_db, _db.workoutRoutines);
  $$RoutineSetsTableTableManager get routineSets =>
      $$RoutineSetsTableTableManager(_db, _db.routineSets);
  $$DailyDataTableTableManager get dailyData =>
      $$DailyDataTableTableManager(_db, _db.dailyData);
  $$DietEntriesTableTableManager get dietEntries =>
      $$DietEntriesTableTableManager(_db, _db.dietEntries);
  $$ExtraCaloriesEntriesTableTableManager get extraCaloriesEntries =>
      $$ExtraCaloriesEntriesTableTableManager(_db, _db.extraCaloriesEntries);
  $$DailyTargetsTableTableManager get dailyTargets =>
      $$DailyTargetsTableTableManager(_db, _db.dailyTargets);
  $$FoodLibraryTableTableManager get foodLibrary =>
      $$FoodLibraryTableTableManager(_db, _db.foodLibrary);
  $$WeeklyDietPlansTableTableManager get weeklyDietPlans =>
      $$WeeklyDietPlansTableTableManager(_db, _db.weeklyDietPlans);
  $$WeeklyDietItemsTableTableManager get weeklyDietItems =>
      $$WeeklyDietItemsTableTableManager(_db, _db.weeklyDietItems);
}
