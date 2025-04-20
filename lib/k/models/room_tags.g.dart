// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_tags.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoomTagsCollection on Isar {
  IsarCollection<RoomTags> get roomTags => this.collection();
}

const RoomTagsSchema = CollectionSchema(
  name: r'RoomTags',
  id: -6376976040501803162,
  properties: {
    r'selected': PropertySchema(
      id: 0,
      name: r'selected',
      type: IsarType.bool,
    ),
    r'tag': PropertySchema(
      id: 1,
      name: r'tag',
      type: IsarType.string,
    )
  },
  estimateSize: _roomTagsEstimateSize,
  serialize: _roomTagsSerialize,
  deserialize: _roomTagsDeserialize,
  deserializeProp: _roomTagsDeserializeProp,
  idName: r'id',
  indexes: {
    r'tag': IndexSchema(
      id: -8827799455852696894,
      name: r'tag',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'tag',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _roomTagsGetId,
  getLinks: _roomTagsGetLinks,
  attach: _roomTagsAttach,
  version: '3.1.0+1',
);

int _roomTagsEstimateSize(
  RoomTags object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.tag.length * 3;
  return bytesCount;
}

void _roomTagsSerialize(
  RoomTags object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.selected);
  writer.writeString(offsets[1], object.tag);
}

RoomTags _roomTagsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoomTags(
    reader.readString(offsets[1]),
    reader.readBool(offsets[0]),
  );
  object.id = id;
  return object;
}

P _roomTagsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _roomTagsGetId(RoomTags object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _roomTagsGetLinks(RoomTags object) {
  return [];
}

void _roomTagsAttach(IsarCollection<dynamic> col, Id id, RoomTags object) {
  object.id = id;
}

extension RoomTagsByIndex on IsarCollection<RoomTags> {
  Future<RoomTags?> getByTag(String tag) {
    return getByIndex(r'tag', [tag]);
  }

  RoomTags? getByTagSync(String tag) {
    return getByIndexSync(r'tag', [tag]);
  }

  Future<bool> deleteByTag(String tag) {
    return deleteByIndex(r'tag', [tag]);
  }

  bool deleteByTagSync(String tag) {
    return deleteByIndexSync(r'tag', [tag]);
  }

  Future<List<RoomTags?>> getAllByTag(List<String> tagValues) {
    final values = tagValues.map((e) => [e]).toList();
    return getAllByIndex(r'tag', values);
  }

  List<RoomTags?> getAllByTagSync(List<String> tagValues) {
    final values = tagValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tag', values);
  }

  Future<int> deleteAllByTag(List<String> tagValues) {
    final values = tagValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tag', values);
  }

  int deleteAllByTagSync(List<String> tagValues) {
    final values = tagValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tag', values);
  }

  Future<Id> putByTag(RoomTags object) {
    return putByIndex(r'tag', object);
  }

  Id putByTagSync(RoomTags object, {bool saveLinks = true}) {
    return putByIndexSync(r'tag', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTag(List<RoomTags> objects) {
    return putAllByIndex(r'tag', objects);
  }

  List<Id> putAllByTagSync(List<RoomTags> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'tag', objects, saveLinks: saveLinks);
  }
}

extension RoomTagsQueryWhereSort on QueryBuilder<RoomTags, RoomTags, QWhere> {
  QueryBuilder<RoomTags, RoomTags, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoomTagsQueryWhere on QueryBuilder<RoomTags, RoomTags, QWhereClause> {
  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> idBetween(
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

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> tagEqualTo(String tag) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tag',
        value: [tag],
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterWhereClause> tagNotEqualTo(
      String tag) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [],
              upper: [tag],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [tag],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [tag],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tag',
              lower: [],
              upper: [tag],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RoomTagsQueryFilter
    on QueryBuilder<RoomTags, RoomTags, QFilterCondition> {
  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> selectedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selected',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterFilterCondition> tagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tag',
        value: '',
      ));
    });
  }
}

extension RoomTagsQueryObject
    on QueryBuilder<RoomTags, RoomTags, QFilterCondition> {}

extension RoomTagsQueryLinks
    on QueryBuilder<RoomTags, RoomTags, QFilterCondition> {}

extension RoomTagsQuerySortBy on QueryBuilder<RoomTags, RoomTags, QSortBy> {
  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> sortBySelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selected', Sort.asc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> sortBySelectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selected', Sort.desc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> sortByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> sortByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }
}

extension RoomTagsQuerySortThenBy
    on QueryBuilder<RoomTags, RoomTags, QSortThenBy> {
  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenBySelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selected', Sort.asc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenBySelectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selected', Sort.desc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<RoomTags, RoomTags, QAfterSortBy> thenByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }
}

extension RoomTagsQueryWhereDistinct
    on QueryBuilder<RoomTags, RoomTags, QDistinct> {
  QueryBuilder<RoomTags, RoomTags, QDistinct> distinctBySelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selected');
    });
  }

  QueryBuilder<RoomTags, RoomTags, QDistinct> distinctByTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tag', caseSensitive: caseSensitive);
    });
  }
}

extension RoomTagsQueryProperty
    on QueryBuilder<RoomTags, RoomTags, QQueryProperty> {
  QueryBuilder<RoomTags, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoomTags, bool, QQueryOperations> selectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selected');
    });
  }

  QueryBuilder<RoomTags, String, QQueryOperations> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tag');
    });
  }
}
