import 'package:wakaranai/database/wakaranai_database.dart';

abstract class BaseRepository<TDomain> {
  Future<TDomain?> get(int id);

  Future<TDomain?> create(TDomain domain);

  Future<List<TDomain>> getAll();

  Future<TDomain?> update(TDomain domain);

  Future<TDomain?> delete(TDomain domain);

}
