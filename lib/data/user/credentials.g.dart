// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserCredentialsCollection on Isar {
  IsarCollection<UserCredentials> get userCredentials => this.collection();
}

const UserCredentialsSchema = CollectionSchema(
  name: r'UserCredentials',
  id: 2438942716554331846,
  properties: {
    r'authKey': PropertySchema(
      id: 0,
      name: r'authKey',
      type: IsarType.string,
    )
  },
  estimateSize: _userCredentialsEstimateSize,
  serialize: _userCredentialsSerialize,
  deserialize: _userCredentialsDeserialize,
  deserializeProp: _userCredentialsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userCredentialsGetId,
  getLinks: _userCredentialsGetLinks,
  attach: _userCredentialsAttach,
  version: '3.1.0+1',
);

int _userCredentialsEstimateSize(
  UserCredentials object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.authKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userCredentialsSerialize(
  UserCredentials object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authKey);
}

UserCredentials _userCredentialsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserCredentials();
  object.authKey = reader.readStringOrNull(offsets[0]);
  object.id = id;
  return object;
}

P _userCredentialsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userCredentialsGetId(UserCredentials object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userCredentialsGetLinks(UserCredentials object) {
  return [];
}

void _userCredentialsAttach(
    IsarCollection<dynamic> col, Id id, UserCredentials object) {
  object.id = id;
}

extension UserCredentialsQueryWhereSort
    on QueryBuilder<UserCredentials, UserCredentials, QWhere> {
  QueryBuilder<UserCredentials, UserCredentials, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserCredentialsQueryWhere
    on QueryBuilder<UserCredentials, UserCredentials, QWhereClause> {
  QueryBuilder<UserCredentials, UserCredentials, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<UserCredentials, UserCredentials, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterWhereClause> idBetween(
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

extension UserCredentialsQueryFilter
    on QueryBuilder<UserCredentials, UserCredentials, QFilterCondition> {
  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'authKey',
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'authKey',
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      authKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<UserCredentials, UserCredentials, QAfterFilterCondition>
      idBetween(
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
}

extension UserCredentialsQueryObject
    on QueryBuilder<UserCredentials, UserCredentials, QFilterCondition> {}

extension UserCredentialsQueryLinks
    on QueryBuilder<UserCredentials, UserCredentials, QFilterCondition> {}

extension UserCredentialsQuerySortBy
    on QueryBuilder<UserCredentials, UserCredentials, QSortBy> {
  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy> sortByAuthKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authKey', Sort.asc);
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy>
      sortByAuthKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authKey', Sort.desc);
    });
  }
}

extension UserCredentialsQuerySortThenBy
    on QueryBuilder<UserCredentials, UserCredentials, QSortThenBy> {
  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy> thenByAuthKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authKey', Sort.asc);
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy>
      thenByAuthKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authKey', Sort.desc);
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserCredentials, UserCredentials, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension UserCredentialsQueryWhereDistinct
    on QueryBuilder<UserCredentials, UserCredentials, QDistinct> {
  QueryBuilder<UserCredentials, UserCredentials, QDistinct> distinctByAuthKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authKey', caseSensitive: caseSensitive);
    });
  }
}

extension UserCredentialsQueryProperty
    on QueryBuilder<UserCredentials, UserCredentials, QQueryProperty> {
  QueryBuilder<UserCredentials, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserCredentials, String?, QQueryOperations> authKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authKey');
    });
  }
}
