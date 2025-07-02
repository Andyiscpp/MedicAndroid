// lib/data/dao/user_dao.dart
import 'package:floor/floor.dart';
import 'package:demo_conut/data/models/user.dart';

@dao
abstract class UserDao {
  @Insert(onConflict: OnConflictStrategy.abort)
  Future<void> insertUser(User user);

  @Query('SELECT * FROM users WHERE userName = :userName') // 注意表名是 users
  Future<User?> findUserByUsername(String userName);

  @Query('SELECT * FROM users WHERE email = :email')
  Future<User?> findUserByEmail(String email);

  @Query('SELECT * FROM users WHERE id = :id')
  Future<User?> findUserById(int id);

  @Update()
  Future<void> updateUser(User user);

  @delete
  Future<void> deleteUser(User user);
}