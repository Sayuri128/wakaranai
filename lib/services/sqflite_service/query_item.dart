abstract class SqfliteQueryItem {
  const SqfliteQueryItem();
}

enum SqfliteQueryComparisonOperator {
  EQUAL_TO,
  NOT_EQUAL_TO,
  LESS_THAN,
  GREATER_THAN,
  LESS_THAN_OR_EQUAL_TO,
  GREATER_THAN_OR_EQUAL_TO
}

String serializeSqfliteComparisonOperator(
    SqfliteQueryComparisonOperator operator) {
  switch (operator) {
    case SqfliteQueryComparisonOperator.EQUAL_TO:
      return "=";
    case SqfliteQueryComparisonOperator.NOT_EQUAL_TO:
      return "!=";
    case SqfliteQueryComparisonOperator.LESS_THAN:
      return "<";
    case SqfliteQueryComparisonOperator.GREATER_THAN:
      return ">";
    case SqfliteQueryComparisonOperator.LESS_THAN_OR_EQUAL_TO:
      return "<=";
    case SqfliteQueryComparisonOperator.GREATER_THAN_OR_EQUAL_TO:
      return ">=";
  }
}

SqfliteQueryComparisonOperator deserializeSqfliteComparisonOperator(
    String value) {
  return SqfliteQueryComparisonOperator.values
      .firstWhere((e) => serializeSqfliteComparisonOperator(e) == value);
}

class SqfliteQueryKeyValueItem<T> extends SqfliteQueryItem {
  final String key;
  final T value;
  final SqfliteQueryComparisonOperator operator;

  const SqfliteQueryKeyValueItem(
      {required this.key,
      required this.value,
      this.operator = SqfliteQueryComparisonOperator.EQUAL_TO});
}

enum SqfliteOperator { ALL, AND, ANY, BETWEEN, EXISTS, IN, LIKE, NOT, OR }

String serializeSqfliteOperator(SqfliteOperator operator) {
  return operator.name;
}

SqfliteOperator deserializeSqfliteOperator(String value) {
  return SqfliteOperator.values.firstWhere((e) => e.name == value);
}

class SqfliteQueryOperatorItem extends SqfliteQueryItem {
  final SqfliteOperator operator;

  const SqfliteQueryOperatorItem({
    required this.operator,
  });
}
