import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

abstract class BaseRepository<TDomain extends BaseDomain> {
  final WakaranaiDatabase database;

  Future<TDomain?> get(int id);

  Future<TDomain?> create(TDomain domain);

  Future<List<TDomain>> getAll();

  Future<TDomain?> update(TDomain domain);

  Future<TDomain?> delete(TDomain domain);

  BaseRepository({required this.database});
}
