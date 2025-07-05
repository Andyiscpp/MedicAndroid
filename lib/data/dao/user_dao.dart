// lib/data/dao/user_dao.dart
import 'package:floor/floor.dart';
// 【关键修复】DAO的所有操作都针对 UserEntity
import 'package:demo_conut/data/models/user_entity.dart';

@dao
abstract class UserDao {
  // 所有方法签名都将 User 替换为 UserEntity
  @Insert(onConflict: OnConflictStrategy.abort)
  Future<void> insertUser(UserEntity user);

  @Query('SELECT * FROM users WHERE username = :username')
  Future<UserEntity?> findUserByUsername(String username);

  @Query('SELECT * FROM users WHERE email = :email')
  Future<UserEntity?> findUserByEmail(String email);

  @Query('SELECT * FROM users WHERE id = :id')
  Future<UserEntity?> findUserById(int id);

  @Update()
  Future<void> updateUser(UserEntity user);

  @delete
  Future<void> deleteUser(UserEntity user);
}