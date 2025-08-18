import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database.dart';

class SocialHandler {
  final DatabaseService _database;

  SocialHandler(this._database);

  Router get router {
    final router = Router();

    // Посты
    router.get('/posts', _getPosts);
    router.post('/posts', _createPost);
    router.get('/posts/<id>', _getPost);
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
    router.post('/chat/rooms', _createChatRoom);
    router.get('/chat/rooms/<roomId>/messages', _getChatMessages);
    router.post('/chat/rooms/<roomId>/messages', _sendMessage);

    return router;
  }

  Future<Response> _getPosts(Request request) async {
    try {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;
      final userId = request.url.queryParameters['userId'];

      String sql = '''
        SELECT p.*, u.name as author_name, u.avatar_url as author_avatar,
               COUNT(DISTINCT l.id) as like_count,
               COUNT(DISTINCT c.id) as comment_count
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
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

      final result = await _database.query(sql, substitutionValues: substitutionValues);

      final totalResult = await _database.query(
        userId != null ? 'SELECT COUNT(*) as total FROM posts WHERE user_id = @userId' : 'SELECT COUNT(*) as total FROM posts',
        substitutionValues: userId != null ? {'userId': userId} : {},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'posts': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _createPost(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // TODO: Implement post creation logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getPost(Request request) async {
    try {
      final postId = request.params['id'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        '''
        SELECT p.*, u.name as author_name, u.avatar_url as author_avatar,
               COUNT(DISTINCT l.id) as like_count,
               COUNT(DISTINCT c.id) as comment_count
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        LEFT JOIN likes l ON p.id = l.post_id
        LEFT JOIN comments c ON p.id = c.post_id
        WHERE p.id = @id
        GROUP BY p.id, u.name, u.avatar_url
        ''',
        substitutionValues: {'id': postId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Post not found',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'post': result.first,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updatePost(Request request) async {
    try {
      final postId = request.params['id'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement post update logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deletePost(Request request) async {
    try {
      final postId = request.params['id'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement post deletion logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _likePost(Request request) async {
    try {
      final postId = request.params['postId'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId = data['userId'];

      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Проверяем, не лайкнул ли уже пользователь этот пост
      final existingLike = await _database.query(
        'SELECT id FROM likes WHERE post_id = @postId AND user_id = @userId',
        substitutionValues: {
          'postId': postId,
          'userId': userId,
        },
      );

      if (existingLike.isNotEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post already liked',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Добавляем лайк
      await _database.execute(
        'INSERT INTO likes (post_id, user_id) VALUES (@postId, @userId)',
        substitutionValues: {
          'postId': postId,
          'userId': userId,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Post liked successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _unlikePost(Request request) async {
    try {
      final postId = request.params['postId'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId = data['userId'];

      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Удаляем лайк
      await _database.execute(
        'DELETE FROM likes WHERE post_id = @postId AND user_id = @userId',
        substitutionValues: {
          'postId': postId,
          'userId': userId,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Post unliked successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getComments(Request request) async {
    try {
      final postId = request.params['postId'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT c.*, u.name as author_name, u.avatar_url as author_avatar
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        WHERE c.post_id = @postId
        ORDER BY c.created_at ASC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'postId': postId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM comments WHERE post_id = @postId',
        substitutionValues: {'postId': postId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'comments': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _createComment(Request request) async {
    try {
      final postId = request.params['postId'];
      if (postId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Post ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement comment creation logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _updateComment(Request request) async {
    try {
      final commentId = request.params['id'];
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Comment ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement comment update logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteComment(Request request) async {
    try {
      final commentId = request.params['id'];
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Comment ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement comment deletion logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _followUser(Request request) async {
    try {
      final targetUserId = request.params['userId'];
      if (targetUserId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Target user ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final followerId = data['followerId'];

      if (followerId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Follower ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (followerId == targetUserId) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Cannot follow yourself',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Проверяем, не подписан ли уже пользователь
      final existingFollow = await _database.query(
        'SELECT id FROM follows WHERE follower_id = @followerId AND following_id = @targetUserId',
        substitutionValues: {
          'followerId': followerId,
          'targetUserId': targetUserId,
        },
      );

      if (existingFollow.isNotEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Already following this user',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Добавляем подписку
      await _database.execute(
        'INSERT INTO follows (follower_id, following_id) VALUES (@followerId, @targetUserId)',
        substitutionValues: {
          'followerId': followerId,
          'targetUserId': targetUserId,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'User followed successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _unfollowUser(Request request) async {
    try {
      final targetUserId = request.params['userId'];
      if (targetUserId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Target user ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final followerId = data['followerId'];

      if (followerId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Follower ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Удаляем подписку
      await _database.execute(
        'DELETE FROM follows WHERE follower_id = @followerId AND following_id = @targetUserId',
        substitutionValues: {
          'followerId': followerId,
          'targetUserId': targetUserId,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'User unfollowed successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getFollowers(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT u.id, u.name, u.avatar_url, u.bio, f.created_at as followed_at
        FROM follows f
        LEFT JOIN users u ON f.follower_id = u.id
        WHERE f.following_id = @userId
        ORDER BY f.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM follows WHERE following_id = @userId',
        substitutionValues: {'userId': userId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'followers': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getFollowing(Request request) async {
    try {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT u.id, u.name, u.avatar_url, u.bio, f.created_at as followed_at
        FROM follows f
        LEFT JOIN users u ON f.following_id = u.id
        WHERE f.follower_id = @userId
        ORDER BY f.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM follows WHERE follower_id = @userId',
        substitutionValues: {'userId': userId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'following': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getNotifications(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT * FROM notifications
        WHERE user_id = @userId
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM notifications WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'notifications': result,
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _markNotificationRead(Request request) async {
    try {
      final notificationId = request.params['id'];
      if (notificationId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Notification ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // TODO: Implement mark notification as read logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getChatRooms(Request request) async {
    try {
      final userId = request.url.queryParameters['userId'];
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _database.query(
        '''
        SELECT cr.*, 
               u1.name as user1_name, u1.avatar_url as user1_avatar,
               u2.name as user2_name, u2.avatar_url as user2_avatar,
               (SELECT content FROM chat_messages 
                WHERE room_id = cr.id 
                ORDER BY created_at DESC LIMIT 1) as last_message,
               (SELECT created_at FROM chat_messages 
                WHERE room_id = cr.id 
                ORDER BY created_at DESC LIMIT 1) as last_message_time
        FROM chat_rooms cr
        LEFT JOIN users u1 ON cr.user1_id = u1.id
        LEFT JOIN users u2 ON cr.user2_id = u2.id
        WHERE cr.user1_id = @userId OR cr.user2_id = @userId
        ORDER BY last_message_time DESC NULLS LAST
        ''',
        substitutionValues: {'userId': userId},
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'chatRooms': result,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _createChatRoom(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // TODO: Implement chat room creation logic
      return Response(501, body: 'Not implemented');
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _getChatMessages(Request request) async {
    try {
      final roomId = request.params['roomId'];
      if (roomId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Room ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final result = await _database.query(
        '''
        SELECT cm.*, u.name as author_name, u.avatar_url as author_avatar
        FROM chat_messages cm
        LEFT JOIN users u ON cm.user_id = u.id
        WHERE cm.room_id = @roomId
        ORDER BY cm.created_at DESC
        LIMIT @limit OFFSET @offset
        ''',
        substitutionValues: {
          'roomId': roomId,
          'limit': limit,
          'offset': offset,
        },
      );

      final totalResult = await _database.query(
        'SELECT COUNT(*) as total FROM chat_messages WHERE room_id = @roomId',
        substitutionValues: {'roomId': roomId},
      );
      final total = totalResult.first['total'] as int;

      return Response.ok(
        jsonEncode({
          'success': true,
          'messages': result.reversed.toList(), // Возвращаем в хронологическом порядке
          'pagination': {
            'total': total,
            'limit': limit,
            'offset': offset,
            'hasMore': offset + limit < total,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _sendMessage(Request request) async {
    try {
      final roomId = request.params['roomId'];
      if (roomId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Room ID is required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId = data['userId'];
      final content = data['content'];

      if (userId == null || content == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'User ID and content are required',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Добавляем сообщение
      final result = await _database.execute(
        'INSERT INTO chat_messages (room_id, user_id, content) VALUES (@roomId, @userId, @content) RETURNING id, created_at',
        substitutionValues: {
          'roomId': roomId,
          'userId': userId,
          'content': content,
        },
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Message sent successfully',
          'messageId': result.first['id'],
          'createdAt': result.first['created_at'],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
