import 'package:wakaranai/data/domain/base_domain.dart';

abstract class BaseActivityDomain<TTableCompanion>
    extends BaseDomain<TTableCompanion> {
  final String title;
  final String uid;
  final int concreteId;

  BaseActivityDomain({
    required this.title,
    required this.uid,
    required this.concreteId,
    required super.id,
    required super.createdAt,
    super.updatedAt,
  });
}
