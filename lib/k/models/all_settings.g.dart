// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAllSettingsCollection on Isar {
  IsarCollection<AllSettings> get allSettings => this.collection();
}

const AllSettingsSchema = CollectionSchema(
  name: r'AllSettings',
  id: 7675443445704401613,
  properties: {
    r'playerName': PropertySchema(
      id: 0,
      name: r'playerName',
      type: IsarType.string,
    ),
    r'room': PropertySchema(
      id: 1,
      name: r'room',
      type: IsarType.long,
    )
  },
  estimateSize: _allSettingsEstimateSize,
  serialize: _allSettingsSerialize,
  deserialize: _allSettingsDeserialize,
  deserializeProp: _allSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _allSettingsGetId,
  getLinks: _allSettingsGetLinks,
  attach: _allSettingsAttach,
  version: '3.1.0+1',
);

int _allSettingsEstimateSize(
  AllSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.playerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _allSettingsSerialize(
  AllSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.playerName);
  writer.writeLong(offsets[1], object.room);
}

AllSettings _allSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AllSettings();
  object.id = id;
  object.playerName = reader.readStringOrNull(offsets[0]);
  object.room = reader.readLongOrNull(offsets[1]);
  return object;
}

P _allSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _allSettingsGetId(AllSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _allSettingsGetLinks(AllSettings object) {
  return [];
}

void _allSettingsAttach(
    IsarCollection<dynamic> col, Id id, AllSettings object) {
  object.id = id;
}

extension AllSettingsQueryWhereSort
    on QueryBuilder<AllSettings, AllSettings, QWhere> {
  QueryBuilder<AllSettings, AllSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AllSettingsQueryWhere
    on QueryBuilder<AllSettings, AllSettings, QWhereClause> {
  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AllSettingsQueryFilter
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {
  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playerName',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playerName',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      playerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'room',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
      roomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'room',
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'room',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'room',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'room',
        value: value,
      ));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'room',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AllSettingsQueryObject
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {}

extension AllSettingsQueryLinks
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {}

extension AllSettingsQuerySortBy
    on QueryBuilder<AllSettings, AllSettings, QSortBy> {
  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }
}

extension AllSettingsQuerySortThenBy
    on QueryBuilder<AllSettings, AllSettings, QSortThenBy> {
  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }
}

extension AllSettingsQueryWhereDistinct
    on QueryBuilder<AllSettings, AllSettings, QDistinct> {
  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByPlayerName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'room');
    });
  }
}

extension AllSettingsQueryProperty
    on QueryBuilder<AllSettings, AllSettings, QQueryProperty> {
  QueryBuilder<AllSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AllSettings, String?, QQueryOperations> playerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerName');
    });
  }

  QueryBuilder<AllSettings, int?, QQueryOperations> roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'room');
    });
  }
}
