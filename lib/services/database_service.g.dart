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
    defaultValue: const Constant(0),
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
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    sleepHours,
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
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
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
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
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
  final double sleepHours;
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
    required this.sleepHours,
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
    map['sleep_hours'] = Variable<double>(sleepHours);
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
      sleepHours: Value(sleepHours),
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
      sleepHours: serializer.fromJson<double>(json['sleepHours']),
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
      'sleepHours': serializer.toJson<double>(sleepHours),
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
    double? sleepHours,
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
    sleepHours: sleepHours ?? this.sleepHours,
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
      sleepHours: data.sleepHours.present
          ? data.sleepHours.value
          : this.sleepHours,
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
          ..write('sleepHours: $sleepHours, ')
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
    sleepHours,
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
          other.sleepHours == this.sleepHours &&
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
  final Value<double> sleepHours;
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
    this.sleepHours = const Value.absent(),
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
    this.sleepHours = const Value.absent(),
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
    Expression<double>? sleepHours,
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
      if (sleepHours != null) 'sleep_hours': sleepHours,
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
    Value<double>? sleepHours,
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
      sleepHours: sleepHours ?? this.sleepHours,
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
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
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
          ..write('sleepHours: $sleepHours, ')
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    }
    if (data.containsKey('planned_calories')) {
      context.handle(
        _plannedCaloriesMeta,
        plannedCalories.isAcceptableOrUnknown(
          data['planned_calories']!,
          _plannedCaloriesMeta,
        ),
      );
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
    this.plannedQuantity = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.plannedCalories = const Value.absent(),
    this.actualQuantity = const Value.absent(),
    this.actualCalories = const Value.absent(),
    this.eaten = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       date = Value(date),
       meal = Value(meal),
       foodName = Value(foodName),
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $DailyDataTable dailyData = $DailyDataTable(this);
  late final $DietEntriesTable dietEntries = $DietEntriesTable(this);
  late final $ExtraCaloriesEntriesTable extraCaloriesEntries =
      $ExtraCaloriesEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workoutSets,
    dailyData,
    dietEntries,
    extraCaloriesEntries,
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
typedef $$DailyDataTableCreateCompanionBuilder =
    DailyDataCompanion Function({
      Value<int> id,
      required String userId,
      required DateTime date,
      Value<double> calories,
      Value<double> calorieTarget,
      Value<int> steps,
      Value<int> stepTarget,
      Value<double> sleepHours,
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
      Value<double> sleepHours,
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

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
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

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
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

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
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
                Value<double> sleepHours = const Value.absent(),
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
                sleepHours: sleepHours,
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
                Value<double> sleepHours = const Value.absent(),
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
                sleepHours: sleepHours,
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
      Value<double> plannedQuantity,
      Value<String> quantityUnit,
      Value<double> plannedCalories,
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
                Value<double> plannedQuantity = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double> plannedCalories = const Value.absent(),
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$DailyDataTableTableManager get dailyData =>
      $$DailyDataTableTableManager(_db, _db.dailyData);
  $$DietEntriesTableTableManager get dietEntries =>
      $$DietEntriesTableTableManager(_db, _db.dietEntries);
  $$ExtraCaloriesEntriesTableTableManager get extraCaloriesEntries =>
      $$ExtraCaloriesEntriesTableTableManager(_db, _db.extraCaloriesEntries);
}
