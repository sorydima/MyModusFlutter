import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';

class SocialHandler {
  final DatabaseService _db;

  SocialHandler(this._db);

  Router get router {
    final router = Router();

    // Посты
    router.get('/posts', _getPosts);
    router.get('/posts/<id>', _getPost);
    router.post('/posts', _createPost);
    router.put('/posts/<id>', _updatePost);
    router.delete('/posts/<id>', _deletePost);
    
    // Лайки
    router.post('/posts/<postId>/like', _likePost);
    router.delete('/posts/<postId>/like', _unlikePost);
    
    // Комментарии
    router.get('/posts/<postId>/comments', _getComments);
    router.post('/posts/<postId>/comments', _createComment);
    router.put('/comments/<id>', _updateComment);
    router.delete('/comments/<id>', _deleteComment);
    
    // Подписки
    router.post('/users/<userId>/follow', _followUser);
    router.delete('/users/<userId>/follow', _unfollowUser);
    router.get('/users/<userId>/followers', _getFollowers);
    router.get('/users/<userId>/following', _getFollowing);
    
    // Уведомления
    router.get('/notifications', _getNotifications);
    router.put('/notifications/<id>/read', _markNotificationRead);
    
    // Чат
    router.get('/chat/rooms', _getChatRooms);
    router.get('/chat/rooms/<roomId>/messages', _getChatMessages);
    router.post('/chat/rooms/<roomId>/messages', _sendMessage);
    router.post('/chat/rooms', _createChatRoom);

    return router;
  }

  // Получение постов
  Future<Response> _getPosts(Request request) async {
    try {
      final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;
      final userId = request.url.queryParameters['userId'];

      var sql = '''
        SELECT p.*, u.name as author_name, u.avatar_url as author_avatar,
               COUNT(l.id) as like_count, COUNT(c.id) as comment_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN likes l ON p.id = l.post_id
        LEFT JOIN comments c ON p.id = c.post_id
      ''';

      final substitutionValues = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (userId != null) {
        sql += ' WHERE p.user_id = @userId';
        substitutionValues['userId'] = userId;
      }

      sql += ' GROUP BY p.id, u.name, u.avatar_url ORDER BY p.created_at DESC LIMIT @limit OFFSET @offset';

      final posts = await _db.query(sql, substitutionValues: substitutionValues);

      return Response(200, 
        body: json.encode({
          'posts': posts.map((post) => {
            'id': post['id'],
            'content': post['content'],
            'imageUrl': post['image_url'],
            'videoUrl': post['video_url'],
            'userId': post['user_id'],
            'authorName': post['author_name'],
            'authorAvatar': post['author_avatar'],
            'likeCount': post['like_count'],
            'commentCount': post['comment_count'],
            'isActive': post['is_active'],
            'createdAt': post['created_at'].toString(),
            'updatedAt': post['updated_at'].toString()
          }).toList(),
          'pagination': {
            'page': page,
            'limit': limit,
            'hasNext': posts.length == limit
          }
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Создание поста
  Future<Response> _createPost(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final content = data['content'] as String?;
      final imageUrl = data['imageUrl'] as String?;
      final videoUrl = data['videoUrl'] as String?;

      if (userId == null || content == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя и контент обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final result = await _db.execute(
        '''
        INSERT INTO posts (user_id, content, image_url, video_url, is_active)
        VALUES (@userId, @content, @imageUrl, @videoUrl, true)
        RETURNING id
        ''',
        substitutionValues: {
          'userId': userId,
          'content': content,
          'imageUrl': imageUrl,
          'videoUrl': videoUrl,
        }
      );

      return Response(201, 
        body: json.encode({
          'message': 'Пост создан',
          'postId': result.first['id']
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Лайк поста
  Future<Response> _likePost(Request request) async {
    try {
      final postId = request.params['postId'];
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;
      final userId = data['userId'] as String?;

      if (postId == null || userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID поста и пользователя обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      await _db.execute(
        'INSERT INTO likes (post_id, user_id) VALUES (@postId, @userId)',
        substitutionValues: {
          'postId': postId,
          'userId': userId,
        }
      );

      return Response(200, 
        body: json.encode({'message': 'Пост лайкнут'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Подписка на пользователя
  Future<Response> _followUser(Request request) async {
    try {
      final targetUserId = request.params['userId'];
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;
      final followerId = data['followerId'] as String?;

      if (targetUserId == null || followerId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователей обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      if (targetUserId == followerId) {
        return Response(400, 
          body: json.encode({'error': 'Нельзя подписаться на себя'}),
          headers: {'content-type': 'application/json'}
        );
      }

      await _db.execute(
        'INSERT INTO follows (follower_id, following_id) VALUES (@followerId, @targetUserId)',
        substitutionValues: {
          'followerId': followerId,
          'targetUserId': targetUserId,
        }
      );

      return Response(200, 
        body: json.encode({'message': 'Подписка оформлена'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение уведомлений
  Future<Response> _getNotifications(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final notifications = await _db.query(
        '''
        SELECT * FROM notifications 
        WHERE user_id = @userId 
        ORDER BY created_at DESC 
        LIMIT 50
        ''',
        substitutionValues: {'userId': userId}
      );

      return Response(200, 
        body: json.encode({
          'notifications': notifications.map((notif) => {
            'id': notif['id'],
            'type': notif['type'],
            'message': notif['message'],
            'isRead': notif['is_read'],
            'createdAt': notif['created_at'].toString()
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Получение чат-комнат
  Future<Response> _getChatRooms(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      
      if (userId == null) {
        return Response(400, 
          body: json.encode({'error': 'ID пользователя обязателен'}),
          headers: {'content-type': 'application/json'}
        );
      }

      final rooms = await _db.query(
        '''
        SELECT cr.*, u.name as other_user_name, u.avatar_url as other_user_avatar,
               (SELECT content FROM chat_messages 
                WHERE room_id = cr.id 
                ORDER BY created_at DESC LIMIT 1) as last_message
        FROM chat_rooms cr
        JOIN chat_participants cp1 ON cr.id = cp1.room_id
        JOIN chat_participants cp2 ON cr.id = cp2.room_id
        JOIN users u ON (cp2.user_id = u.id AND cp2.user_id != @userId)
        WHERE cp1.user_id = @userId
        ORDER BY cr.updated_at DESC
        ''',
        substitutionValues: {'userId': userId}
      );

      return Response(200, 
        body: json.encode({
          'rooms': rooms.map((room) => {
            'id': room['id'],
            'otherUserName': room['other_user_name'],
            'otherUserAvatar': room['other_user_avatar'],
            'lastMessage': room['last_message'],
            'updatedAt': room['updated_at'].toString()
          }).toList()
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Отправка сообщения
  Future<Response> _sendMessage(Request request) async {
    try {
      final roomId = request.params['roomId'];
      final payload = await request.readAsString();
      final data = json.decode(payload) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final content = data['content'] as String?;

      if (roomId == null || userId == null || content == null) {
        return Response(400, 
          body: json.encode({'error': 'ID комнаты, пользователя и контент обязательны'}),
          headers: {'content-type': 'application/json'}
        );
      }

      await _db.execute(
        '''
        INSERT INTO chat_messages (room_id, user_id, content)
        VALUES (@roomId, @userId, @content)
        ''',
        substitutionValues: {
          'roomId': roomId,
          'userId': userId,
          'content': content,
        }
      );

      // Обновление времени комнаты
      await _db.execute(
        'UPDATE chat_rooms SET updated_at = NOW() WHERE id = @roomId',
        substitutionValues: {'roomId': roomId}
      );

      return Response(200, 
        body: json.encode({'message': 'Сообщение отправлено'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response(500, 
        body: json.encode({'error': 'Ошибка сервера: $e'}),
        headers: {'content-type': 'application/json'}
      );
    }
  }

  // Остальные методы для полноты API
  Future<Response> _getPost(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _updatePost(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _deletePost(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _unlikePost(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getComments(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _createComment(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _updateComment(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _deleteComment(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _unfollowUser(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getFollowers(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getFollowing(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _markNotificationRead(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _getChatMessages(Request request) async => Response(501, body: 'Not implemented');
  Future<Response> _createChatRoom(Request request) async => Response(501, body: 'Not implemented');
}
